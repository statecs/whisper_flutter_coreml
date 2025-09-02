//
// whisper-encoder.h
//
// Created by Claude Code for whisper_flutter_coreml
//

#pragma once

#include <stddef.h>  // For size_t

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

// Encode audio features using CoreML with explicit buffer dimensions and strides
int whisper_coreml_encode_with_dims(
    struct whisper_coreml_context * ctx,
    float                         * mel,
    float                         * out,
    int                             out_n_state,
    int                             out_n_ctx,
    size_t                          out_stride_bytes);

// Get the encoder n_state dimension (512 for base, 1280 for large)
int whisper_coreml_get_n_state(struct whisper_coreml_context * ctx);

// Free CoreML context
void whisper_coreml_free(struct whisper_coreml_context * ctx);

// Memory management functions for crash prevention
size_t whisper_coreml_get_available_memory(void);
bool whisper_coreml_check_memory_sufficient(size_t required_bytes);
void whisper_coreml_handle_memory_pressure(void);
bool whisper_coreml_should_fallback_to_cpu(size_t buffer_size);

#ifdef __cplusplus
}
#endif