// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_bean.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WhisperTranscribeResponse _$WhisperTranscribeResponseFromJson(
        Map<String, dynamic> json) =>
    _WhisperTranscribeResponse(
      type: json['@type'] as String,
      text: json['text'] as String,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) =>
              WhisperTranscribeSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WhisperTranscribeResponseToJson(
        _WhisperTranscribeResponse instance) =>
    <String, dynamic>{
      '@type': instance.type,
      'text': instance.text,
      'segments': instance.segments,
    };

_WhisperTranscribeSegment _$WhisperTranscribeSegmentFromJson(
        Map<String, dynamic> json) =>
    _WhisperTranscribeSegment(
      fromTs: WhisperTranscribeSegment._durationFromInt(
          (json['from_ts'] as num).toInt()),
      toTs: WhisperTranscribeSegment._durationFromInt(
          (json['to_ts'] as num).toInt()),
      text: json['text'] as String,
    );

Map<String, dynamic> _$WhisperTranscribeSegmentToJson(
        _WhisperTranscribeSegment instance) =>
    <String, dynamic>{
      'from_ts': instance.fromTs.inMicroseconds,
      'to_ts': instance.toTs.inMicroseconds,
      'text': instance.text,
    };

_WhisperVersionResponse _$WhisperVersionResponseFromJson(
        Map<String, dynamic> json) =>
    _WhisperVersionResponse(
      type: json['@type'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$WhisperVersionResponseToJson(
        _WhisperVersionResponse instance) =>
    <String, dynamic>{
      '@type': instance.type,
      'message': instance.message,
    };

_WhisperMemoryStatusResponse _$WhisperMemoryStatusResponseFromJson(
        Map<String, dynamic> json) =>
    _WhisperMemoryStatusResponse(
      type: json['@type'] as String,
      availableMb: (json['available_mb'] as num).toDouble(),
      sufficient: json['sufficient'] as bool,
    );

Map<String, dynamic> _$WhisperMemoryStatusResponseToJson(
        _WhisperMemoryStatusResponse instance) =>
    <String, dynamic>{
      '@type': instance.type,
      'available_mb': instance.availableMb,
      'sufficient': instance.sufficient,
    };
