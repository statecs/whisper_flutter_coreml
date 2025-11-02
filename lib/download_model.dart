/*

 */

import "dart:io";

import "package:flutter/foundation.dart";
import "package:archive/archive.dart";

/// Available whisper models
enum WhisperModel {
  // no model
  none("", 0, 0),

  /// tiny model for all languages
  tiny("tiny", 39, 200),

  /// base model for all languages
  base("base", 142, 500),

  /// small model for all languages
  small("small", 466, 750),

  /// turbo model for all languages
  turbo("large-v3-turbo", 1536, 3600),

  /// medium model for all languages
  medium("medium", 1500, 3100),

  /// large model for all languages
  largeV1("large-v1", 2900, 5800),
  largeV2("large-v2", 2900, 5800);

  const WhisperModel(this.modelName, this.memoryRequirementMB, this.nativeMemoryRequirementMB);

  /// Public name of model
  final String modelName;

  /// Model size in MB (file size)
  final int memoryRequirementMB;

  /// Native whisper.cpp memory requirement in MB (actual RAM needed during model load)
  /// This is the memory reported by whisper_model_load before CoreML optimization kicks in
  final int nativeMemoryRequirementMB;

  /// Get local path of model file
  String getPath(String dir) {
    return "$dir/ggml-$modelName.bin";
  }
  
  /// Check if this model can run with available memory (MB)
  /// [hasCoreML] indicates if CoreML hardware acceleration is available
  bool canRunWithMemory(double availableMemoryMB, {bool hasCoreML = false}) {
    if (this == WhisperModel.none) return true;

    // Use native memory requirements (actual whisper.cpp RAM usage during load)
    // Even with CoreML, the model must be loaded into memory first before optimization
    // Add small safety margin for system overhead
    final safetyMargin = hasCoreML ? 200 : 500; // MB
    final requiredMemory = nativeMemoryRequirementMB + safetyMargin;

    if (kDebugMode) {
      final mode = hasCoreML ? 'CoreML' : 'CPU';
      debugPrint('[Memory Check] Model $modelName ($mode): native requires ${nativeMemoryRequirementMB}MB + ${safetyMargin}MB margin = ${requiredMemory}MB total, available: ${availableMemoryMB.toInt()}MB');
    }

    return availableMemoryMB >= requiredMemory;
  }
  
  /// Check if CoreML model exists for this whisper model
  bool hasCoreMLModel(String modelDir) {
    if (this == WhisperModel.none) return false;
    
    final coreMLPath = '$modelDir/ggml-$modelName-encoder.mlmodelc';
    final coreMLDir = Directory(coreMLPath);
    
    return coreMLDir.existsSync() && coreMLDir.listSync().isNotEmpty;
  }
  
