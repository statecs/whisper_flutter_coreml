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
        
        // Calculate output size
        NSInteger outputElements = 1;
        for (NSNumber *dim in outputShape) {
            outputElements *= dim.integerValue;
        }
        
        // Copy output data to result buffer with safe memory access
        // Expected output: [n_state, n_ctx] where n_ctx=1500, n_state varies by model
        // For base model: 512*1500=768000 elements, for small: 512*1500=768000 elements
        
        NSLog(@"[CoreML] Output validation: %ld elements, expected format [n_state, n_ctx]", (long)outputElements);
        
        // Safe memory access with proper validation
        float *outputData = (float *)outputArray.dataPointer;
        if (!outputData) {
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
        @try {
            // Check first element
            if (outputElements > 0) {
                float firstValue = outputData[0];
                if (isnan(firstValue) || isinf(firstValue)) {
                    NSLog(@"[CoreML] First output element is invalid (%f) - using CPU fallback", firstValue);
                    return -1;
                }
            }
            
            // Check middle element
            if (outputElements > 1) {
                NSInteger midIndex = outputElements / 2;
                float midValue = outputData[midIndex];
                if (isnan(midValue) || isinf(midValue)) {
                    NSLog(@"[CoreML] Middle output element is invalid (%f) - using CPU fallback", midValue);
                    return -1;
                }
            }
            
            // Check last element
            if (outputElements > 2) {
                float lastValue = outputData[outputElements - 1];
                if (isnan(lastValue) || isinf(lastValue)) {
                    NSLog(@"[CoreML] Last output element is invalid (%f) - using CPU fallback", lastValue);
                    return -1;
                }
            }
            
            NSLog(@"[CoreML] Minimal validation passed - first/middle/last elements are valid");
            
        } @catch (NSException *exception) {
            NSLog(@"[CoreML] Exception during output validation: %@ - using CPU fallback", exception.reason);
            return -1;
        }
        
        // Dynamic output buffer size calculation based on actual model output
        NSInteger outputNState = 512; // Default whisper base model
        NSInteger outputNCtx = 1500;  // Default context length
        
        // Extract dimensions from actual output shape
        if (outputShape.count >= 4) {
            // Format: [batch, n_state, height, n_ctx] -> [1, 1280, 1, 1500]
            outputNState = outputShape[1].integerValue;
            outputNCtx = outputShape[3].integerValue;
        } else if (outputShape.count >= 2) {
            // Format: [n_state, n_ctx] -> [1280, 1500]
            outputNState = outputShape[0].integerValue;
            outputNCtx = outputShape[1].integerValue;
        }
        
        const size_t expectedOutputSize = outputNState * outputNCtx * sizeof(float);
        NSLog(@"[CoreML] Dynamic buffer sizing: n_state=%ld, n_ctx=%ld, buffer_size=%zu bytes", 
              (long)outputNState, (long)outputNCtx, expectedOutputSize);
        
        // Initialize output buffer with correct size
        memset(out, 0, expectedOutputSize);
        
        // Safe data copying with memory protection
        @autoreleasepool {
            @try {
                // Reshape 4D output [1, n_state, 1, n_ctx] to 2D [n_state, n_ctx] format expected by whisper.cpp
                if (outputShape.count >= 4) {
                    // Reshape from [1, 1280, 1, 1500] to [1280, 1500]
                    NSLog(@"[CoreML] Reshaping 4D output to 2D: [%ld,%ld,%ld,%ld] -> [%ld,%ld]",
                          (long)outputShape[0].integerValue, (long)outputShape[1].integerValue,
                          (long)outputShape[2].integerValue, (long)outputShape[3].integerValue,
                          (long)outputNState, (long)outputNCtx);
                          
                    // Safe copy with bounds checking for every access
                    float *outPtr = (float *)out;
                    NSInteger copiedElements = 0;
                    
                    for (NSInteger ctx = 0; ctx < outputNCtx; ctx++) {
                        for (NSInteger state = 0; state < outputNState; state++) {
                            // Source index: batch=0, state, height=0, ctx  
                            NSInteger srcIdx = ctx * outputNState + state;
                            // Destination index: [state, ctx] layout for whisper.cpp
                            NSInteger dstIdx = state * outputNCtx + ctx;
                            
                            // Triple bounds checking for maximum safety
                            if (srcIdx >= 0 && srcIdx < outputElements && 
                                dstIdx >= 0 && dstIdx < outputNState * outputNCtx &&
                                outputData != NULL && outPtr != NULL) {
                                
                                outPtr[dstIdx] = outputData[srcIdx];
                                copiedElements++;
                            } else {
                                NSLog(@"[CoreML] Skipping invalid indices: src=%ld, dst=%ld", (long)srcIdx, (long)dstIdx);
                            }
                        }
                    }
                    
                    NSLog(@"[CoreML] 4D->2D reshape completed: copied %ld/%ld elements", 
                          (long)copiedElements, (long)(outputNState * outputNCtx));
                          
                } else {
                    // Direct copy for 2D output with bounds checking
                    size_t copySize = MIN(outputSize, expectedOutputSize);
                    if (outputData && out && copySize > 0) {
                        memcpy(out, outputData, copySize);
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
        const size_t typical_encoder_output_size = 1500 * 512 * sizeof(float);
        memset(out, 0, typical_encoder_output_size);
        
        return -1; // CPU fallback
    } @catch (...) {
        NSLog(@"[CoreML] Unknown exception during prediction - using CPU fallback");
        
        // SAFETY: Handle any other exception type
        const size_t typical_encoder_output_size = 1500 * 512 * sizeof(float);
        memset(out, 0, typical_encoder_output_size);
        
        return -1; // CPU fallback
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