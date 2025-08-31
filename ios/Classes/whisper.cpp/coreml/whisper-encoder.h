//
// whisper-encoder.h
//
// Created by Claude Code for whisper_flutter_coreml
//

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

struct whisper_coreml_context;

// Initialize CoreML context for Whisper encoder
struct whisper_coreml_context * whisper_coreml_init(const char * path_model);

// Encode audio features using CoreML
int whisper_coreml_encode(
    struct whisper_coreml_context * ctx,
    float                         * mel,
    float                         * out);

// Encode audio features using CoreML with explicit buffer dimensions
int whisper_coreml_encode_with_dims(
    struct whisper_coreml_context * ctx,
    float                         * mel,
    float                         * out,
    int                             out_n_state,
    int                             out_n_ctx);

// Get the encoder n_state dimension (512 for base, 1280 for large)
int whisper_coreml_get_n_state(struct whisper_coreml_context * ctx);

// Free CoreML context
void whisper_coreml_free(struct whisper_coreml_context * ctx);

#ifdef __cplusplus
}
#endif