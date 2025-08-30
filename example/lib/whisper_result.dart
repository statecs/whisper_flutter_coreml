import "package:whisper_flutter_coreml/whisper_flutter_coreml.dart";

class TranscribeResult {
  const TranscribeResult({
    required this.transcription,
    required this.time,
  });

  final WhisperTranscribeResponse transcription;
  final Duration time;
}
