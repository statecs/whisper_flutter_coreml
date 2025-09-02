// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_bean.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TranscribeRequest {
  String get audio;
  set audio(String value);
  bool get isTranslate;
  set isTranslate(bool value);
  int get threads;
  set threads(int value);
  bool get isVerbose;
  set isVerbose(bool value);
  String get language;
  set language(String value);
  bool get isSpecialTokens;
  set isSpecialTokens(bool value);
  bool get isNoTimestamps;
  set isNoTimestamps(bool value);
  int get nProcessors;
  set nProcessors(int value);
  bool get splitOnWord;
  set splitOnWord(bool value);
  bool get noFallback;
  set noFallback(bool value);
  bool get diarize;
  set diarize(bool value);
  bool get speedUp;
  set speedUp(bool value);

  /// Create a copy of TranscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TranscribeRequestCopyWith<TranscribeRequest> get copyWith =>
      _$TranscribeRequestCopyWithImpl<TranscribeRequest>(
          this as TranscribeRequest, _$identity);

  /// Serializes this TranscribeRequest to a JSON map.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'TranscribeRequest(audio: $audio, isTranslate: $isTranslate, threads: $threads, isVerbose: $isVerbose, language: $language, isSpecialTokens: $isSpecialTokens, isNoTimestamps: $isNoTimestamps, nProcessors: $nProcessors, splitOnWord: $splitOnWord, noFallback: $noFallback, diarize: $diarize, speedUp: $speedUp)';
  }
}

/// @nodoc
abstract mixin class $TranscribeRequestCopyWith<$Res> {
  factory $TranscribeRequestCopyWith(
          TranscribeRequest value, $Res Function(TranscribeRequest) _then) =
      _$TranscribeRequestCopyWithImpl;
  @useResult
  $Res call(
      {String audio,
      bool isTranslate,
      int threads,
      bool isVerbose,
      String language,
      bool isSpecialTokens,
      bool isNoTimestamps,
      int nProcessors,
      bool splitOnWord,
      bool noFallback,
      bool diarize,
      bool speedUp});
}

/// @nodoc
class _$TranscribeRequestCopyWithImpl<$Res>
    implements $TranscribeRequestCopyWith<$Res> {
  _$TranscribeRequestCopyWithImpl(this._self, this._then);

  final TranscribeRequest _self;
  final $Res Function(TranscribeRequest) _then;

  /// Create a copy of TranscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audio = null,
    Object? isTranslate = null,
    Object? threads = null,
    Object? isVerbose = null,
    Object? language = null,
    Object? isSpecialTokens = null,
    Object? isNoTimestamps = null,
    Object? nProcessors = null,
    Object? splitOnWord = null,
    Object? noFallback = null,
    Object? diarize = null,
    Object? speedUp = null,
  }) {
    return _then(_self.copyWith(
      audio: null == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String,
      isTranslate: null == isTranslate
          ? _self.isTranslate
          : isTranslate // ignore: cast_nullable_to_non_nullable
              as bool,
      threads: null == threads
          ? _self.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      isVerbose: null == isVerbose
          ? _self.isVerbose
          : isVerbose // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      isSpecialTokens: null == isSpecialTokens
          ? _self.isSpecialTokens
          : isSpecialTokens // ignore: cast_nullable_to_non_nullable
              as bool,
      isNoTimestamps: null == isNoTimestamps
          ? _self.isNoTimestamps
          : isNoTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      nProcessors: null == nProcessors
          ? _self.nProcessors
          : nProcessors // ignore: cast_nullable_to_non_nullable
              as int,
      splitOnWord: null == splitOnWord
          ? _self.splitOnWord
          : splitOnWord // ignore: cast_nullable_to_non_nullable
              as bool,
      noFallback: null == noFallback
          ? _self.noFallback
          : noFallback // ignore: cast_nullable_to_non_nullable
              as bool,
      diarize: null == diarize
          ? _self.diarize
          : diarize // ignore: cast_nullable_to_non_nullable
              as bool,
      speedUp: null == speedUp
          ? _self.speedUp
          : speedUp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TranscribeRequest implements TranscribeRequest {
  _TranscribeRequest(
      {required this.audio,
      this.isTranslate = false,
      this.threads = 6,
      this.isVerbose = false,
      this.language = "auto",
      this.isSpecialTokens = false,
      this.isNoTimestamps = false,
      this.nProcessors = 1,
      this.splitOnWord = false,
      this.noFallback = false,
      this.diarize = false,
      this.speedUp = false});
  factory _TranscribeRequest.fromJson(Map<String, dynamic> json) =>
      _$TranscribeRequestFromJson(json);

  @override
  String audio;
  @override
  @JsonKey()
  bool isTranslate;
  @override
  @JsonKey()
  int threads;
  @override
  @JsonKey()
  bool isVerbose;
  @override
  @JsonKey()
  String language;
  @override
  @JsonKey()
  bool isSpecialTokens;
  @override
  @JsonKey()
  bool isNoTimestamps;
  @override
  @JsonKey()
  int nProcessors;
  @override
  @JsonKey()
  bool splitOnWord;
  @override
  @JsonKey()
  bool noFallback;
  @override
  @JsonKey()
  bool diarize;
  @override
  @JsonKey()
  bool speedUp;

  /// Create a copy of TranscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TranscribeRequestCopyWith<_TranscribeRequest> get copyWith =>
      __$TranscribeRequestCopyWithImpl<_TranscribeRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TranscribeRequestToJson(
      this,
    );
  }

  @override
  String toString() {
    return 'TranscribeRequest(audio: $audio, isTranslate: $isTranslate, threads: $threads, isVerbose: $isVerbose, language: $language, isSpecialTokens: $isSpecialTokens, isNoTimestamps: $isNoTimestamps, nProcessors: $nProcessors, splitOnWord: $splitOnWord, noFallback: $noFallback, diarize: $diarize, speedUp: $speedUp)';
  }
}

/// @nodoc
abstract mixin class _$TranscribeRequestCopyWith<$Res>
    implements $TranscribeRequestCopyWith<$Res> {
  factory _$TranscribeRequestCopyWith(
          _TranscribeRequest value, $Res Function(_TranscribeRequest) _then) =
      __$TranscribeRequestCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String audio,
      bool isTranslate,
      int threads,
      bool isVerbose,
      String language,
      bool isSpecialTokens,
      bool isNoTimestamps,
      int nProcessors,
      bool splitOnWord,
      bool noFallback,
      bool diarize,
      bool speedUp});
}

