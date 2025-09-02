import "dart:convert";

import "package:freezed_annotation/freezed_annotation.dart";
import "package:whisper_flutter_coreml/bean/whisper_dto.dart";

part "request_bean.freezed.dart";
part "request_bean.g.dart";

@unfreezed
abstract class TranscribeRequest with _$TranscribeRequest {
  TranscribeRequest._();
  
  factory TranscribeRequest({
    required String audio,
    @Default(false) bool isTranslate,
    @Default(6) int threads,
    @Default(false) bool isVerbose,
    @Default("auto") String language,
    @Default(false) bool isSpecialTokens,
    @Default(false) bool isNoTimestamps,
    @Default(1) int nProcessors,
    @Default(false) bool splitOnWord,
    @Default(false) bool noFallback,
    @Default(false) bool diarize,
    @Default(false) bool speedUp,
  }) = _TranscribeRequest;
  
  factory TranscribeRequest.fromJson(Map<String, dynamic> json) =>
      _$TranscribeRequestFromJson(json);
}


@freezed
abstract class TranscribeRequestDto
    with _$TranscribeRequestDto
    implements WhisperRequestDto {
  const factory TranscribeRequestDto({
    required String audio,
    required String model,
    @JsonKey(name: "is_translate") required bool isTranslate,
    required int threads,
    @JsonKey(name: "is_verbose") required bool isVerbose,
    required String language,
    @JsonKey(name: "is_special_tokens") required bool isSpecialTokens,
    @JsonKey(name: "is_no_timestamps") required bool isNoTimestamps,
    @JsonKey(name: "n_processors") required int nProcessors,
    @JsonKey(name: "split_on_word") required bool splitOnWord,
    @JsonKey(name: "no_fallback") required bool noFallback,
    required bool diarize,
    @JsonKey(name: "speed_up") required bool speedUp,
  }) = _TranscribeRequestDto;

  /// Convert [request] to TranscribeRequestDto with specified [modelPath]
  factory TranscribeRequestDto.fromTranscribeRequest(
    TranscribeRequest request,
    String modelPath,
  ) {
    return TranscribeRequestDto(
      audio: request.audio,
      model: modelPath,
      isTranslate: request.isTranslate,
      threads: request.threads,
      isVerbose: request.isVerbose,
      language: request.language,
      isSpecialTokens: request.isSpecialTokens,
      isNoTimestamps: request.isNoTimestamps,
      nProcessors: request.nProcessors,
      splitOnWord: request.splitOnWord,
      noFallback: request.noFallback,
      diarize: request.diarize,
      speedUp: request.speedUp,
    );
  }
  const TranscribeRequestDto._();

  /// Create request json
  factory TranscribeRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TranscribeRequestDtoFromJson(json);

  @override
  String get specialType => "getTextFromWavFile";

  @override
  String toRequestString() {
    return json.encode({
      "@type": specialType,
      ...toJson(),
    });
  }
}

@freezed
class VersionRequest with _$VersionRequest implements WhisperRequestDto {
  const factory VersionRequest() = _VersionRequest;
  const VersionRequest._();

  @override
  String get specialType => "getVersion";

  @override
  String toRequestString() {
    return json.encode({
      "@type": specialType,
    });
  }
}

@freezed
class MemoryCheckRequest with _$MemoryCheckRequest implements WhisperRequestDto {
  const factory MemoryCheckRequest() = _MemoryCheckRequest;
  const MemoryCheckRequest._();

  @override
  String get specialType => "checkMemory";

  @override
  String toRequestString() {
    return json.encode({
      "@type": specialType,
    });
  }
}
