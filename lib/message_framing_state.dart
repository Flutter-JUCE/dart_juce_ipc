import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_framing_state.freezed.dart';

@freezed
class MessageFramingDecoderState with _$MessageFramingDecoderState {
  const factory MessageFramingDecoderState.header(List<int> data) = _Header;
  const factory MessageFramingDecoderState.message(int size, List<int> data) = _Message;
}