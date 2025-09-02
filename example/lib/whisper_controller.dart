import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:path_provider/path_provider.dart";
import "package:system_info2/system_info2.dart";
import "package:test_whisper/providers.dart";
import "package:test_whisper/whisper_audio_convert.dart";
import "package:test_whisper/whisper_result.dart";
import "package:whisper_flutter_coreml/whisper_flutter_coreml.dart";

class WhisperController extends StateNotifier<AsyncValue<TranscribeResult?>> {
  WhisperController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> transcribe(String filePath) async {
    final WhisperModel requestedModel = ref.read(modelProvider);

    state = const AsyncLoading();

    /// China: https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main
    /// Other: https://huggingface.co/ggerganov/whisper.cpp/resolve/main
    final Whisper whisper = Whisper(
        model: requestedModel,
        downloadHost:
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main");

    final DateTime start = DateTime.now();

    final String lang = ref.read(langProvider);

    final bool translate = ref.read(translateProvider);

    final bool withSegments = ref.read(withSegmentsProvider);

    final bool splitWords = ref.read(splitWordsProvider);

    try {
      if (kDebugMode) {
        debugPrint("[Whisper] Starting transcription with requested model: ${requestedModel.modelName}");
      }
      
      final String? whisperVersion = await whisper.getVersion();
      var cores = 2;
      try {
        cores = SysInfo.cores.length;
      } catch (_) {
        cores = 8;
      }
      
      // Optimize thread count for mobile devices to prevent memory issues
      final int optimizedThreads = cores <= 4 ? cores : (cores * 0.75).ceil();
      final int optimizedProcessors = optimizedThreads;
      
      if (kDebugMode) {
        debugPrint("[Whisper] Device cores: $cores, optimized threads: $optimizedThreads");
        debugPrint("[Whisper] Whisper version: $whisperVersion");
      }
      
      final Directory documentDirectory =
          await getApplicationDocumentsDirectory();
      final WhisperAudioconvert converter = WhisperAudioconvert(
        audioInput: File(filePath),
        audioOutput: File("${documentDirectory.path}/convert.wav"),
      );

      final File? convertedFile = await converter.convert();
      final WhisperTranscribeResponse transcription = await whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: convertedFile?.path ?? filePath,
          language: lang,
          nProcessors: optimizedProcessors,
          threads: optimizedThreads,
          isTranslate: translate,
          isNoTimestamps: !withSegments,
          splitOnWord: splitWords,
        ),
      );

      final Duration transcriptionDuration = DateTime.now().difference(start);
      if (kDebugMode) {
        debugPrint("[Whisper] Transcription completed in $transcriptionDuration");
        debugPrint("[Whisper] Text length: ${transcription.text.length} characters");
      }
      
      state = AsyncData(
        TranscribeResult(
          time: transcriptionDuration,
          transcription: transcription,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("[Whisper] Transcription error: $e");
      }
      
      // Check if this is a memory-related error and provide helpful message
      if (e.toString().contains('memory') || e.toString().contains('Memory')) {
        if (kDebugMode) {
          debugPrint("[Whisper] Memory-related error detected - automatic model downgrade should have prevented this");
        }
      }
      
      state = const AsyncData(null);
    }
  }
}

final whisperControllerProvider = StateNotifierProvider.autoDispose<
    WhisperController, AsyncValue<TranscribeResult?>>(
  (ref) => WhisperController(ref),
);
