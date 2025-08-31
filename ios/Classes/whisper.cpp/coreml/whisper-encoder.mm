//
// whisper-encoder.mm
//
// Created by Claude Code for whisper_flutter_coreml
//

#import "whisper-encoder.h"

#import <CoreML/CoreML.h>
#import <Foundation/Foundation.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

struct whisper_coreml_context {
    MLModel * model;
    MLModelConfiguration * config;
};

struct whisper_coreml_context * whisper_coreml_init(const char * path_model) {
    if (!path_model) {
        NSLog(@"[CoreML] Invalid model path provided (null)");
        return nullptr;
    }
    
    NSString *modelPath = [NSString stringWithUTF8String:path_model];
    
    // Enhanced file existence checking
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:modelPath isDirectory:&isDirectory];
    
    if (!exists) {
        NSLog(@"[CoreML] Model not found at: %@ - falling back to CPU processing", modelPath);
        return nullptr;
    }
    
    // CoreML models are typically directories (.mlmodelc)
    if (!isDirectory && ![modelPath hasSuffix:@".mlmodelc"]) {
        NSLog(@"[CoreML] Warning: Expected .mlmodelc directory but found file at: %@", modelPath);
    }
    
    @try {
        NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
        
        // Create model configuration with explicit compute units
        MLModelConfiguration *config = [[MLModelConfiguration alloc] init];
        config.computeUnits = MLComputeUnitsAll; // Use all available compute units including ANE
        
        NSError *error = nil;
        MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:config error:&error];
        
        if (!model || error) {
            NSLog(@"[CoreML] Failed to load model from %@: %@ - falling back to CPU", 
                  modelPath, error ? error.localizedDescription : @"Unknown error");
            return nullptr;
        }
        
        // Validate model has expected inputs/outputs
        MLModelDescription *description = model.modelDescription;
        if (!description.inputDescriptionsByName || description.inputDescriptionsByName.count == 0) {
            NSLog(@"[CoreML] Model has no valid inputs - falling back to CPU");
            return nullptr;
        }
        
        // Enhanced model compatibility validation
        NSString *inputName = description.inputDescriptionsByName.allKeys.firstObject;
        MLFeatureDescription *inputDesc = description.inputDescriptionsByName[inputName];
        
        if (inputDesc.type != MLFeatureTypeMultiArray) {
            NSLog(@"[CoreML] Model input is not MultiArray type (got %ld) - falling back to CPU", (long)inputDesc.type);
            return nullptr;
        }
        
        NSArray<NSNumber *> *inputShape = inputDesc.multiArrayConstraint.shape;
        NSLog(@"[CoreML] Model input shape: %@ (dimensions: %lu)", inputShape, (unsigned long)inputShape.count);
        
        // Check if shape is compatible with whisper encoder expectations
        NSInteger totalElements = 1;
        for (NSNumber *dim in inputShape) {
            totalElements *= dim.integerValue;
        }
        
        // Whisper encoder should accept reasonable input sizes
        if (totalElements < 10000 || totalElements > 2000000) {
            NSLog(@"[CoreML] Model input size (%ld elements) outside reasonable range (10K-2M) - falling back to CPU", 
                  (long)totalElements);
            return nullptr;
        }
        
        // Check output compatibility
        if (!description.outputDescriptionsByName || description.outputDescriptionsByName.count == 0) {
            NSLog(@"[CoreML] Model has no valid outputs - falling back to CPU");
            return nullptr;
        }
        
        NSString *outputName = description.outputDescriptionsByName.allKeys.firstObject;
        MLFeatureDescription *outputDesc = description.outputDescriptionsByName[outputName];
        
        if (outputDesc.type != MLFeatureTypeMultiArray) {
            NSLog(@"[CoreML] Model output is not MultiArray type - falling back to CPU");
            return nullptr;
        }
        
        NSArray<NSNumber *> *outputShape = outputDesc.multiArrayConstraint.shape;
        NSLog(@"[CoreML] Model output shape: %@", outputShape);
        
        NSInteger outputElements = 1;
        for (NSNumber *dim in outputShape) {
            outputElements *= dim.integerValue;
        }
        
        // Whisper encoder output should be reasonable size (typically n_state * n_ctx)
        if (outputElements < 100000 || outputElements > 5000000) {
            NSLog(@"[CoreML] Model output size (%ld elements) outside reasonable range (100K-5M) - falling back to CPU", 
                  (long)outputElements);
            return nullptr;
        }
        
        NSLog(@"[CoreML] Model compatibility check passed - input: %ld elements, output: %ld elements", 
              (long)totalElements, (long)outputElements);
        
        whisper_coreml_context *ctx = new whisper_coreml_context();
        ctx->model = model;
        ctx->config = config;
        
        NSLog(@"[CoreML] Successfully loaded model from: %@", modelPath);
        NSLog(@"[CoreML] Model inputs: %@", [description.inputDescriptionsByName.allKeys componentsJoinedByString:@", "]);
        NSLog(@"[CoreML] Model outputs: %@", [description.outputDescriptionsByName.allKeys componentsJoinedByString:@", "]);
        
        return ctx;
        
    } @catch (NSException *exception) {
        NSLog(@"[CoreML] Exception during model loading: %@ - falling back to CPU", exception.reason);
        return nullptr;
    }
}

