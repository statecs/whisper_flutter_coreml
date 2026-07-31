## 1.0.4

* Support Whisper v3-family models (`large-v3`, `large-v3-turbo`): the vendored whisper.cpp predated v3 and decoded these models into gibberish — `is_multilingual()` rejected the 51866-token v3 vocab (shifting every special token id), and the mel spectrogram was hardcoded to 80 bins while v3 encoders expect 128
* Fix CoreML encoder lookup for quantized models: the Dart downloader kept the `-qX_Y` suffix in the `.mlmodelc` name, but whisper.cpp strips it when resolving the encoder path, so turbo never found its downloaded CoreML encoder and silently fell back to CPU
* Cache the whisper context across requests instead of reloading model weights and the CoreML encoder on every transcription
* Add `Whisper.releaseContext()` to free the cached native context and reclaim memory; the next `transcribe()` reloads the model automatically
* Update Android build to NDK 28.0.12433566 and compileSdk 36 (16 KB page-size alignment required by Google Play for targetSdk 35+)

## 1.0.3

* Fix heap corruption on iOS: CoreML encoder exception handlers cleared a hardcoded 7.68MB (large-model size) instead of the actual output buffer, overrunning smaller models' buffers and causing delayed EXC_BAD_ACCESS crashes
* Fix silently dropped encoder output on iOS: copy-loop bounds check used the logical element count instead of the stride-padded physical size, zeroing the last encoder-state rows on every CoreML batch

## 1.0.2

* Prevents crashes by checking available memory before large allocations
* Automatic degradation from CoreML to CPU when memory is low
* Real-time monitoring with 200MB minimum threshold for iPhone 11's 4GB RAM
* Graceful error handling with helpful user messages
* Memory cleanup triggered by iOS system notifications

## 1.0.1

* Update Gradle version to 8.4.2
* Update NDK version to 27.0.11902837
* Support MacOS

## 1.0.0

* Optimizing performance
* Update Dependencies
* AGP8+ compatible
* Support custom model download Host
* See the example project for more details.
