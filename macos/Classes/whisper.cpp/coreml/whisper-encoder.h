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

// Free CoreML context
void whisper_coreml_free(struct whisper_coreml_context * ctx);

#ifdef __cplusplus
}
#endif