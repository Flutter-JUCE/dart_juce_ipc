import 'dart:async';
import 'dart:io';
import 'package:juce_ipc/message_framing_state.dart';
import 'dart:typed_data';
import 'dart:developer';

/// Converts data from a socket into messages
///
/// This class will parse the input data as a byte stream, and output a full
/// message, exactly as it was sent at the other side of the connection.
class MessageFramingDecoder {
  MessageFramingDecoder({required int magic}) : _magic = magic;

  final int _magic;
  late StreamController<List<int>> controller;

  var state = const MessageFramingDecoderState.header([]);

  void _processByte(int byte, EventSink<List<int>> sink) {
    assert(0 <= byte && byte <= 0xFF);

    state = state.map(
      header: (header) {
        final newBytes = [...header.data, byte];

        if (newBytes.length < 4 * 2) {
          return MessageFramingDecoderState.header(newBytes);
        } else {
          final bytes = Uint8List.fromList(newBytes).buffer.asByteData();
          final magic = bytes.getUint32(0, Endian.little);
          if (magic != _magic) {
            sink.addError(Exception("Magic was missing from received data"));
            return const MessageFramingDecoderState.header([]);
          }

          final messageSize = bytes.getUint32(4, Endian.little);
          return MessageFramingDecoderState.message(messageSize, []);
        }
      },
      message: (message) {
        final newState = message.copyWith(data: [...message.data, byte]);

        if (newState.data.length == message.size) {
          sink.add(newState.data);
          return const MessageFramingDecoderState.header([]);
        }

        return newState;
      },
    );
  }

  void processBytes(List<int> input, EventSink<List<int>> sink) {
    for (var byte in input) {
      _processByte(byte, sink);
    }
  }
}

List<int> encodeFramedMessage(List<int> message, int magic) {
  final header = ByteData(2 * 4);
  header.setUint32(0, magic, Endian.little);
  header.setUint32(4, message.length, Endian.little);
  inspect(header);

  return [...header.buffer.asUint8List(), ...message];
}
