// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'response_bean.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WhisperTranscribeResponse {
  @JsonKey(name: "@type")
  String get type;
  @JsonKey(name: "@type")
  set type(String value);
  String get text;
  set text(String value);
  @JsonKey(name: "segments")
  List<WhisperTranscribeSegment>? get segments;
  @JsonKey(name: "segments")
  set segments(List<WhisperTranscribeSegment>? value);

  /// Create a copy of WhisperTranscribeResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WhisperTranscribeResponseCopyWith<WhisperTranscribeResponse> get copyWith =>
      _$WhisperTranscribeResponseCopyWithImpl<WhisperTranscribeResponse>(
          this as WhisperTranscribeResponse, _$identity);

  /// Serializes this WhisperTranscribeResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'WhisperTranscribeResponse(type: $type, text: $text, segments: $segments)';
  }
}

/// @nodoc
abstract mixin class $WhisperTranscribeResponseCopyWith<$Res> {
  factory $WhisperTranscribeResponseCopyWith(WhisperTranscribeResponse value,
          $Res Function(WhisperTranscribeResponse) _then) =
      _$WhisperTranscribeResponseCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: "@type") String type,
      String text,
      @JsonKey(name: "segments") List<WhisperTranscribeSegment>? segments});
}

/// @nodoc
class _$WhisperTranscribeResponseCopyWithImpl<$Res>
    implements $WhisperTranscribeResponseCopyWith<$Res> {
  _$WhisperTranscribeResponseCopyWithImpl(this._self, this._then);

  final WhisperTranscribeResponse _self;
  final $Res Function(WhisperTranscribeResponse) _then;

  /// Create a copy of WhisperTranscribeResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? text = null,
    Object? segments = freezed,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      segments: freezed == segments
          ? _self.segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<WhisperTranscribeSegment>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WhisperTranscribeResponse implements WhisperTranscribeResponse {
  _WhisperTranscribeResponse(
      {@JsonKey(name: "@type") required this.type,
      required this.text,
      @JsonKey(name: "segments") required this.segments});
  factory _WhisperTranscribeResponse.fromJson(Map<String, dynamic> json) =>
      _$WhisperTranscribeResponseFromJson(json);

  @override
  @JsonKey(name: "@type")
  String type;
  @override
  String text;
  @override
  @JsonKey(name: "segments")
  List<WhisperTranscribeSegment>? segments;

  /// Create a copy of WhisperTranscribeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WhisperTranscribeResponseCopyWith<_WhisperTranscribeResponse>
      get copyWith =>
          __$WhisperTranscribeResponseCopyWithImpl<_WhisperTranscribeResponse>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WhisperTranscribeResponseToJson(
      this,
    );
  }

  @override
  String toString() {
    return 'WhisperTranscribeResponse(type: $type, text: $text, segments: $segments)';
  }
}

/// @nodoc
abstract mixin class _$WhisperTranscribeResponseCopyWith<$Res>
    implements $WhisperTranscribeResponseCopyWith<$Res> {
  factory _$WhisperTranscribeResponseCopyWith(_WhisperTranscribeResponse value,
          $Res Function(_WhisperTranscribeResponse) _then) =
      __$WhisperTranscribeResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "@type") String type,
      String text,
      @JsonKey(name: "segments") List<WhisperTranscribeSegment>? segments});
}

/// @nodoc
class __$WhisperTranscribeResponseCopyWithImpl<$Res>
    implements _$WhisperTranscribeResponseCopyWith<$Res> {
  __$WhisperTranscribeResponseCopyWithImpl(this._self, this._then);

  final _WhisperTranscribeResponse _self;
  final $Res Function(_WhisperTranscribeResponse) _then;

  /// Create a copy of WhisperTranscribeResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? text = null,
    Object? segments = freezed,
  }) {
    return _then(_WhisperTranscribeResponse(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      segments: freezed == segments
          ? _self.segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<WhisperTranscribeSegment>?,
    ));
  }
}