  /// Get the best model that can run with available memory
  /// [hasCoreML] indicates if CoreML hardware acceleration is available
  static WhisperModel getBestModelForMemory(double availableMemoryMB, {bool hasCoreML = false}) {
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
      if (model.canRunWithMemory(availableMemoryMB, hasCoreML: hasCoreML)) {
        if (kDebugMode) {
          final mode = hasCoreML ? 'CoreML' : 'CPU';
          debugPrint('[Memory Selection] Selected model: ${model.modelName} ($mode, requires ${model.memoryRequirementMB}MB)');
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

/// Callback for download progress updates
/// [progress] is a value between 0.0 and 1.0
/// [downloadedMB] is the amount downloaded in megabytes
/// [totalMB] is the total size in megabytes
typedef DownloadProgressCallback = void Function(double progress, double downloadedMB, double totalMB);

/// Download [model] to [destinationPath]
/// Also attempts to download CoreML model for hardware acceleration if available
/// [onProgress] is an optional callback for monitoring download progress
Future<String> downloadModel(
    {required WhisperModel model,
    required String destinationPath,
    String? downloadHost,
    bool downloadCoreML = true,
    bool skipBinDownload = false,
    DownloadProgressCallback? onProgress}) async {
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
      onProgress: onProgress,
    );
  }
  
  return file.path;
}

/// Download CoreML model for hardware acceleration (iOS/macOS only)
Future<void> _downloadCoreMLModel({
  required WhisperModel model,
  required String destinationPath,
  String? downloadHost,
  DownloadProgressCallback? onProgress,
}) async {
  if (model == WhisperModel.none) return;

  final coreMLFileName = 'ggml-${model.modelName}-encoder.mlmodelc';
  final coreMLDir = Directory('$destinationPath/$coreMLFileName');
  // Add timestamp to prevent race conditions with concurrent downloads
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final coreMLTempDir = Directory('$destinationPath/.$coreMLFileName.tmp.$timestamp');
  
  // Check if CoreML model already exists and is valid
  if (coreMLDir.existsSync() && coreMLDir.listSync().isNotEmpty) {
    if (kDebugMode) {
      debugPrint('[CoreML] Model already exists: ${coreMLDir.path}');
    }
    return;
  }
  
  // Clean up any partial downloads (including from previous attempts with different timestamps)
  final destinationDir = Directory(destinationPath);
  if (destinationDir.existsSync()) {
    final tempDirs = destinationDir.listSync()
        .whereType<Directory>()
        .where((dir) => dir.path.contains('.$coreMLFileName.tmp'));

    for (final tempDir in tempDirs) {
      try {
        tempDir.deleteSync(recursive: true);
        if (kDebugMode) {
          debugPrint('[CoreML] Cleaned up old temp directory: ${tempDir.path}');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[CoreML] Warning: Failed to clean up old temp directory: $e');
        }
      }
    }
  }

  if (coreMLDir.existsSync()) {
    try {
      coreMLDir.deleteSync(recursive: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CoreML] Warning: Failed to clean up partial download: $e');
      }
    }
  }
  
  try {
    // Check available disk space before downloading
    final destinationDir = Directory(destinationPath);
    if (destinationDir.existsSync()) {
      // Estimate CoreML model size: tiny/base ~40MB, small ~150MB, medium/large ~500MB
      final estimatedSizeMB = model == WhisperModel.tiny || model == WhisperModel.base ? 40
          : model == WhisperModel.small ? 150
          : 500;

      // Get free space using df command (skip on iOS where Process.run is not supported)
      if (!Platform.isIOS) {
        try {
          final result = await Process.run('df', ['-k', destinationPath]);
          if (result.exitCode == 0) {
            final lines = (result.stdout as String).split('\n');
            if (lines.length > 1) {
              final parts = lines[1].split(RegExp(r'\s+'));
              if (parts.length >= 4) {
                final freeSpaceKB = int.tryParse(parts[3]) ?? 0;
                final freeSpaceMB = freeSpaceKB / 1024;

                if (kDebugMode) {
                  debugPrint('[CoreML] Available disk space: ${freeSpaceMB.toStringAsFixed(1)}MB, estimated model size: ${estimatedSizeMB}MB');
                }

                if (freeSpaceMB < estimatedSizeMB * 2) { // 2x safety margin
                  if (kDebugMode) {
                    debugPrint('[CoreML] Insufficient disk space for ${model.modelName} model (need ${estimatedSizeMB * 2}MB, have ${freeSpaceMB.toStringAsFixed(1)}MB)');
                    debugPrint('[CoreML] CPU fallback will be used');
                  }
                  return;
                }
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[CoreML] Warning: Could not check disk space: $e (continuing anyway)');
          }
        }
      }
    }

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

    // Download zip file to disk first to avoid memory exhaustion
    final zipTempFile = File('$destinationPath/.${coreMLFileName}.zip.$timestamp');
    final contentLength = response.contentLength;
    int downloadedBytes = 0;
    int lastReportedProgress = -1;

    try {
      final sink = zipTempFile.openWrite();

      await for (var chunk in response) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (contentLength > 0) {
          final progressPercent = (downloadedBytes / contentLength * 100).round();
          final downloadedMB = downloadedBytes / 1024 / 1024;
          final totalMB = contentLength / 1024 / 1024;

          // Call progress callback if provided
          if (onProgress != null) {
            onProgress(downloadedBytes / contentLength, downloadedMB, totalMB);
          }

          // Report progress less frequently to reduce log spam
          if (kDebugMode) {
            if (progressPercent >= lastReportedProgress + 10 || progressPercent == 100) {
              debugPrint('[CoreML] Download progress: $progressPercent% (${downloadedMB.toStringAsFixed(1)}MB/${totalMB.toStringAsFixed(1)}MB)');
              lastReportedProgress = progressPercent;
            }
          }
        }
      }

      await sink.flush();
      await sink.close();

      // Validate ZIP file download
      final zipFileSize = zipTempFile.lengthSync();
      if (kDebugMode) {
        debugPrint('[CoreML] Download complete: ${(zipFileSize / 1024 / 1024).toStringAsFixed(1)}MB');
      }

      // Verify download integrity
      if (contentLength > 0 && downloadedBytes != contentLength) {
        if (kDebugMode) {
          debugPrint('[CoreML] WARNING: Downloaded $downloadedBytes bytes but expected $contentLength bytes');
        }
        throw Exception('[CoreML] Incomplete download: got $downloadedBytes bytes, expected $contentLength');
      }

      if (zipFileSize < 1024 * 100) { // Less than 100KB is suspiciously small
        if (kDebugMode) {
          debugPrint('[CoreML] WARNING: ZIP file is suspiciously small (${zipFileSize} bytes)');
        }
        throw Exception('[CoreML] ZIP file too small, possibly corrupted');
      }

      if (kDebugMode) {
        debugPrint('[CoreML] Extracting ${model.modelName} CoreML model...');
      }
    } catch (e) {
      // Clean up zip file on download error
      try {
        if (zipTempFile.existsSync()) {
          zipTempFile.deleteSync();
        }
      } catch (_) {}
      rethrow;
    }

    // Extract ZIP file using platform-optimized method to minimize memory usage
    // Create temporary directory for extraction
    if (!coreMLTempDir.existsSync()) {
      coreMLTempDir.createSync(recursive: true);
    }

    bool extractionSuccessful = false;
    int extractedFiles = 0;

    // Try native unzip first on macOS (avoids loading entire ZIP into Dart memory)
    if (Platform.isMacOS) {
      try {
        if (kDebugMode) {
          debugPrint('[CoreML] Using native unzip for extraction (memory-efficient)');
        }

        final result = await Process.run(
          'unzip',
          ['-q', '-o', zipTempFile.path, '-d', coreMLTempDir.path],
        );

        if (result.exitCode == 0) {
          extractionSuccessful = true;
          // Count extracted files
          extractedFiles = coreMLTempDir.listSync(recursive: true).whereType<File>().length;

          if (kDebugMode) {
            debugPrint('[CoreML] Native unzip successful: $extractedFiles files extracted');
          }
        } else {
          if (kDebugMode) {
            debugPrint('[CoreML] Native unzip failed (exit ${result.exitCode}), falling back to Dart extraction');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[CoreML] Native unzip unavailable: $e, falling back to Dart extraction');
        }
      }
    }

    // Fallback to Dart-based extraction if native method unavailable or failed
    if (!extractionSuccessful) {
      try {
        if (kDebugMode) {
          debugPrint('[CoreML] Using Dart-based ZIP extraction');
        }

        final zipBytes = zipTempFile.readAsBytesSync();
        final archive = ZipDecoder().decodeBytes(zipBytes);

        // Extract all files to temporary directory
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
            // Clean up on extraction failure
            if (coreMLTempDir.existsSync()) {
              try {
                coreMLTempDir.deleteSync(recursive: true);
              } catch (cleanupError) {
                if (kDebugMode) {
                  debugPrint('[CoreML] Warning: Failed to clean up after extraction error: $cleanupError');
                }
              }
            }
            throw Exception('[CoreML] Failed to extract ${file.name}: $e');
          }
        }

        extractionSuccessful = true;

        if (kDebugMode) {
          debugPrint('[CoreML] Dart extraction completed: $extractedFiles files');
        }
      } catch (e) {
        // Clean up zip file and rethrow
        try {
          if (zipTempFile.existsSync()) {
            zipTempFile.deleteSync();
          }
        } catch (_) {}
        rethrow;
      }
    }

    // Clean up zip file after successful extraction
    try {
      if (zipTempFile.existsSync()) {
        zipTempFile.deleteSync();
        if (kDebugMode) {
          debugPrint('[CoreML] Cleaned up temp zip file');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[CoreML] Warning: Failed to clean up temp zip file: $e');
      }
    }

    if (kDebugMode) {
      debugPrint('[CoreML] Extracted $extractedFiles files for ${model.modelName} CoreML model');
    }

    // Validate the extraction by checking for required files
    // Note: .mlmodelc is a compiled CoreML package (directory structure)
    final tempFiles = coreMLTempDir.listSync(recursive: true);
    final fileCount = tempFiles.whereType<File>().length;

    if (tempFiles.isEmpty) {
      coreMLTempDir.deleteSync(recursive: true);
      throw Exception('[CoreML] Extracted model directory is empty for ${model.modelName}');
    }

    // Check for required CoreML files
    final hasMetadata = tempFiles.any((f) => f.path.endsWith('metadata.json'));
    final hasCoreMLData = tempFiles.any((f) => f.path.endsWith('coremldata.bin'));
    final hasModelMil = tempFiles.any((f) => f.path.endsWith('model.mil'));

    if (kDebugMode) {
      debugPrint('[CoreML] Extracted $fileCount files for ${model.modelName} CoreML model');
      debugPrint('[CoreML] Validation - metadata.json: $hasMetadata, coremldata.bin: $hasCoreMLData, model.mil: $hasModelMil');
    }

    // Validate presence of essential CoreML files
    if (!hasMetadata || !hasCoreMLData || !hasModelMil) {
      if (kDebugMode) {
        debugPrint('[CoreML] ERROR: Missing required CoreML files');
        debugPrint('[CoreML] Files found: ${tempFiles.map((f) => f.path.split('/').last).take(10).join(', ')}...');
      }
      coreMLTempDir.deleteSync(recursive: true);
      throw Exception('[CoreML] Missing required CoreML files - metadata:$hasMetadata, coremldata:$hasCoreMLData, model.mil:$hasModelMil');
    }

    if (kDebugMode) {
      debugPrint('[CoreML] Validation passed: All required CoreML files present ($fileCount total files)');
    }
    
    // Atomically move from temp to final location
    try {
      coreMLTempDir.renameSync(coreMLDir.path);
    } catch (e) {
      // Clean up on move failure
      if (coreMLTempDir.existsSync()) {
        try {
          coreMLTempDir.deleteSync(recursive: true);
        } catch (cleanupError) {
          if (kDebugMode) {
            debugPrint('[CoreML] Warning: Failed to clean up after move failure: $cleanupError');
          }
        }
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
      } catch (cleanupError) {
        if (kDebugMode) {
          debugPrint('[CoreML] Warning: Failed to clean up temp directory after error: $cleanupError');
        }
      }
    }
    if (coreMLDir.existsSync()) {
      try {
        coreMLDir.deleteSync(recursive: true);
      } catch (cleanupError) {
        if (kDebugMode) {
          debugPrint('[CoreML] Warning: Failed to clean up partial download after error: $cleanupError');
        }
      }
    }
  }
}