/// @nodoc
class __$TranscribeRequestCopyWithImpl<$Res>
    implements _$TranscribeRequestCopyWith<$Res> {
  __$TranscribeRequestCopyWithImpl(this._self, this._then);

  final _TranscribeRequest _self;
  final $Res Function(_TranscribeRequest) _then;

  /// Create a copy of TranscribeRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? audio = null,
    Object? isTranslate = null,
    Object? threads = null,
    Object? isVerbose = null,
    Object? language = null,
    Object? isSpecialTokens = null,
    Object? isNoTimestamps = null,
    Object? nProcessors = null,
    Object? splitOnWord = null,
    Object? noFallback = null,
    Object? diarize = null,
    Object? speedUp = null,
  }) {
    return _then(_TranscribeRequest(
      audio: null == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String,
      isTranslate: null == isTranslate
          ? _self.isTranslate
          : isTranslate // ignore: cast_nullable_to_non_nullable
              as bool,
      threads: null == threads
          ? _self.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      isVerbose: null == isVerbose
          ? _self.isVerbose
          : isVerbose // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      isSpecialTokens: null == isSpecialTokens
          ? _self.isSpecialTokens
          : isSpecialTokens // ignore: cast_nullable_to_non_nullable
              as bool,
      isNoTimestamps: null == isNoTimestamps
          ? _self.isNoTimestamps
          : isNoTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      nProcessors: null == nProcessors
          ? _self.nProcessors
          : nProcessors // ignore: cast_nullable_to_non_nullable
              as int,
      splitOnWord: null == splitOnWord
          ? _self.splitOnWord
          : splitOnWord // ignore: cast_nullable_to_non_nullable
              as bool,
      noFallback: null == noFallback
          ? _self.noFallback
          : noFallback // ignore: cast_nullable_to_non_nullable
              as bool,
      diarize: null == diarize
          ? _self.diarize
          : diarize // ignore: cast_nullable_to_non_nullable
              as bool,
      speedUp: null == speedUp
          ? _self.speedUp
          : speedUp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$TranscribeRequestDto {
  String get audio;
  String get model;
  @JsonKey(name: "is_translate")
  bool get isTranslate;
  int get threads;
  @JsonKey(name: "is_verbose")
  bool get isVerbose;
  String get language;
  @JsonKey(name: "is_special_tokens")
  bool get isSpecialTokens;
  @JsonKey(name: "is_no_timestamps")
  bool get isNoTimestamps;
  @JsonKey(name: "n_processors")
  int get nProcessors;
  @JsonKey(name: "split_on_word")
  bool get splitOnWord;
  @JsonKey(name: "no_fallback")
  bool get noFallback;
  bool get diarize;
  @JsonKey(name: "speed_up")
  bool get speedUp;

  /// Create a copy of TranscribeRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TranscribeRequestDtoCopyWith<TranscribeRequestDto> get copyWith =>
      _$TranscribeRequestDtoCopyWithImpl<TranscribeRequestDto>(
          this as TranscribeRequestDto, _$identity);

  /// Serializes this TranscribeRequestDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TranscribeRequestDto &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.isTranslate, isTranslate) ||
                other.isTranslate == isTranslate) &&
            (identical(other.threads, threads) || other.threads == threads) &&
            (identical(other.isVerbose, isVerbose) ||
                other.isVerbose == isVerbose) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.isSpecialTokens, isSpecialTokens) ||
                other.isSpecialTokens == isSpecialTokens) &&
            (identical(other.isNoTimestamps, isNoTimestamps) ||
                other.isNoTimestamps == isNoTimestamps) &&
            (identical(other.nProcessors, nProcessors) ||
                other.nProcessors == nProcessors) &&
            (identical(other.splitOnWord, splitOnWord) ||
                other.splitOnWord == splitOnWord) &&
            (identical(other.noFallback, noFallback) ||
                other.noFallback == noFallback) &&
            (identical(other.diarize, diarize) || other.diarize == diarize) &&
            (identical(other.speedUp, speedUp) || other.speedUp == speedUp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      audio,
      model,
      isTranslate,
      threads,
      isVerbose,
      language,
      isSpecialTokens,
      isNoTimestamps,
      nProcessors,
      splitOnWord,
      noFallback,
      diarize,
      speedUp);

  @override
  String toString() {
    return 'TranscribeRequestDto(audio: $audio, model: $model, isTranslate: $isTranslate, threads: $threads, isVerbose: $isVerbose, language: $language, isSpecialTokens: $isSpecialTokens, isNoTimestamps: $isNoTimestamps, nProcessors: $nProcessors, splitOnWord: $splitOnWord, noFallback: $noFallback, diarize: $diarize, speedUp: $speedUp)';
  }
}

