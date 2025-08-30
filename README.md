# Whisper Flutter CoreML


Ready to use [whisper.cpp](https://github.com/ggerganov/whisper.cpp) models implementation for iOS
and Android

1. Support AGP8+
2. Support Android 5.0+ & iOS 13+ & MacOS 11+
3. It is optimized and fast

Supported models: tiny、base、small、medium、large-v1、large-v2

Recommended Models：base、small、medium

All models have been actually tested, test devices: Android: Google Pixel 7 Pro, iOS: M1 iOS
simulator，MacOS: M1 MacBookPro & M2 MacMini

## Install library

```bash
flutter pub add whisper_flutter_coreml
```

## import library

```dart
import 'package:whisper_flutter_coreml/whisper_flutter_coreml.dart';
```

## Quickstart

```dart
// Prepare wav file
final Directory documentDirectory = await getApplicationDocumentsDirectory();
final ByteData documentBytes = await rootBundle.load('assets/jfk.wav');

final String jfkPath = '${documentDirectory.path}/jfk.wav';

await File(jfkPath).writeAsBytes(
    documentBytes.buffer.asUint8List(),
);

// Begin whisper transcription
/// China: https://hf-mirror.com/ggerganov/whisper.cpp/resolve/main
/// Other: https://huggingface.co/ggerganov/whisper.cpp/resolve/main
final Whisper whisper = Whisper(
    model: WhisperModel.base,
    downloadHost: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main"
);

final String? whisperVersion = await whisper.getVersion();
print(whisperVersion);

final String transcription = await whisper.transcribe(
    transcribeRequest: TranscribeRequest(
        audio: jfkPath,
        isTranslate: true, // Translate result from audio lang to english text
        isNoTimestamps: false, // Get segments in result
        splitOnWord: true, // Split segments on each word 
    ),
);
print(transcription);
```