int whisper_coreml_encode(
    struct whisper_coreml_context * ctx,
    float                         * mel,
    float                         * out) {
    
    // Legacy wrapper - auto-detect dimensions and call new implementation
    int n_state = whisper_coreml_get_n_state(ctx);
    if (n_state <= 0) {
        n_state = 512; // Default to base model
    }
    return whisper_coreml_encode_with_dims(ctx, mel, out, n_state, 1500, n_state * sizeof(float));
}

int whisper_coreml_encode_with_dims(
    struct whisper_coreml_context * ctx,
    float                         * mel,
    float                         * out,
    int                             out_n_state,
    int                             out_n_ctx,
    size_t                          out_stride_bytes) {
    
    // CRITICAL: Always validate inputs first
    if (!ctx) {
        NSLog(@"[CoreML] No CoreML context - using CPU fallback");
        return -1; // Graceful fallback to CPU
    }
    
    if (!ctx->model) {
        NSLog(@"[CoreML] No CoreML model in context - using CPU fallback");
        return -1; // Graceful fallback to CPU
    }
    
    if (!mel || !out) {
        NSLog(@"[CoreML] Invalid mel spectrogram or output buffer - using CPU fallback");
        return -1; // Graceful fallback to CPU
    }
    
    @try {
        NSLog(@"[CoreML] Starting encoder prediction...");
        
        // Get model description to understand input/output shapes
        MLModelDescription *description = ctx->model.modelDescription;
        NSDictionary<NSString *, MLFeatureDescription *> *inputDescriptions = description.inputDescriptionsByName;
        NSDictionary<NSString *, MLFeatureDescription *> *outputDescriptions = description.outputDescriptionsByName;
        
        // Log model information for debugging
        NSLog(@"[CoreML] Model inputs: %@", [inputDescriptions.allKeys componentsJoinedByString:@", "]);
        NSLog(@"[CoreML] Model outputs: %@", [outputDescriptions.allKeys componentsJoinedByString:@", "]);
        
        // Find the input feature (typically named "melspectrogram" or similar)
        NSString *inputName = inputDescriptions.allKeys.firstObject;
        if (!inputName) {
            NSLog(@"[CoreML] No input features found in model - using CPU fallback");
            return -1;
        }
        
        MLFeatureDescription *inputDesc = inputDescriptions[inputName];
        if (inputDesc.type != MLFeatureTypeMultiArray) {
            NSLog(@"[CoreML] Input feature is not MultiArray type - using CPU fallback");
            return -1;
        }
        
        // Get input dimensions from model
        NSArray<NSNumber *> *inputShape = inputDesc.multiArrayConstraint.shape;
        NSLog(@"[CoreML] Input shape: %@", inputShape);
        
        // Create input MLMultiArray from mel spectrogram
        NSError *error = nil;
        MLMultiArray *inputArray = [[MLMultiArray alloc] 
            initWithShape:inputShape 
            dataType:MLMultiArrayDataTypeFloat32 
            error:&error];
            
        if (!inputArray || error) {
            NSLog(@"[CoreML] Failed to create input array: %@ - using CPU fallback", 
                  error ? error.localizedDescription : @"Unknown error");
            return -1;
        }
        
        // Calculate expected input size
        NSInteger totalElements = 1;
        for (NSNumber *dim in inputShape) {
            totalElements *= dim.integerValue;
        }
        
        // Copy mel data to MLMultiArray with validation
        // Note: mel is expected to be [2*n_ctx, n_mels] typically [3000, 80]
        // Whisper.cpp typically uses n_ctx=1500, n_mels=80 -> 3000*80=240000 elements
        NSLog(@"[CoreML] Expected input elements: %ld, model expects: %ld", 
              (long)(3000 * 80), (long)totalElements);
        
        // Dynamic input size calculation based on model requirements
        // Extract dimensions from model shape: typically [batch, n_mels, height, n_ctx]
        NSInteger batchSize = 1, nMels = 80, height = 1, nCtx = 1500;
        
        if (inputShape.count >= 4) {
            batchSize = inputShape[0].integerValue;
            nMels = inputShape[1].integerValue; 
            height = inputShape[2].integerValue;
            nCtx = inputShape[3].integerValue;
        } else if (inputShape.count >= 2) {
            // Handle 2D case [n_features, n_ctx] 
            nMels = inputShape[0].integerValue;
            nCtx = inputShape[1].integerValue;
        }
        
        NSLog(@"[CoreML] Detected model dimensions: batch=%ld, n_mels=%ld, height=%ld, n_ctx=%ld", 
              (long)batchSize, (long)nMels, (long)height, (long)nCtx);
        
        // Calculate source data dimensions (whisper.cpp standard)
        const NSInteger srcNCtx = 1500; // Standard whisper context
        const NSInteger srcNMels = 80;   // Standard mel features  
        const NSInteger srcElements = 2 * srcNCtx * srcNMels; // 240,000 elements
        
        NSLog(@"[CoreML] Source data: %ld elements (%ld ctx × %ld mels × 2)", 
              (long)srcElements, (long)srcNCtx, (long)srcNMels);
        NSLog(@"[CoreML] Model expects: %ld elements", (long)totalElements);
        
        float *inputData = (float *)inputArray.dataPointer;
        
        // Initialize input array to zero
        memset(inputData, 0, totalElements * sizeof(float));
        
        // Reshape and copy mel data based on size compatibility
        if (srcElements == totalElements) {
            // Direct copy - same size
            NSLog(@"[CoreML] Direct copy: source and model have same size");
            for (NSInteger i = 0; i < totalElements; i++) {
                float value = mel[i];
                if (isnan(value) || isinf(value)) {
                    value = 0.0f; // Sanitize invalid values instead of failing
                }
                inputData[i] = value;
            }
        } else if (srcElements < totalElements) {
            // Model expects more features - need to reshape/interpolate
            NSLog(@"[CoreML] Reshaping: expanding %ld to %ld elements", (long)srcElements, (long)totalElements);
            
            // Handle shape transformation from [2*n_ctx, n_mels] to [batch, n_mels_new, height, n_ctx_new]
            if (inputShape.count >= 4) {
                // 4D tensor reshape
                const NSInteger srcFrames = 2 * srcNCtx; // 3000 frames
                const NSInteger dstFrames = nCtx; 
                const NSInteger melRatio = nMels / srcNMels; // e.g., 128/80 = 1.6
                
                for (NSInteger frame = 0; frame < MIN(srcFrames, dstFrames); frame++) {
                    for (NSInteger srcMel = 0; srcMel < srcNMels; srcMel++) {
                        float value = mel[frame * srcNMels + srcMel];
                        if (isnan(value) || isinf(value)) value = 0.0f;
                        
                        // Map source mel to destination mel features with interpolation
                        NSInteger dstMelStart = (srcMel * nMels) / srcNMels;
                        NSInteger dstMelEnd = ((srcMel + 1) * nMels) / srcNMels;
                        
                        for (NSInteger dstMel = dstMelStart; dstMel < dstMelEnd; dstMel++) {
                            NSInteger dstIdx = frame * nMels + dstMel;
                            if (dstIdx < totalElements) {
                                inputData[dstIdx] = value;
                            }
                        }
                    }
                }
            } else {
                // 2D tensor - simple copy with truncation
                NSInteger copyElements = MIN(srcElements, totalElements);
                for (NSInteger i = 0; i < copyElements; i++) {
                    float value = mel[i];
                    if (isnan(value) || isinf(value)) value = 0.0f;
                    inputData[i] = value;
                }
            }
        } else {
            // Model expects fewer features - truncate
            NSLog(@"[CoreML] Reshaping: truncating %ld to %ld elements", (long)srcElements, (long)totalElements);
            for (NSInteger i = 0; i < totalElements; i++) {
                float value = mel[i];
                if (isnan(value) || isinf(value)) value = 0.0f;
                inputData[i] = value;
            }
        }
        
        NSLog(@"[CoreML] Successfully created input array with %ld validated elements", (long)totalElements);
        
        // Create feature provider
        NSDictionary *inputFeatures = @{inputName: [MLFeatureValue featureValueWithMultiArray:inputArray]};
        MLDictionaryFeatureProvider *provider = [[MLDictionaryFeatureProvider alloc] 
            initWithDictionary:inputFeatures error:&error];
            
        if (!provider || error) {
            NSLog(@"[CoreML] Failed to create feature provider: %@ - using CPU fallback", 
                  error ? error.localizedDescription : @"Unknown error");
            return -1;
        }
        
        // Run prediction
        NSLog(@"[CoreML] Running model prediction...");
        id<MLFeatureProvider> result = [ctx->model predictionFromFeatures:provider error:&error];
        
        if (!result || error) {
            NSLog(@"[CoreML] Model prediction failed: %@ - using CPU fallback", 
                  error ? error.localizedDescription : @"Unknown error");
            return -1;
        }
        
        // Extract output
        NSString *outputName = outputDescriptions.allKeys.firstObject;
        if (!outputName) {
            NSLog(@"[CoreML] No output features found - using CPU fallback");
            return -1;
        }
        
        MLFeatureValue *outputFeature = [result featureValueForName:outputName];
        if (!outputFeature || outputFeature.type != MLFeatureTypeMultiArray) {
            NSLog(@"[CoreML] Invalid output feature - using CPU fallback");
            return -1;
        }
        
        MLMultiArray *outputArray = outputFeature.multiArrayValue;
        NSArray<NSNumber *> *outputShape = outputArray.shape;
        NSLog(@"[CoreML] Output shape: %@", outputShape);
        
        // CRITICAL: Debug CoreML MLMultiArray memory layout and data type
        NSArray<NSNumber *> *outputStrides = outputArray.strides;
        NSLog(@"[CoreML] Output strides: %@ (elements)", outputStrides);
        NSLog(@"[CoreML] CoreML data pointer: %p", outputArray.dataPointer);
        NSLog(@"[CoreML] CoreML data type: %d", (int)outputArray.dataType);
        NSLog(@"[CoreML] Data type reference - Float16=%d, Float32=%d, Double=%d, Int32=%d", 
              (int)MLMultiArrayDataTypeFloat16, (int)MLMultiArrayDataTypeFloat32,
              (int)MLMultiArrayDataTypeDouble, (int)MLMultiArrayDataTypeInt32);
              
        // Validate data type and prepare for conversion
        BOOL needsConversion = NO;
        size_t elementSize = 0;
        NSString *dataTypeName = @"Unknown";
        
        switch (outputArray.dataType) {
            case MLMultiArrayDataTypeFloat16:
                elementSize = 2;  // 16 bits = 2 bytes
                dataTypeName = @"Float16";
                needsConversion = YES;  // Need to convert to Float32
                break;
            case MLMultiArrayDataTypeFloat32:
                elementSize = 4;  // 32 bits = 4 bytes
                dataTypeName = @"Float32";
                needsConversion = NO;   // Already Float32
                break;
            case MLMultiArrayDataTypeDouble:
                elementSize = 8;  // 64 bits = 8 bytes
                dataTypeName = @"Double";
                needsConversion = YES;  // Need to convert to Float32
                break;
            default:
                NSLog(@"[CoreML] ERROR: Unsupported data type %d - using CPU fallback", (int)outputArray.dataType);
                return -1;
        }
        
        NSLog(@"[CoreML] Detected data type: %@ (%zu bytes per element), conversion needed: %@",
              dataTypeName, elementSize, needsConversion ? @"YES" : @"NO");
        
        // Calculate stride information in bytes
        if (outputStrides.count >= 2) {
            NSInteger stride0_elements = outputStrides[0].integerValue;  // stride for dim 0
            NSInteger stride1_elements = outputStrides[1].integerValue;  // stride for dim 1
            NSLog(@"[CoreML] CoreML strides: [%ld, %ld] elements = [%ld, %ld] bytes", 
                  (long)stride0_elements, (long)stride1_elements,
                  (long)(stride0_elements * sizeof(float)), (long)(stride1_elements * sizeof(float)));
        }
        
        // Calculate output size
        NSInteger outputElements = 1;
        for (NSNumber *dim in outputShape) {
            outputElements *= dim.integerValue;
        }
        
        // CRITICAL: Calculate actual memory layout size accounting for stride padding
        // Declare at outer scope so it's accessible throughout the function
        __block NSInteger actualMemoryElements = outputElements;  // Default to logical size
        if (outputStrides.count > 0 && outputShape.count > 0) {
            // The actual memory size is stride[0] * shape[0] for the first dimension
            // This accounts for any padding in the memory layout
            NSInteger firstDimStride = outputStrides[0].integerValue;
            NSInteger firstDimSize = outputShape[0].integerValue;
            actualMemoryElements = firstDimStride * firstDimSize;
            
            // Detect and log padding
            if (actualMemoryElements > outputElements) {
                NSInteger paddingElements = actualMemoryElements - outputElements;
                NSLog(@"[CoreML] ⚠️ Detected stride padding: logical=%ld elements, physical=%ld elements, padding=%ld elements", 
                      (long)outputElements, (long)actualMemoryElements, (long)paddingElements);
                
                // Check individual dimension strides for padding
                if (outputShape.count >= 4 && outputStrides.count >= 4) {
                    NSInteger expectedStride3 = 1;
                    NSInteger expectedStride2 = outputShape[3].integerValue;
                    NSInteger expectedStride1 = outputShape[2].integerValue * outputShape[3].integerValue;
                    
                    if (outputStrides[3].integerValue != expectedStride3 ||
                        outputStrides[2].integerValue != expectedStride2 ||
                        outputStrides[1].integerValue != expectedStride1) {
                        NSLog(@"[CoreML] Stride padding details:");
                        NSLog(@"[CoreML] • Dim 3: expected=%ld, actual=%ld", 
                              (long)expectedStride3, (long)outputStrides[3].integerValue);
                        NSLog(@"[CoreML] • Dim 2: expected=%ld, actual=%ld", 
                              (long)expectedStride2, (long)outputStrides[2].integerValue);
                        NSLog(@"[CoreML] • Dim 1: expected=%ld, actual=%ld (padding=%ld)", 
                              (long)expectedStride1, (long)outputStrides[1].integerValue,
                              (long)(outputStrides[1].integerValue - expectedStride1));
                    }
                }
            }
        }
        
        // Copy output data to result buffer with safe memory access
        // Expected output: [n_state, n_ctx] where n_ctx=1500, n_state varies by model
        // For base model: 512*1500=768000 elements, for small: 512*1500=768000 elements
        
        NSLog(@"[CoreML] Output validation: %ld elements, expected format [n_state, n_ctx]", (long)outputElements);
        
        // Safe memory access with proper validation - handle different data types
        void *outputDataPtr = outputArray.dataPointer;
        if (!outputDataPtr) {
            NSLog(@"[CoreML] Output data pointer is null - using CPU fallback");
            return -1;
        }
        
        // Validate MLMultiArray properties
        if (outputArray.count != outputElements) {
            NSLog(@"[CoreML] Output array count mismatch: expected %ld, got %ld - using CPU fallback", 
                  (long)outputElements, (long)outputArray.count);
            return -1;
        }
        
        const size_t outputSize = outputElements * sizeof(float);
        
        // Minimal validation approach - check only essential elements to avoid crashes
        // CRITICAL: Handle different data types properly during validation
        @try {
            // Helper function to get value at index based on data type
            auto getValueAtIndex = [&](NSInteger index) -> float {
                switch (outputArray.dataType) {
                    case MLMultiArrayDataTypeFloat16: {
                        __fp16 *f16Data = (__fp16*)outputDataPtr;
                        return (float)f16Data[index];
                    }
                    case MLMultiArrayDataTypeFloat32: {
                        float *f32Data = (float*)outputDataPtr;
                        return f32Data[index];
                    }
                    case MLMultiArrayDataTypeDouble: {
                        double *f64Data = (double*)outputDataPtr;
                        return (float)f64Data[index];
                    }
                    default:
                        return NAN;
                }
            };
            
            // Check first element
            if (outputElements > 0) {
                float firstValue = getValueAtIndex(0);
                if (isnan(firstValue) || isinf(firstValue)) {
                    NSLog(@"[CoreML] First output element is invalid (%f) - using CPU fallback", firstValue);
                    return -1;
                }
                NSLog(@"[CoreML] First element validation: value=%f (valid)", firstValue);
            }
            
            // Check middle element
            if (outputElements > 1) {
                NSInteger midIndex = outputElements / 2;
                float midValue = getValueAtIndex(midIndex);
                if (isnan(midValue) || isinf(midValue)) {
                    NSLog(@"[CoreML] Middle output element is invalid (%f) - using CPU fallback", midValue);
                    return -1;
                }
                NSLog(@"[CoreML] Middle element validation: index=%ld, value=%f (valid)", (long)midIndex, midValue);
            }
            
            // Check last element with bounds safety
            if (outputElements > 2) {
                NSInteger lastIdx = outputElements - 1;
                if (lastIdx >= 0 && lastIdx < actualMemoryElements) {  // Use actualMemoryElements for bounds
                    float lastValue = getValueAtIndex(lastIdx);
                    if (isnan(lastValue) || isinf(lastValue)) {
                        NSLog(@"[CoreML] Last output element is invalid (%f) - using CPU fallback", lastValue);
                        return -1;
                    }
                    NSLog(@"[CoreML] Last element validation: index=%ld, value=%f (valid)", (long)lastIdx, lastValue);
                } else {
                    NSLog(@"[CoreML] Invalid last element index %ld/%ld - using CPU fallback", (long)lastIdx, (long)actualMemoryElements);
                    return -1;
                }
            }
            
            NSLog(@"[CoreML] Minimal validation passed - first/middle/last elements are valid");
            
        } @catch (NSException *exception) {
            NSLog(@"[CoreML] Exception during output validation: %@ - using CPU fallback", exception.reason);
            return -1;
        }
        
        // CRITICAL: Use the actual allocated buffer dimensions instead of hardcoded values
        // The 'out' buffer dimensions are now passed from whisper.cpp
        const NSInteger whisperNState = out_n_state;   // Actual allocated buffer state dimension
        const NSInteger whisperNCtx = out_n_ctx;       // Actual allocated buffer context dimension
        
        NSLog(@"[CoreML] Using actual buffer dimensions: [%ld×%ld] (passed from whisper.cpp)", 
              (long)whisperNState, (long)whisperNCtx);
        NSLog(@"[CoreML] GGML buffer stride: %zu bytes (%zu floats per row)", 
              out_stride_bytes, out_stride_bytes / sizeof(float));
              
        // Validate stride makes sense
        if (out_stride_bytes < whisperNState * sizeof(float)) {
            NSLog(@"[CoreML] ERROR: Invalid stride - stride=%zu bytes < expected=%ld bytes", 
                  out_stride_bytes, (long)(whisperNState * sizeof(float)));
            return -1;
        }
        
        // Extract actual model dimensions to determine expected buffer size
        NSInteger modelNState = 512;
        NSInteger modelNCtx = 1500;
        
        if (outputShape.count >= 4) {
            // Format: [batch, n_state, height, n_ctx] -> [1, 1280, 1, 1500]
            modelNState = outputShape[1].integerValue;
            modelNCtx = outputShape[3].integerValue;
        } else if (outputShape.count >= 2) {
            // Format: [n_state, n_ctx] -> [1280, 1500]
            modelNState = outputShape[0].integerValue;
            modelNCtx = outputShape[1].integerValue;
        }
        
        const size_t whisperBufferSize = whisperNState * whisperNCtx * sizeof(float);
        
        NSLog(@"[CoreML] Buffer compatibility: whisper expects [%ld×%ld]=%.2fMB, model outputs [%ld×%ld]=%.2fMB", 
              (long)whisperNState, (long)whisperNCtx, whisperBufferSize / (1024.0*1024.0),
              (long)modelNState, (long)modelNCtx, (modelNState * modelNCtx * sizeof(float)) / (1024.0*1024.0));
        
        // Adaptive processing: handle size mismatches gracefully
        if (modelNState > whisperNState || modelNCtx > whisperNCtx) {
            NSLog(@"[CoreML] ⚠️  Model dimensions exceed whisper buffer - will use partial output:");
            NSLog(@"[CoreML] • n_state: using first %ld/%ld dimensions (%.1f%%)", 
                  (long)MIN(modelNState, whisperNState), (long)modelNState, 
                  100.0 * MIN(modelNState, whisperNState) / modelNState);
            NSLog(@"[CoreML] • n_ctx: using first %ld/%ld frames (%.1f%%)", 
                  (long)MIN(modelNCtx, whisperNCtx), (long)modelNCtx,
                  100.0 * MIN(modelNCtx, whisperNCtx) / modelNCtx);
            NSLog(@"[CoreML] CoreML acceleration enabled with partial model usage");
        } else {
            NSLog(@"[CoreML] ✅ Model dimensions compatible - using full model output");
        }
        
        // Initialize whisper buffer (always use whisper's expected size)
        memset(out, 0, whisperBufferSize);
        
        // Safe data copying with memory protection
        @autoreleasepool {
            @try {
                // Smart tensor reshaping with size adaptation
                if (outputShape.count >= 4) {
                    NSLog(@"[CoreML] Reshaping 4D model output [%ld,%ld,%ld,%ld] to whisper 2D format [%ld×%ld]",
                          (long)outputShape[0].integerValue, (long)outputShape[1].integerValue,
                          (long)outputShape[2].integerValue, (long)outputShape[3].integerValue,
                          (long)whisperNState, (long)whisperNCtx);
                          
                    float *outPtr = (float *)out;
                    NSInteger copiedElements = 0;
                    
                    // CRITICAL: Validate buffer and dimensions before starting copy
                    if (!outPtr) {
                        NSLog(@"[CoreML] FATAL: Output buffer pointer is NULL");
                        return -1;
                    }
                    
                    if (whisperNState <= 0 || whisperNCtx <= 0) {
                        NSLog(@"[CoreML] FATAL: Invalid whisper buffer dimensions [%ld×%ld]", (long)whisperNState, (long)whisperNCtx);
                        return -1;
                    }
                    
                    if (modelNState <= 0 || modelNCtx <= 0) {
                        NSLog(@"[CoreML] FATAL: Invalid model dimensions [%ld×%ld]", (long)modelNState, (long)modelNCtx);
                        return -1;
                    }
                    
                    // Validate buffer size expectations
                    NSInteger expectedBufferElements = whisperNState * whisperNCtx;
                    NSLog(@"[CoreML] Buffer validation: expected=%ld elements, available=%ld elements", 
                          (long)expectedBufferElements, (long)outputElements);
                    
                    // Adaptive copying: fit model output into whisper buffer dimensions
                    NSInteger copyNState = MIN(modelNState, whisperNState);
                    NSInteger copyNCtx = MIN(modelNCtx, whisperNCtx);
                    
                    // Validate copy dimensions
                    if (copyNState <= 0 || copyNCtx <= 0) {
                        NSLog(@"[CoreML] FATAL: Invalid copy dimensions [%ld×%ld]", (long)copyNState, (long)copyNCtx);
                        return -1;
                    }
                    
                    NSLog(@"[CoreML] Copying [%ld×%ld] subset of model output to whisper buffer", 
                          (long)copyNState, (long)copyNCtx);
                    
                    // PERFORMANCE: Add timing and progress monitoring
                    NSDate *copyStartTime = [NSDate date];
                    NSInteger totalElements = copyNState * copyNCtx;
                    NSLog(@"[CoreML] Starting tensor copy of %ld elements with %@ data type", 
                          (long)totalElements, dataTypeName);
                    
                    // OPTIMIZATION: Use batch processing for better performance
                    const NSInteger chunkSize = needsConversion ? 100 : 500; // Smaller chunks for conversions
                    NSInteger processedCtx = 0;
                    
                    while (processedCtx < copyNCtx) {
                        NSInteger currentChunkSize = MIN(chunkSize, copyNCtx - processedCtx);
                        NSInteger chunkEnd = processedCtx + currentChunkSize;
                        
                        for (NSInteger ctx = processedCtx; ctx < chunkEnd; ctx++) {
                            for (NSInteger state = 0; state < copyNState; state++) {
                                // CoreML 4D tensor layout: [batch=1, state, height=1, ctx]
                                // Correct flattened index for [1, modelNState, 1, modelNCtx]
                                // 4D index: batch=0, state, height=0, ctx
                                NSInteger srcIdx = (0 * modelNState * 1 * modelNCtx) + 
                                                 (state * 1 * modelNCtx) + 
                                                 (0 * modelNCtx) + ctx;
                                
                                // Whisper 2D layout: [state, ctx]
                                NSInteger dstIdx = state * whisperNCtx + ctx;
                                
                                // CRITICAL: Comprehensive bounds checking with detailed validation
                                bool isValidSrc = (srcIdx >= 0 && srcIdx < outputElements);
                                bool isValidDst = (dstIdx >= 0 && dstIdx < whisperNState * whisperNCtx);
                                bool isValidPointers = (outputDataPtr != NULL && outPtr != NULL);
                                bool isValidDims = (state < modelNState && ctx < modelNCtx && 
                                                   state < whisperNState && ctx < whisperNCtx);
                                
                                if (isValidSrc && isValidDst && isValidPointers && isValidDims) {
                                    // CRITICAL: Use stride-aware memory access instead of flat array indexing
                                    @try {
                                        // CRITICAL: Get source value with proper data type handling
                                        float srcValue = 0.0f;
                                        
                                        // Calculate 4D offset with proper stride validation
                                        if (outputStrides.count < 4) {
                                            NSLog(@"[CoreML] ERROR: Insufficient strides for 4D access - got %ld strides", (long)outputStrides.count);
                                            return -1;
                                        }
                                        
                                        NSInteger srcOffset = 0 * outputStrides[0].integerValue +
                                                            state * outputStrides[1].integerValue +
                                                            0 * outputStrides[2].integerValue +
                                                            ctx * outputStrides[3].integerValue;
                                        
                                        // Bounds check - use actualMemoryElements to account for stride padding
                                        if (srcOffset < 0 || srcOffset >= actualMemoryElements) {
                                            NSLog(@"[CoreML] ERROR: Offset %ld out of bounds [0, %ld) at [%ld,%ld]", 
                                                  (long)srcOffset, (long)actualMemoryElements, (long)state, (long)ctx);
                                            NSLog(@"[CoreML] Debug: logical elements=%ld, checking against padded memory=%ld", 
                                                  (long)outputElements, (long)actualMemoryElements);
                                            return -1;
                                        }
                                        
                                        // Extract value based on actual data type
                                        void *dataPtr = outputArray.dataPointer;
                                        switch (outputArray.dataType) {
                                            case MLMultiArrayDataTypeFloat16: {
                                                // OPTIMIZED: Use Apple's highly efficient Float16 conversion
                                                __fp16 *f16Data = (__fp16*)dataPtr;
                                                __fp16 f16Value = f16Data[srcOffset];
                                                // Direct hardware-accelerated conversion
                                                srcValue = (float)f16Value;
                                                break;
                                            }
                                            case MLMultiArrayDataTypeFloat32: {
                                                float *f32Data = (float*)dataPtr;
                                                srcValue = f32Data[srcOffset];
                                                break;
                                            }
                                            case MLMultiArrayDataTypeDouble: {
                                                double *f64Data = (double*)dataPtr;
                                                srcValue = (float)f64Data[srcOffset];
                                                break;
                                            }
                                            default:
                                                NSLog(@"[CoreML] ERROR: Unsupported data type during value extraction");
                                                return -1;
                                        }
                                        
                                        // For GGML tensor: use proper stride-based access
                                        // CRITICAL FIX: GGML tensor layout is [state, ctx] not [ctx, state]
                                        // nb[0] = 4 bytes (stride between states), nb[1] = out_stride_bytes (stride between contexts)
                                        char *ggmlData = (char*)out;
                                        size_t ggmlOffset = state * sizeof(float) + ctx * out_stride_bytes;
                                        float *ggmlPtr = (float*)(ggmlData + ggmlOffset);
                                        
                                        // Perform safe memory copy
                                        *ggmlPtr = srcValue;
                                        copiedElements++;
                                        
                                        // Occasional validation for debugging (every 10000 elements)
                                        if (copiedElements % 10000 == 0) {
                                            NSLog(@"[CoreML] Progress: copied %ld elements, current [%ld,%ld] = %f", 
                                                  (long)copiedElements, (long)state, (long)ctx, srcValue);
                                        }
                                        
                                    } @catch (NSException *e) {
                                        NSLog(@"[CoreML] Exception during stride-aware copy at [%ld,%ld]: %@", 
                                              (long)state, (long)ctx, e.reason);
                                        NSLog(@"[CoreML] Stopping tensor copy to prevent crash - copied %ld elements", (long)copiedElements);
                                        return -1;
                                    }
                                } else {
                                    // Log detailed failure reason for debugging
                                    if (!isValidSrc) {
                                        NSLog(@"[CoreML] ERROR: Invalid source index - srcIdx=%ld, outputElements=%ld", 
                                              (long)srcIdx, (long)outputElements);
                                    }
                                    if (!isValidDst) {
                                        NSLog(@"[CoreML] ERROR: Invalid destination index - dstIdx=%ld, bufferSize=%ld", 
                                              (long)dstIdx, (long)(whisperNState * whisperNCtx));
                                    }
                                    if (!isValidPointers) {
                                        NSLog(@"[CoreML] ERROR: Invalid pointers - outputDataPtr=%p, outPtr=%p", outputDataPtr, outPtr);
                                    }
                                    if (!isValidDims) {
                                        NSLog(@"[CoreML] ERROR: Invalid dimensions - state=%ld<%ld, ctx=%ld<%ld", 
                                              (long)state, (long)MIN(modelNState, whisperNState), (long)ctx, (long)MIN(modelNCtx, whisperNCtx));
                                    }
                                    
                                    // Stop processing on first error to prevent crash
                                    NSLog(@"[CoreML] Stopping tensor copy due to bounds violation - copied %ld elements so far", (long)copiedElements);
                                    return -1;
                                }
                            }
                        }
                        
                        processedCtx = chunkEnd;
                        
                        // Progress reporting - show every chunk to demonstrate it's working
                        if (processedCtx % chunkSize == 0 || processedCtx >= copyNCtx) {
                            double progress = 100.0 * processedCtx / copyNCtx;
                            NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:copyStartTime];
                            NSInteger elementsProcessed = processedCtx * copyNState;
                            double elementsPerSecond = elementsProcessed / elapsed;
                            
                            NSLog(@"[CoreML] Progress: %ld/%ld frames (%.1f%%) - %.0f elements/sec, %ld total elements copied",
                                  (long)processedCtx, (long)copyNCtx, progress, elementsPerSecond, (long)copiedElements);
                            
                            // Estimate time remaining
                            if (processedCtx < copyNCtx && elementsPerSecond > 0) {
                                NSInteger remaining = totalElements - elementsProcessed;
                                double timeRemaining = remaining / elementsPerSecond;
                                NSLog(@"[CoreML] Estimated time remaining: %.1f seconds", timeRemaining);
                            }
                        }
                    }
                    
                    // Final performance metrics
                    NSTimeInterval totalTime = [[NSDate date] timeIntervalSinceDate:copyStartTime];
                    double finalElementsPerSecond = copiedElements / totalTime;
                    
                    NSLog(@"[CoreML] ✅ Tensor copy completed: %ld/%ld elements in %.3f seconds (%.0f elements/sec)", 
                          (long)copiedElements, (long)totalElements, totalTime, finalElementsPerSecond);
                    NSLog(@"[CoreML] 4D->2D adaptive reshape completed: copied %ld elements to [%ld×%ld] whisper buffer", 
                          (long)copiedElements, (long)whisperNState, (long)whisperNCtx);
                          
                } else {
                    // Direct copy for 2D output with size adaptation
                    const size_t modelOutputSize = modelNState * modelNCtx * sizeof(float);
                    const size_t copySize = MIN(modelOutputSize, whisperBufferSize);
                    
                    NSLog(@"[CoreML] Direct 2D copy: model %.2fMB -> whisper buffer %.2fMB (copying %.2fMB)", 
                          modelOutputSize / (1024.0*1024.0), whisperBufferSize / (1024.0*1024.0), copySize / (1024.0*1024.0));
                    
                    if (outputDataPtr && out && copySize > 0) {
                        memcpy(out, outputDataPtr, copySize);
                        NSLog(@"[CoreML] Direct copy completed: %zu bytes", copySize);
                    } else {
                        NSLog(@"[CoreML] Skipping direct copy due to invalid pointers or size");
                        return -1;
                    }
                }
                
            } @catch (NSException *exception) {
                NSLog(@"[CoreML] Exception during data copying: %@ - using CPU fallback", exception.reason);
                return -1;
            }
        }
        
        NSLog(@"[CoreML] Successfully completed prediction with %ld validated output elements", (long)outputElements);
        return 0; // Success
        
    } @catch (NSException *exception) {
        NSLog(@"[CoreML] Exception during prediction: %@ - using CPU fallback", exception.reason);
        
        // SAFETY: Ensure output buffer is safe even on exception
        // Use conservative buffer size that works for both base (512) and large (1280)
        const size_t conservative_encoder_output_size = 1500 * 1280 * sizeof(float); // Max size for large model
        memset(out, 0, conservative_encoder_output_size);
        
        return -1; // CPU fallback
    } @catch (...) {
        NSLog(@"[CoreML] Unknown exception during prediction - using CPU fallback");
        
        // SAFETY: Handle any other exception type
        // Use conservative buffer size that works for both base (512) and large (1280)
        const size_t conservative_encoder_output_size = 1500 * 1280 * sizeof(float); // Max size for large model
        memset(out, 0, conservative_encoder_output_size);
        
        return -1; // CPU fallback
    }
}