/// @nodoc
abstract mixin class $TranscribeRequestDtoCopyWith<$Res> {
  factory $TranscribeRequestDtoCopyWith(TranscribeRequestDto value,
          $Res Function(TranscribeRequestDto) _then) =
      _$TranscribeRequestDtoCopyWithImpl;
  @useResult
  $Res call(
      {String audio,
      String model,
      @JsonKey(name: "is_translate") bool isTranslate,
      int threads,
      @JsonKey(name: "is_verbose") bool isVerbose,
      String language,
      @JsonKey(name: "is_special_tokens") bool isSpecialTokens,
      @JsonKey(name: "is_no_timestamps") bool isNoTimestamps,
      @JsonKey(name: "n_processors") int nProcessors,
      @JsonKey(name: "split_on_word") bool splitOnWord,
      @JsonKey(name: "no_fallback") bool noFallback,
      bool diarize,
      @JsonKey(name: "speed_up") bool speedUp});
}

/// @nodoc
class _$TranscribeRequestDtoCopyWithImpl<$Res>
    implements $TranscribeRequestDtoCopyWith<$Res> {
  _$TranscribeRequestDtoCopyWithImpl(this._self, this._then);

  final TranscribeRequestDto _self;
  final $Res Function(TranscribeRequestDto) _then;

  /// Create a copy of TranscribeRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? audio = null,
    Object? model = null,
    Object? isTranslate = null,
    Object? threads = null,
    Object? isVerbose = null,
    Object? language = null,
    Object? isSpecialTokens = null,
    Object? isNoTimestamps = null,
    Object? nProcessors = null,
    Object? splitOnWord = null,
    Object? noFallback = null,
    Object? diarize = null,
    Object? speedUp = null,
  }) {
    return _then(_self.copyWith(
      audio: null == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      isTranslate: null == isTranslate
          ? _self.isTranslate
          : isTranslate // ignore: cast_nullable_to_non_nullable
              as bool,
      threads: null == threads
          ? _self.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      isVerbose: null == isVerbose
          ? _self.isVerbose
          : isVerbose // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      isSpecialTokens: null == isSpecialTokens
          ? _self.isSpecialTokens
          : isSpecialTokens // ignore: cast_nullable_to_non_nullable
              as bool,
      isNoTimestamps: null == isNoTimestamps
          ? _self.isNoTimestamps
          : isNoTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      nProcessors: null == nProcessors
          ? _self.nProcessors
          : nProcessors // ignore: cast_nullable_to_non_nullable
              as int,
      splitOnWord: null == splitOnWord
          ? _self.splitOnWord
          : splitOnWord // ignore: cast_nullable_to_non_nullable
              as bool,
      noFallback: null == noFallback
          ? _self.noFallback
          : noFallback // ignore: cast_nullable_to_non_nullable
              as bool,
      diarize: null == diarize
          ? _self.diarize
          : diarize // ignore: cast_nullable_to_non_nullable
              as bool,
      speedUp: null == speedUp
          ? _self.speedUp
          : speedUp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _TranscribeRequestDto extends TranscribeRequestDto {
  const _TranscribeRequestDto(
      {required this.audio,
      required this.model,
      @JsonKey(name: "is_translate") required this.isTranslate,
      required this.threads,
      @JsonKey(name: "is_verbose") required this.isVerbose,
      required this.language,
      @JsonKey(name: "is_special_tokens") required this.isSpecialTokens,
      @JsonKey(name: "is_no_timestamps") required this.isNoTimestamps,
      @JsonKey(name: "n_processors") required this.nProcessors,
      @JsonKey(name: "split_on_word") required this.splitOnWord,
      @JsonKey(name: "no_fallback") required this.noFallback,
      required this.diarize,
      @JsonKey(name: "speed_up") required this.speedUp})
      : super._();
  factory _TranscribeRequestDto.fromJson(Map<String, dynamic> json) =>
      _$TranscribeRequestDtoFromJson(json);

  @override
  final String audio;
  @override
  final String model;
  @override
  @JsonKey(name: "is_translate")
  final bool isTranslate;
  @override
  final int threads;
  @override
  @JsonKey(name: "is_verbose")
  final bool isVerbose;
  @override
  final String language;
  @override
  @JsonKey(name: "is_special_tokens")
  final bool isSpecialTokens;
  @override
  @JsonKey(name: "is_no_timestamps")
  final bool isNoTimestamps;
  @override
  @JsonKey(name: "n_processors")
  final int nProcessors;
  @override
  @JsonKey(name: "split_on_word")
  final bool splitOnWord;
  @override
  @JsonKey(name: "no_fallback")
  final bool noFallback;
  @override
  final bool diarize;
  @override
  @JsonKey(name: "speed_up")
  final bool speedUp;

  /// Create a copy of TranscribeRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TranscribeRequestDtoCopyWith<_TranscribeRequestDto> get copyWith =>
      __$TranscribeRequestDtoCopyWithImpl<_TranscribeRequestDto>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TranscribeRequestDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TranscribeRequestDto &&
            (identical(other.audio, audio) || other.audio == audio) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.isTranslate, isTranslate) ||
                other.isTranslate == isTranslate) &&
            (identical(other.threads, threads) || other.threads == threads) &&
            (identical(other.isVerbose, isVerbose) ||
                other.isVerbose == isVerbose) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.isSpecialTokens, isSpecialTokens) ||
                other.isSpecialTokens == isSpecialTokens) &&
            (identical(other.isNoTimestamps, isNoTimestamps) ||
                other.isNoTimestamps == isNoTimestamps) &&
            (identical(other.nProcessors, nProcessors) ||
                other.nProcessors == nProcessors) &&
            (identical(other.splitOnWord, splitOnWord) ||
                other.splitOnWord == splitOnWord) &&
            (identical(other.noFallback, noFallback) ||
                other.noFallback == noFallback) &&
            (identical(other.diarize, diarize) || other.diarize == diarize) &&
            (identical(other.speedUp, speedUp) || other.speedUp == speedUp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      audio,
      model,
      isTranslate,
      threads,
      isVerbose,
      language,
      isSpecialTokens,
      isNoTimestamps,
      nProcessors,
      splitOnWord,
      noFallback,
      diarize,
      speedUp);

  @override
  String toString() {
    return 'TranscribeRequestDto(audio: $audio, model: $model, isTranslate: $isTranslate, threads: $threads, isVerbose: $isVerbose, language: $language, isSpecialTokens: $isSpecialTokens, isNoTimestamps: $isNoTimestamps, nProcessors: $nProcessors, splitOnWord: $splitOnWord, noFallback: $noFallback, diarize: $diarize, speedUp: $speedUp)';
  }
}

