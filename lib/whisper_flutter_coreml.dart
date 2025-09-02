import "dart:convert";
import "dart:ffi";
import "dart:io";
import "dart:isolate";

import "package:ffi/ffi.dart";
import "package:flutter/foundation.dart";
import "package:path_provider/path_provider.dart";
import "package:whisper_flutter_coreml/bean/_models.dart";
import "package:whisper_flutter_coreml/bean/whisper_dto.dart";
import "package:whisper_flutter_coreml/download_model.dart";
import "package:whisper_flutter_coreml/whisper_bindings_generated.dart";

export "package:whisper_flutter_coreml/bean/_models.dart";
export "package:whisper_flutter_coreml/download_model.dart" show WhisperModel;

/// Entry point of whisper_flutter_plus
class Whisper {
  /// [model] is required
  /// [modelDir] is path where downloaded model will be stored.
  /// Default to library directory
  const Whisper({required this.model, this.modelDir, this.downloadHost});

  /// model used for transcription
  final WhisperModel model;

  /// override of model storage path
  final String? modelDir;

  // override of model download host
  final String? downloadHost;

  /// Get available memory in MB (iOS only)
  Future<double> _getAvailableMemoryMB() async {
    if (!Platform.isIOS) return 4096.0; // Assume 4GB on non-iOS
    
    try {
      final Map<String, dynamic> result = await _request(
        whisperRequest: const MemoryCheckRequest(),
      );
      
      final WhisperMemoryStatusResponse response = WhisperMemoryStatusResponse.fromJson(result);
      
      if (kDebugMode) {
        debugPrint('[Whisper Memory] Available: ${response.availableMb.toStringAsFixed(1)} MB');
      }
      
      return response.availableMb;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Whisper Memory] Error checking memory: $e - assuming 2GB available');
      }
      return 2048.0; // Conservative fallback
    }
  }
  
  /// Select the best model that can run with available memory
  Future<WhisperModel> _selectOptimalModel(WhisperModel requestedModel) async {
    final double availableMemoryMB = await _getAvailableMemoryMB();
    
    // First check if the requested model can run
    if (requestedModel.canRunWithMemory(availableMemoryMB)) {
      if (kDebugMode) {
        debugPrint('[Model Selection] Requested model ${requestedModel.modelName} can run with ${availableMemoryMB.toInt()}MB');
      }
      return requestedModel;
    }
    
    // If not, find the best alternative
    final optimizedModel = WhisperModel.getBestModelForMemory(availableMemoryMB);
    
    if (optimizedModel != requestedModel) {
      if (kDebugMode) {
        debugPrint('[Model Selection] Downgraded from ${requestedModel.modelName} to ${optimizedModel.modelName} due to memory constraints');
      }
    }
    
    return optimizedModel;
  }

  DynamicLibrary _openLib() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("libwhisper.so");
    } else {
      return DynamicLibrary.process();
    }
  }

  Future<String> _getModelDir() async {
    if (modelDir != null) {
      return modelDir!;
    }
    final Directory libraryDirectory = Platform.isAndroid
        ? await getApplicationSupportDirectory()
        : await getLibraryDirectory();
    return libraryDirectory.path;
  }

  Future<void> _initModel(WhisperModel modelToInit) async {
    final String modelDir = await _getModelDir();
    final File modelFile = File(modelToInit.getPath(modelDir));
    final bool isModelExist = modelFile.existsSync();
    
    if (isModelExist) {
      if (kDebugMode) {
        final bool hasCoreML = modelToInit.hasCoreMLModel(modelDir);
        debugPrint("Use existing model ${modelToInit.modelName} ${hasCoreML ? '(CoreML available)' : '(CPU only)'}");
      }
      return;
    } else {
      if (kDebugMode) {
        debugPrint("Downloading model ${modelToInit.modelName}...");
      }
      await downloadModel(
          model: modelToInit, 
          destinationPath: modelDir, 
          downloadHost: downloadHost,
          downloadCoreML: Platform.isIOS || Platform.isMacOS);
    }
  }

  Future<Map<String, dynamic>> _request({
    required WhisperRequestDto whisperRequest,
    WhisperModel? specificModel,
  }) async {
    final modelToUse = specificModel ?? model;
    if (modelToUse != WhisperModel.none) {
      await _initModel(modelToUse);
    }
    return Isolate.run(
      () async {
        final Pointer<Utf8> data =
            whisperRequest.toRequestString().toNativeUtf8();
        final Pointer<Char> res =
            WhisperFlutterBindings(_openLib()).request(data.cast<Char>());
        final Map<String, dynamic> result = json.decode(
          res.cast<Utf8>().toDartString(),
        ) as Map<String, dynamic>;
        try {
          malloc.free(data);
          malloc.free(res);
        } catch (_) {}
        if (kDebugMode) {
          debugPrint("Result =  $result");
        }
        return result;
      },
    );
  }

  /// Transcribe audio file to text
  Future<WhisperTranscribeResponse> transcribe({
    required TranscribeRequest transcribeRequest,
  }) async {
    // Select optimal model based on available memory - MUST be done in main isolate
    final optimalModel = await _selectOptimalModel(model);
    
    final String modelDir = await _getModelDir();
    
    // Note: Background isolate cannot access method channels, so model selection is done above
    final Map<String, dynamic> result = await _request(
      whisperRequest: TranscribeRequestDto.fromTranscribeRequest(
        transcribeRequest,
        optimalModel.getPath(modelDir),
      ),
      specificModel: optimalModel,
    );
    if (kDebugMode) {
      debugPrint("Transcribe request $result");
    }
    if (result["text"] == null) {
      if (kDebugMode) {
        debugPrint('Transcribe Exception ${result['message']}');
      }
      throw Exception(result["message"]);
    }
    return WhisperTranscribeResponse.fromJson(result);
  }

  /// Get whisper version
  Future<String?> getVersion() async {
    final Map<String, dynamic> result = await _request(
      whisperRequest: const VersionRequest(),
    );

    final WhisperVersionResponse response = WhisperVersionResponse.fromJson(
      result,
    );
    return response.message;
  }

  /// Check if CoreML model is available for hardware acceleration
  Future<bool> hasCoreMLSupport() async {
    if (!Platform.isIOS && !Platform.isMacOS) return false;
    
    final String modelDir = await _getModelDir();
    return model.hasCoreMLModel(modelDir);
  }
}