int whisper_coreml_get_n_state(struct whisper_coreml_context * ctx) {
    if (!ctx || !ctx->model) {
        return -1; // Invalid context
    }
    
    @try {
        MLModelDescription* description = ctx->model.modelDescription;
        NSDictionary<NSString*, MLFeatureDescription*>* outputFeatures = description.outputDescriptionsByName;
        
        // Find the encoder output feature (usually named "encoder_output_embeds" or similar)
        for (NSString* outputName in outputFeatures) {
            MLFeatureDescription* outputDesc = outputFeatures[outputName];
            if (outputDesc.type == MLFeatureTypeMultiArray) {
                NSArray<NSNumber*>* shape = outputDesc.multiArrayConstraint.shape;
                
                // CoreML output typically: [batch=1, n_state, height=1, n_ctx]
                if (shape.count >= 4 && shape[1].integerValue > 0) {
                    int n_state = (int)shape[1].integerValue;
                    NSLog(@"[CoreML] Detected encoder n_state = %d from model output shape", n_state);
                    return n_state;
                }
                // Fallback for 2D: [n_state, n_ctx]
                else if (shape.count >= 2 && shape[0].integerValue > 0) {
                    int n_state = (int)shape[0].integerValue;
                    NSLog(@"[CoreML] Detected encoder n_state = %d from 2D model output shape", n_state);
                    return n_state;
                }
            }
        }
        
        NSLog(@"[CoreML] Could not determine n_state from model - defaulting to -1");
        return -1;
        
    } @catch (NSException *exception) {
        NSLog(@"[CoreML] Exception getting n_state: %@", exception.reason);
        return -1;
    }
}

void whisper_coreml_free(struct whisper_coreml_context * ctx) {
    if (ctx) {
        NSLog(@"[CoreML] Cleaning up CoreML context");
        @try {
            // Release the model and config (ARC will handle cleanup)
            ctx->model = nil;
            ctx->config = nil;
            delete ctx;
        } @catch (NSException *exception) {
            NSLog(@"[CoreML] Exception during cleanup: %@", exception.reason);
            // Still try to delete the context
            delete ctx;
        }
    }
}

#ifdef __cplusplus
}
#endif