/// @nodoc
abstract mixin class _$TranscribeRequestDtoCopyWith<$Res>
    implements $TranscribeRequestDtoCopyWith<$Res> {
  factory _$TranscribeRequestDtoCopyWith(_TranscribeRequestDto value,
          $Res Function(_TranscribeRequestDto) _then) =
      __$TranscribeRequestDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String audio,
      String model,
      @JsonKey(name: "is_translate") bool isTranslate,
      int threads,
      @JsonKey(name: "is_verbose") bool isVerbose,
      String language,
      @JsonKey(name: "is_special_tokens") bool isSpecialTokens,
      @JsonKey(name: "is_no_timestamps") bool isNoTimestamps,
      @JsonKey(name: "n_processors") int nProcessors,
      @JsonKey(name: "split_on_word") bool splitOnWord,
      @JsonKey(name: "no_fallback") bool noFallback,
      bool diarize,
      @JsonKey(name: "speed_up") bool speedUp});
}

/// @nodoc
class __$TranscribeRequestDtoCopyWithImpl<$Res>
    implements _$TranscribeRequestDtoCopyWith<$Res> {
  __$TranscribeRequestDtoCopyWithImpl(this._self, this._then);

  final _TranscribeRequestDto _self;
  final $Res Function(_TranscribeRequestDto) _then;

  /// Create a copy of TranscribeRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? audio = null,
    Object? model = null,
    Object? isTranslate = null,
    Object? threads = null,
    Object? isVerbose = null,
    Object? language = null,
    Object? isSpecialTokens = null,
    Object? isNoTimestamps = null,
    Object? nProcessors = null,
    Object? splitOnWord = null,
    Object? noFallback = null,
    Object? diarize = null,
    Object? speedUp = null,
  }) {
    return _then(_TranscribeRequestDto(
      audio: null == audio
          ? _self.audio
          : audio // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      isTranslate: null == isTranslate
          ? _self.isTranslate
          : isTranslate // ignore: cast_nullable_to_non_nullable
              as bool,
      threads: null == threads
          ? _self.threads
          : threads // ignore: cast_nullable_to_non_nullable
              as int,
      isVerbose: null == isVerbose
          ? _self.isVerbose
          : isVerbose // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      isSpecialTokens: null == isSpecialTokens
          ? _self.isSpecialTokens
          : isSpecialTokens // ignore: cast_nullable_to_non_nullable
              as bool,
      isNoTimestamps: null == isNoTimestamps
          ? _self.isNoTimestamps
          : isNoTimestamps // ignore: cast_nullable_to_non_nullable
              as bool,
      nProcessors: null == nProcessors
          ? _self.nProcessors
          : nProcessors // ignore: cast_nullable_to_non_nullable
              as int,
      splitOnWord: null == splitOnWord
          ? _self.splitOnWord
          : splitOnWord // ignore: cast_nullable_to_non_nullable
              as bool,
      noFallback: null == noFallback
          ? _self.noFallback
          : noFallback // ignore: cast_nullable_to_non_nullable
              as bool,
      diarize: null == diarize
          ? _self.diarize
          : diarize // ignore: cast_nullable_to_non_nullable
              as bool,
      speedUp: null == speedUp
          ? _self.speedUp
          : speedUp // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$VersionRequest {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is VersionRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VersionRequest()';
  }
}

/// @nodoc
class $VersionRequestCopyWith<$Res> {
  $VersionRequestCopyWith(VersionRequest _, $Res Function(VersionRequest) __);
}

/// @nodoc

class _VersionRequest extends VersionRequest {
  const _VersionRequest() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _VersionRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'VersionRequest()';
  }
}

/// @nodoc
mixin _$MemoryCheckRequest {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MemoryCheckRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MemoryCheckRequest()';
  }
}

/// @nodoc
class $MemoryCheckRequestCopyWith<$Res> {
  $MemoryCheckRequestCopyWith(
      MemoryCheckRequest _, $Res Function(MemoryCheckRequest) __);
}

/// @nodoc

class _MemoryCheckRequest extends MemoryCheckRequest {
  const _MemoryCheckRequest() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _MemoryCheckRequest);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MemoryCheckRequest()';
  }
}

// dart format on
