/*
 * Copyright (c) 田梓萱[小草林] 2021-2024.
 * All Rights Reserved.
 * All codes are protected by China's regulations on the protection of computer software, and infringement must be investigated.
 * 版权所有 (c) 田梓萱[小草林] 2021-2024.
 * 所有代码均受中国《计算机软件保护条例》保护，侵权必究.
 */

import "dart:io";

import "package:flutter/foundation.dart";

/// Available whisper models
enum WhisperModel {
  // no model
  none("", 0),

  /// tiny model for all languages
  tiny("tiny", 39),

  /// base model for all languages
  base("base", 142),

  /// small model for all languages
  small("small", 466),

  /// turbo model for all languages  
  turbo("large-v3-turbo", 1536),

  /// medium model for all languages
  medium("medium", 1500),

  /// large model for all languages
  largeV1("large-v1", 2900),
  largeV2("large-v2", 2900);

  const WhisperModel(this.modelName, this.memoryRequirementMB);

  /// Public name of model
  final String modelName;
  
  /// Memory requirement in MB (including working memory overhead)
  final int memoryRequirementMB;

  /// Get local path of model file
  String getPath(String dir) {
    return "$dir/ggml-$modelName.bin";
  }
  
  /// Check if this model can run with available memory (MB)
  bool canRunWithMemory(double availableMemoryMB) {
    if (this == WhisperModel.none) return true;
    
    // Use 3x safety factor to account for:
    // 1. Model loading overhead
    // 2. Input/output buffers
    // 3. System memory pressure protection
    final requiredWithSafety = memoryRequirementMB * 3.0;
    
    if (kDebugMode) {
      debugPrint('[Memory Check] Model ${modelName}: requires ${memoryRequirementMB}MB (${requiredWithSafety.toInt()}MB with 3x safety), available: ${availableMemoryMB.toInt()}MB');
    }
    
    return availableMemoryMB >= requiredWithSafety;
  }
  
  /// Get the best model that can run with available memory
  static WhisperModel getBestModelForMemory(double availableMemoryMB) {
    // Try models in order of preference (quality)
    final modelsInPreferenceOrder = [
      WhisperModel.turbo,
      WhisperModel.largeV2, 
      WhisperModel.largeV1,
      WhisperModel.medium,
      WhisperModel.small,
      WhisperModel.base,
      WhisperModel.tiny,
    ];
    
    for (final model in modelsInPreferenceOrder) {
      if (model.canRunWithMemory(availableMemoryMB)) {
        if (kDebugMode) {
          debugPrint('[Memory Selection] Selected model: ${model.modelName} (requires ${model.memoryRequirementMB}MB)');
        }
        return model;
      }
    }
    
    if (kDebugMode) {
      debugPrint('[Memory Selection] No model fits in ${availableMemoryMB.toInt()}MB - using tiny as last resort');
    }
    return WhisperModel.tiny; // Fallback to smallest model
  }
}

/// Download [model] to [destinationPath]
Future<String> downloadModel(
    {required WhisperModel model,
    required String destinationPath,
    String? downloadHost}) async {
  if (kDebugMode) {
    debugPrint("Download model ${model.modelName}");
  }
  final httpClient = HttpClient();

  Uri modelUri;

  if (downloadHost == null || downloadHost.isEmpty) {
    /// Huggingface url to download model
    modelUri = Uri.parse(
      "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${model.modelName}.bin",
    );
  } else {
    modelUri = Uri.parse(
      "$downloadHost/ggml-${model.modelName}.bin",
    );
  }

  final request = await httpClient.getUrl(
    modelUri,
  );

  final response = await request.close();

  final file = File("$destinationPath/ggml-${model.modelName}.bin");
  final raf = file.openSync(mode: FileMode.write);

  await for (var chunk in response) {
    raf.writeFromSync(chunk);
  }

  await raf.close();

  if (kDebugMode) {
    debugPrint("Download Down . Path = ${file.path}");
  }
  return file.path;
}