/// @nodoc
mixin _$WhisperTranscribeSegment {
  @JsonKey(name: "from_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
  Duration get fromTs;
  @JsonKey(name: "from_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
  set fromTs(Duration value);
  @JsonKey(name: "to_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
  Duration get toTs;
  @JsonKey(name: "to_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
  set toTs(Duration value);
  String get text;
  set text(String value);

  /// Create a copy of WhisperTranscribeSegment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WhisperTranscribeSegmentCopyWith<WhisperTranscribeSegment> get copyWith =>
      _$WhisperTranscribeSegmentCopyWithImpl<WhisperTranscribeSegment>(
          this as WhisperTranscribeSegment, _$identity);

  /// Serializes this WhisperTranscribeSegment to a JSON map.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'WhisperTranscribeSegment(fromTs: $fromTs, toTs: $toTs, text: $text)';
  }
}

/// @nodoc
abstract mixin class $WhisperTranscribeSegmentCopyWith<$Res> {
  factory $WhisperTranscribeSegmentCopyWith(WhisperTranscribeSegment value,
          $Res Function(WhisperTranscribeSegment) _then) =
      _$WhisperTranscribeSegmentCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(
          name: "from_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
      Duration fromTs,
      @JsonKey(
          name: "to_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
      Duration toTs,
      String text});
}

/// @nodoc
class _$WhisperTranscribeSegmentCopyWithImpl<$Res>
    implements $WhisperTranscribeSegmentCopyWith<$Res> {
  _$WhisperTranscribeSegmentCopyWithImpl(this._self, this._then);

  final WhisperTranscribeSegment _self;
  final $Res Function(WhisperTranscribeSegment) _then;

  /// Create a copy of WhisperTranscribeSegment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromTs = null,
    Object? toTs = null,
    Object? text = null,
  }) {
    return _then(_self.copyWith(
      fromTs: null == fromTs
          ? _self.fromTs
          : fromTs // ignore: cast_nullable_to_non_nullable
              as Duration,
      toTs: null == toTs
          ? _self.toTs
          : toTs // ignore: cast_nullable_to_non_nullable
              as Duration,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WhisperTranscribeSegment implements WhisperTranscribeSegment {
  _WhisperTranscribeSegment(
      {@JsonKey(
          name: "from_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
      required this.fromTs,
      @JsonKey(
          name: "to_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
      required this.toTs,
      required this.text});
  factory _WhisperTranscribeSegment.fromJson(Map<String, dynamic> json) =>
      _$WhisperTranscribeSegmentFromJson(json);

  @override
  @JsonKey(name: "from_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
  Duration fromTs;
  @override
  @JsonKey(name: "to_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
  Duration toTs;
  @override
  String text;

  /// Create a copy of WhisperTranscribeSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WhisperTranscribeSegmentCopyWith<_WhisperTranscribeSegment> get copyWith =>
      __$WhisperTranscribeSegmentCopyWithImpl<_WhisperTranscribeSegment>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WhisperTranscribeSegmentToJson(
      this,
    );
  }

  @override
  String toString() {
    return 'WhisperTranscribeSegment(fromTs: $fromTs, toTs: $toTs, text: $text)';
  }
}

/// @nodoc
abstract mixin class _$WhisperTranscribeSegmentCopyWith<$Res>
    implements $WhisperTranscribeSegmentCopyWith<$Res> {
  factory _$WhisperTranscribeSegmentCopyWith(_WhisperTranscribeSegment value,
          $Res Function(_WhisperTranscribeSegment) _then) =
      __$WhisperTranscribeSegmentCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          name: "from_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
      Duration fromTs,
      @JsonKey(
          name: "to_ts", fromJson: WhisperTranscribeSegment._durationFromInt)
      Duration toTs,
      String text});
}

/// @nodoc
class __$WhisperTranscribeSegmentCopyWithImpl<$Res>
    implements _$WhisperTranscribeSegmentCopyWith<$Res> {
  __$WhisperTranscribeSegmentCopyWithImpl(this._self, this._then);

  final _WhisperTranscribeSegment _self;
  final $Res Function(_WhisperTranscribeSegment) _then;

  /// Create a copy of WhisperTranscribeSegment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? fromTs = null,
    Object? toTs = null,
    Object? text = null,
  }) {
    return _then(_WhisperTranscribeSegment(
      fromTs: null == fromTs
          ? _self.fromTs
          : fromTs // ignore: cast_nullable_to_non_nullable
              as Duration,
      toTs: null == toTs
          ? _self.toTs
          : toTs // ignore: cast_nullable_to_non_nullable
              as Duration,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$WhisperVersionResponse {
  @JsonKey(name: "@type")
  String get type;
  @JsonKey(name: "@type")
  set type(String value);
  String get message;
  set message(String value);

  /// Create a copy of WhisperVersionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WhisperVersionResponseCopyWith<WhisperVersionResponse> get copyWith =>
      _$WhisperVersionResponseCopyWithImpl<WhisperVersionResponse>(
          this as WhisperVersionResponse, _$identity);

  /// Serializes this WhisperVersionResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'WhisperVersionResponse(type: $type, message: $message)';
  }
}

/// @nodoc
abstract mixin class $WhisperVersionResponseCopyWith<$Res> {
  factory $WhisperVersionResponseCopyWith(WhisperVersionResponse value,
          $Res Function(WhisperVersionResponse) _then) =
      _$WhisperVersionResponseCopyWithImpl;
  @useResult
  $Res call({@JsonKey(name: "@type") String type, String message});
}

/// @nodoc
class _$WhisperVersionResponseCopyWithImpl<$Res>
    implements $WhisperVersionResponseCopyWith<$Res> {
  _$WhisperVersionResponseCopyWithImpl(this._self, this._then);

  final WhisperVersionResponse _self;
  final $Res Function(WhisperVersionResponse) _then;

  /// Create a copy of WhisperVersionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? message = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WhisperVersionResponse implements WhisperVersionResponse {
  _WhisperVersionResponse(
      {@JsonKey(name: "@type") required this.type, required this.message});
  factory _WhisperVersionResponse.fromJson(Map<String, dynamic> json) =>
      _$WhisperVersionResponseFromJson(json);

  @override
  @JsonKey(name: "@type")
  String type;
  @override
  String message;

  /// Create a copy of WhisperVersionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WhisperVersionResponseCopyWith<_WhisperVersionResponse> get copyWith =>
      __$WhisperVersionResponseCopyWithImpl<_WhisperVersionResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WhisperVersionResponseToJson(
      this,
    );
  }

  @override
  String toString() {
    return 'WhisperVersionResponse(type: $type, message: $message)';
  }
}

/// @nodoc
abstract mixin class _$WhisperVersionResponseCopyWith<$Res>
    implements $WhisperVersionResponseCopyWith<$Res> {
  factory _$WhisperVersionResponseCopyWith(_WhisperVersionResponse value,
          $Res Function(_WhisperVersionResponse) _then) =
      __$WhisperVersionResponseCopyWithImpl;
  @override
  @useResult
  $Res call({@JsonKey(name: "@type") String type, String message});
}

/// @nodoc
class __$WhisperVersionResponseCopyWithImpl<$Res>
    implements _$WhisperVersionResponseCopyWith<$Res> {
  __$WhisperVersionResponseCopyWithImpl(this._self, this._then);

  final _WhisperVersionResponse _self;
  final $Res Function(_WhisperVersionResponse) _then;

  /// Create a copy of WhisperVersionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? message = null,
  }) {
    return _then(_WhisperVersionResponse(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$WhisperMemoryStatusResponse {
  @JsonKey(name: "@type")
  String get type;
  @JsonKey(name: "@type")
  set type(String value);
  @JsonKey(name: "available_mb")
  double get availableMb;
  @JsonKey(name: "available_mb")
  set availableMb(double value);
  bool get sufficient;
  set sufficient(bool value);

  /// Create a copy of WhisperMemoryStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WhisperMemoryStatusResponseCopyWith<WhisperMemoryStatusResponse>
      get copyWith => _$WhisperMemoryStatusResponseCopyWithImpl<
              WhisperMemoryStatusResponse>(
          this as WhisperMemoryStatusResponse, _$identity);

  /// Serializes this WhisperMemoryStatusResponse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'WhisperMemoryStatusResponse(type: $type, availableMb: $availableMb, sufficient: $sufficient)';
  }
}

/// @nodoc
abstract mixin class $WhisperMemoryStatusResponseCopyWith<$Res> {
  factory $WhisperMemoryStatusResponseCopyWith(
          WhisperMemoryStatusResponse value,
          $Res Function(WhisperMemoryStatusResponse) _then) =
      _$WhisperMemoryStatusResponseCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: "@type") String type,
      @JsonKey(name: "available_mb") double availableMb,
      bool sufficient});
}

/// @nodoc
class _$WhisperMemoryStatusResponseCopyWithImpl<$Res>
    implements $WhisperMemoryStatusResponseCopyWith<$Res> {
  _$WhisperMemoryStatusResponseCopyWithImpl(this._self, this._then);

  final WhisperMemoryStatusResponse _self;
  final $Res Function(WhisperMemoryStatusResponse) _then;

  /// Create a copy of WhisperMemoryStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? availableMb = null,
    Object? sufficient = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      availableMb: null == availableMb
          ? _self.availableMb
          : availableMb // ignore: cast_nullable_to_non_nullable
              as double,
      sufficient: null == sufficient
          ? _self.sufficient
          : sufficient // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _WhisperMemoryStatusResponse implements WhisperMemoryStatusResponse {
  _WhisperMemoryStatusResponse(
      {@JsonKey(name: "@type") required this.type,
      @JsonKey(name: "available_mb") required this.availableMb,
      required this.sufficient});
  factory _WhisperMemoryStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$WhisperMemoryStatusResponseFromJson(json);

  @override
  @JsonKey(name: "@type")
  String type;
  @override
  @JsonKey(name: "available_mb")
  double availableMb;
  @override
  bool sufficient;

  /// Create a copy of WhisperMemoryStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WhisperMemoryStatusResponseCopyWith<_WhisperMemoryStatusResponse>
      get copyWith => __$WhisperMemoryStatusResponseCopyWithImpl<
          _WhisperMemoryStatusResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WhisperMemoryStatusResponseToJson(
      this,
    );
  }

  @override
  String toString() {
    return 'WhisperMemoryStatusResponse(type: $type, availableMb: $availableMb, sufficient: $sufficient)';
  }
}

/// @nodoc
abstract mixin class _$WhisperMemoryStatusResponseCopyWith<$Res>
    implements $WhisperMemoryStatusResponseCopyWith<$Res> {
  factory _$WhisperMemoryStatusResponseCopyWith(
          _WhisperMemoryStatusResponse value,
          $Res Function(_WhisperMemoryStatusResponse) _then) =
      __$WhisperMemoryStatusResponseCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "@type") String type,
      @JsonKey(name: "available_mb") double availableMb,
      bool sufficient});
}

/// @nodoc
class __$WhisperMemoryStatusResponseCopyWithImpl<$Res>
    implements _$WhisperMemoryStatusResponseCopyWith<$Res> {
  __$WhisperMemoryStatusResponseCopyWithImpl(this._self, this._then);

  final _WhisperMemoryStatusResponse _self;
  final $Res Function(_WhisperMemoryStatusResponse) _then;

  /// Create a copy of WhisperMemoryStatusResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? availableMb = null,
    Object? sufficient = null,
  }) {
    return _then(_WhisperMemoryStatusResponse(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      availableMb: null == availableMb
          ? _self.availableMb
          : availableMb // ignore: cast_nullable_to_non_nullable
              as double,
      sufficient: null == sufficient
          ? _self.sufficient
          : sufficient // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
