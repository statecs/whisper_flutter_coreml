//
// whisper-encoder.mm
//
// Created by Claude Code for whisper_flutter_coreml
//

#import "whisper-encoder.h"

#import <CoreML/CoreML.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

struct whisper_coreml_context {
    MLModel * model;
    MLModelConfiguration * config;
};

struct whisper_coreml_context * whisper_coreml_init(const char * path_model) {
    NSString *modelPath = [NSString stringWithUTF8String:path_model];
    
    // Check if model file exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:modelPath]) {
        NSLog(@"CoreML model file not found at: %@", modelPath);
        return nullptr;
    }
    
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    
    // Create model configuration
    MLModelConfiguration *config = [[MLModelConfiguration alloc] init];
    config.computeUnits = MLComputeUnitsAll; // Use all available compute units including ANE
    
    NSError *error = nil;
    MLModel *model = [MLModel modelWithContentsOfURL:modelURL configuration:config error:&error];
    
    if (!model || error) {
        NSLog(@"Failed to load CoreML model: %@", error ? error.localizedDescription : @"Unknown error");
        return nullptr;
    }
    
    whisper_coreml_context *ctx = new whisper_coreml_context();
    ctx->model = model;
    ctx->config = config;
    
    return ctx;
}

int whisper_coreml_encode(
    struct whisper_coreml_context * ctx,
    float                         * mel,
    float                         * out) {
    
    if (!ctx || !ctx->model) {
        return -1;
    }
    
    @try {
        // For this implementation, we need to know the input/output dimensions
        // This is a placeholder implementation that should be customized
        // based on the specific model architecture
        
        // Note: The actual implementation would need to:
        // 1. Create MLMultiArray from the mel spectrogram input
        // 2. Run prediction using the CoreML model
        // 3. Extract the output and copy to the out buffer
        
        NSLog(@"CoreML encoder prediction not yet implemented - falling back to CPU");
        return -1; // Fall back to CPU implementation
        
    } @catch (NSException *exception) {
        NSLog(@"CoreML prediction failed: %@", exception.reason);
        return -1;
    }
}

void whisper_coreml_free(struct whisper_coreml_context * ctx) {
    if (ctx) {
        delete ctx;
    }
}

#ifdef __cplusplus
}
#endif