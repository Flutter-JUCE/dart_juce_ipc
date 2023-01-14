// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_framing_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$MessageFramingDecoderState {
  List<int> get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<int> data) header,
    required TResult Function(int size, List<int> data) message,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<int> data)? header,
    TResult? Function(int size, List<int> data)? message,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<int> data)? header,
    TResult Function(int size, List<int> data)? message,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Header value) header,
    required TResult Function(_Message value) message,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Header value)? header,
    TResult? Function(_Message value)? message,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Header value)? header,
    TResult Function(_Message value)? message,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageFramingDecoderStateCopyWith<MessageFramingDecoderState>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageFramingDecoderStateCopyWith<$Res> {
  factory $MessageFramingDecoderStateCopyWith(MessageFramingDecoderState value,
          $Res Function(MessageFramingDecoderState) then) =
      _$MessageFramingDecoderStateCopyWithImpl<$Res,
          MessageFramingDecoderState>;
  @useResult
  $Res call({List<int> data});
}

/// @nodoc
class _$MessageFramingDecoderStateCopyWithImpl<$Res,
        $Val extends MessageFramingDecoderState>
    implements $MessageFramingDecoderStateCopyWith<$Res> {
  _$MessageFramingDecoderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_HeaderCopyWith<$Res>
    implements $MessageFramingDecoderStateCopyWith<$Res> {
  factory _$$_HeaderCopyWith(_$_Header value, $Res Function(_$_Header) then) =
      __$$_HeaderCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> data});
}

/// @nodoc
class __$$_HeaderCopyWithImpl<$Res>
    extends _$MessageFramingDecoderStateCopyWithImpl<$Res, _$_Header>
    implements _$$_HeaderCopyWith<$Res> {
  __$$_HeaderCopyWithImpl(_$_Header _value, $Res Function(_$_Header) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$_Header(
      null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$_Header implements _Header {
  const _$_Header(final List<int> data) : _data = data;

  final List<int> _data;
  @override
  List<int> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'MessageFramingDecoderState.header(data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Header &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_HeaderCopyWith<_$_Header> get copyWith =>
      __$$_HeaderCopyWithImpl<_$_Header>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<int> data) header,
    required TResult Function(int size, List<int> data) message,
  }) {
    return header(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<int> data)? header,
    TResult? Function(int size, List<int> data)? message,
  }) {
    return header?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<int> data)? header,
    TResult Function(int size, List<int> data)? message,
    required TResult orElse(),
  }) {
    if (header != null) {
      return header(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Header value) header,
    required TResult Function(_Message value) message,
  }) {
    return header(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Header value)? header,
    TResult? Function(_Message value)? message,
  }) {
    return header?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Header value)? header,
    TResult Function(_Message value)? message,
    required TResult orElse(),
  }) {
    if (header != null) {
      return header(this);
    }
    return orElse();
  }
}

abstract class _Header implements MessageFramingDecoderState {
  const factory _Header(final List<int> data) = _$_Header;

  @override
  List<int> get data;
  @override
  @JsonKey(ignore: true)
  _$$_HeaderCopyWith<_$_Header> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$_MessageCopyWith<$Res>
    implements $MessageFramingDecoderStateCopyWith<$Res> {
  factory _$$_MessageCopyWith(
          _$_Message value, $Res Function(_$_Message) then) =
      __$$_MessageCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int size, List<int> data});
}

/// @nodoc
class __$$_MessageCopyWithImpl<$Res>
    extends _$MessageFramingDecoderStateCopyWithImpl<$Res, _$_Message>
    implements _$$_MessageCopyWith<$Res> {
  __$$_MessageCopyWithImpl(_$_Message _value, $Res Function(_$_Message) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? size = null,
    Object? data = null,
  }) {
    return _then(_$_Message(
      null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as int,
      null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc

class _$_Message implements _Message {
  const _$_Message(this.size, final List<int> data) : _data = data;

  @override
  final int size;
  final List<int> _data;
  @override
  List<int> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  String toString() {
    return 'MessageFramingDecoderState.message(size: $size, data: $data)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Message &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, size, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_MessageCopyWith<_$_Message> get copyWith =>
      __$$_MessageCopyWithImpl<_$_Message>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(List<int> data) header,
    required TResult Function(int size, List<int> data) message,
  }) {
    return message(size, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<int> data)? header,
    TResult? Function(int size, List<int> data)? message,
  }) {
    return message?.call(size, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<int> data)? header,
    TResult Function(int size, List<int> data)? message,
    required TResult orElse(),
  }) {
    if (message != null) {
      return message(size, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Header value) header,
    required TResult Function(_Message value) message,
  }) {
    return message(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Header value)? header,
    TResult? Function(_Message value)? message,
  }) {
    return message?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Header value)? header,
    TResult Function(_Message value)? message,
    required TResult orElse(),
  }) {
    if (message != null) {
      return message(this);
    }
    return orElse();
  }
}

abstract class _Message implements MessageFramingDecoderState {
  const factory _Message(final int size, final List<int> data) = _$_Message;

  int get size;
  @override
  List<int> get data;
  @override
  @JsonKey(ignore: true)
  _$$_MessageCopyWith<_$_Message> get copyWith =>
      throw _privateConstructorUsedError;
}
