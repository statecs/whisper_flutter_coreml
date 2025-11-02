/*
 */
import "package:freezed_annotation/freezed_annotation.dart";

part "response_bean.freezed.dart";
part "response_bean.g.dart";

@unfreezed
abstract class WhisperTranscribeResponse with _$WhisperTranscribeResponse {
  WhisperTranscribeResponse._();
  
  factory WhisperTranscribeResponse({
    @JsonKey(name: "@type") required String type,
    required String text,
    @JsonKey(name: "segments")
    required List<WhisperTranscribeSegment>? segments,
  }) = _WhisperTranscribeResponse;

  factory WhisperTranscribeResponse.fromJson(Map<String, dynamic> json) =>
      _$WhisperTranscribeResponseFromJson(json);
}

@unfreezed
abstract class WhisperTranscribeSegment with _$WhisperTranscribeSegment {
  WhisperTranscribeSegment._();
  
  factory WhisperTranscribeSegment({
    @JsonKey(
      name: "from_ts",
      fromJson: WhisperTranscribeSegment._durationFromInt,
    )
    required Duration fromTs,
    @JsonKey(
      name: "to_ts",
      fromJson: WhisperTranscribeSegment._durationFromInt,
    )
    required Duration toTs,
    required String text,
  }) = _WhisperTranscribeSegment;

  /// Parse [json] to WhisperTranscribeSegment
  factory WhisperTranscribeSegment.fromJson(Map<String, dynamic> json) =>
      _$WhisperTranscribeSegmentFromJson(json);

  static Duration _durationFromInt(int timestamp) {
    return Duration(
      milliseconds: timestamp * 10,
    );
  }
}

@unfreezed
abstract class WhisperVersionResponse with _$WhisperVersionResponse {
  WhisperVersionResponse._();
  
  factory WhisperVersionResponse({
    @JsonKey(name: "@type") required String type,
    required String message,
  }) = _WhisperVersionResponse;

  factory WhisperVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$WhisperVersionResponseFromJson(json);
}

@unfreezed
abstract class WhisperMemoryStatusResponse with _$WhisperMemoryStatusResponse {
  WhisperMemoryStatusResponse._();
  
  factory WhisperMemoryStatusResponse({
    @JsonKey(name: "@type") required String type,
    @JsonKey(name: "available_mb") required double availableMb,
    required bool sufficient,
  }) = _WhisperMemoryStatusResponse;

  factory WhisperMemoryStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$WhisperMemoryStatusResponseFromJson(json);
}
