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
        
        // Copy mel data to MLMultiArray
        // Note: mel is expected to be [3000, 80] = [2*n_ctx, n_mels]
        // But CoreML model might expect different layout
        float *inputData = (float *)inputArray.dataPointer;
        memcpy(inputData, mel, totalElements * sizeof(float));
        
        NSLog(@"[CoreML] Created input array with %ld elements", (long)totalElements);
        
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
        
        // Copy output data to result buffer
        // Expected output: [n_state, n_ctx] where n_ctx=1500, n_state varies by model
        float *outputData = (float *)outputArray.dataPointer;
        const size_t outputSize = outputElements * sizeof(float);
        
        // Initialize output buffer to prevent crashes
        memset(out, 0, outputSize);
        memcpy(out, outputData, outputSize);
        
        NSLog(@"[CoreML] Successfully completed prediction with %ld output elements", (long)outputElements);
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