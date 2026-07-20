## 1.0.0

* Optimizing performance
* Update Dependencies
* AGP8+ compatible
* Support custom model download Host
* See the example project for more details.

## 1.0.1

* Update Gradle version to 8.4.2
* Update NDK version to 27.0.11902837
* Support MacOS


## 1.0.3

* Fix heap corruption on iOS: CoreML encoder exception handlers cleared a hardcoded 7.68MB (large-model size) instead of the actual output buffer, overrunning smaller models' buffers and causing delayed EXC_BAD_ACCESS crashes
* Fix silently dropped encoder output on iOS: copy-loop bounds check used the logical element count instead of the stride-padded physical size, zeroing the last encoder-state rows on every CoreML batch

## 1.0.2

* Prevents crashes by checking available memory before large allocations
* Automatic degradation from CoreML to CPU when memory is low
* Real-time monitoring with 200MB minimum threshold for iPhone 11's 4GB RAM
* Graceful error handling with helpful user messages
*  Memory cleanup triggered by iOS system notifications