/*
 * Copyright (c) 田梓萱[小草林] 2021-2024.
 * All Rights Reserved.
 * All codes are protected by China's regulations on the protection of computer software, and infringement must be investigated.
 * 版权所有 (c) 田梓萱[小草林] 2021-2024.
 * 所有代码均受中国《计算机软件保护条例》保护，侵权必究.
 */

import "dart:io";
import "dart:typed_data";

import "package:flutter/foundation.dart";
import "package:archive/archive.dart";

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
  
  /// Check if CoreML model exists for this whisper model
  bool hasCoreMLModel(String modelDir) {
    if (this == WhisperModel.none) return false;
    
    final coreMLPath = '$modelDir/ggml-$modelName-encoder.mlmodelc';
    final coreMLDir = Directory(coreMLPath);
    
    return coreMLDir.existsSync() && coreMLDir.listSync().isNotEmpty;
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
/// Also attempts to download CoreML model for hardware acceleration if available
Future<String> downloadModel(
    {required WhisperModel model,
    required String destinationPath,
    String? downloadHost,
    bool downloadCoreML = true,
    bool skipBinDownload = false}) async {
  final file = File("$destinationPath/ggml-${model.modelName}.bin");
  
  if (!skipBinDownload) {
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

    final raf = file.openSync(mode: FileMode.write);

    await for (var chunk in response) {
      raf.writeFromSync(chunk);
    }

    await raf.close();

    if (kDebugMode) {
      debugPrint("Download complete. Path = ${file.path}");
    }
  } else {
    if (kDebugMode) {
      debugPrint("Skipping .bin download for ${model.modelName} - file already exists");
    }
  }
  
  // Attempt to download CoreML model for hardware acceleration
  if (downloadCoreML && (Platform.isIOS || Platform.isMacOS)) {
    await _downloadCoreMLModel(
      model: model,
      destinationPath: destinationPath,
      downloadHost: downloadHost,
    );
  }
  
  return file.path;
}

/// Download CoreML model for hardware acceleration (iOS/macOS only)
Future<void> _downloadCoreMLModel({
  required WhisperModel model,
  required String destinationPath,
  String? downloadHost,
}) async {
  if (model == WhisperModel.none) return;
  
  final coreMLFileName = 'ggml-${model.modelName}-encoder.mlmodelc';
  final coreMLDir = Directory('$destinationPath/$coreMLFileName');
  final coreMLTempDir = Directory('$destinationPath/.$coreMLFileName.tmp');
  
  // Check if CoreML model already exists and is valid
  if (coreMLDir.existsSync() && coreMLDir.listSync().isNotEmpty) {
    if (kDebugMode) {
      debugPrint('[CoreML] Model already exists: ${coreMLDir.path}');
    }
    return;
  }
  
  // Clean up any partial downloads
  if (coreMLTempDir.existsSync()) {
    try {
      coreMLTempDir.deleteSync(recursive: true);
    } catch (_) {}
  }
  if (coreMLDir.existsSync()) {
    try {
      coreMLDir.deleteSync(recursive: true);
    } catch (_) {}
  }
  
  try {
    if (kDebugMode) {
      debugPrint('[CoreML] Downloading ${model.modelName} CoreML model...');
    }
    
    final httpClient = HttpClient();
    
    Uri coreMLUri;
    if (downloadHost == null || downloadHost.isEmpty) {
      coreMLUri = Uri.parse(
        'https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-${model.modelName}-encoder.mlmodelc.zip',
      );
    } else {
      coreMLUri = Uri.parse(
        '$downloadHost/ggml-${model.modelName}-encoder.mlmodelc.zip',
      );
    }
    
    final request = await httpClient.getUrl(coreMLUri);
    final response = await request.close();
    
    if (response.statusCode != 200) {
      if (kDebugMode) {
        debugPrint('[CoreML] Model not available for ${model.modelName} (HTTP ${response.statusCode})');
        debugPrint('[CoreML] CPU fallback will be used for ${model.modelName}');
      }
      return;
    }
    
    // Download zip file to memory with progress tracking
    final List<int> zipBytes = [];
    final contentLength = response.contentLength;
    int downloadedBytes = 0;
    int lastReportedProgress = -1;
    
    await for (var chunk in response) {
      zipBytes.addAll(chunk);
      downloadedBytes += chunk.length;
      
      // Report progress less frequently to reduce log spam
      if (kDebugMode && contentLength > 0) {
        final progress = (downloadedBytes / contentLength * 100).round();
        if (progress >= lastReportedProgress + 10 || progress == 100) {
          debugPrint('[CoreML] Download progress: $progress% (${(downloadedBytes / 1024 / 1024).toStringAsFixed(1)}MB/${(contentLength / 1024 / 1024).toStringAsFixed(1)}MB)');
          lastReportedProgress = progress;
        }
      }
    }
    
    if (kDebugMode) {
      debugPrint('[CoreML] Download complete, extracting ${model.modelName} CoreML model...');
    }
    
    // Extract zip file to temporary directory first (atomic operation)
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(Uint8List.fromList(zipBytes));
    } catch (e) {
      throw Exception('[CoreML] Failed to decode zip file for ${model.modelName}: $e');
    }
    
    // Create temporary directory for extraction
    if (!coreMLTempDir.existsSync()) {
      coreMLTempDir.createSync(recursive: true);
    }
    
    // Extract all files to temporary directory
    int extractedFiles = 0;
    for (final file in archive) {
      try {
        final filename = file.name;
        final filePath = '${coreMLTempDir.path}/$filename';
        
        if (file.isFile) {
          final data = file.content as List<int>;
          File(filePath)..createSync(recursive: true)..writeAsBytesSync(data);
          extractedFiles++;
        } else {
          Directory(filePath).createSync(recursive: true);
        }
      } catch (e) {
        // Clean up temp directory on extraction failure
        if (coreMLTempDir.existsSync()) {
          try {
            coreMLTempDir.deleteSync(recursive: true);
          } catch (_) {}
        }
        throw Exception('[CoreML] Failed to extract ${file.name}: $e');
      }
    }
    
    if (kDebugMode) {
      debugPrint('[CoreML] Extracted $extractedFiles files for ${model.modelName} CoreML model');
    }
    
    // Validate the extraction by checking for required CoreML files
    final tempFiles = coreMLTempDir.listSync(recursive: true);
    if (tempFiles.isEmpty) {
      coreMLTempDir.deleteSync(recursive: true);
      throw Exception('[CoreML] Extracted model directory is empty for ${model.modelName}');
    }
    
    // Atomically move from temp to final location
    try {
      coreMLTempDir.renameSync(coreMLDir.path);
    } catch (e) {
      // Clean up on move failure
      if (coreMLTempDir.existsSync()) {
        try {
          coreMLTempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
      throw Exception('[CoreML] Failed to move CoreML model to final location: $e');
    }
    
    if (kDebugMode) {
      debugPrint('[CoreML] Successfully downloaded and extracted ${model.modelName} CoreML model to ${coreMLDir.path}');
      debugPrint('[CoreML] CoreML model ready for hardware acceleration');
    }
    
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[CoreML] Failed to download CoreML model for ${model.modelName}: $e');
      debugPrint('[CoreML] CPU fallback will be used');
    }
    
    // Clean up any partial downloads or temp directories
    if (coreMLTempDir.existsSync()) {
      try {
        coreMLTempDir.deleteSync(recursive: true);
      } catch (_) {}
    }
    if (coreMLDir.existsSync()) {
      try {
        coreMLDir.deleteSync(recursive: true);
      } catch (_) {}
    }
  }
}
