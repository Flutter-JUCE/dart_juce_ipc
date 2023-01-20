import "dart:async";
import "dart:io";

import "package:freezed_annotation/freezed_annotation.dart";
import "package:logging/logging.dart";

import "message_framing.dart";

final _log = Logger("juce_ipc.interprocess_connection");

const _defaultHeaderMagic = 0xf2b49e2c;

/// Manages a simple two-way messaging connection to another process.
///
/// See https://docs.juce.com/master/classInterprocessConnection.html
abstract class InterprocessConnection {
  /// The read end of this connection
  Stream<List<int>> get read;

  /// The write end of this connection
  IOSink get write;
}

/// Manages a simple two-way messaging connection to another process using a named pipe.
class InterprocessConnectionNamedPipe implements InterprocessConnection {
  /// Create a new connection
  InterprocessConnectionNamedPipe(
    String pipeName, {
    int magic = _defaultHeaderMagic,
  })  : pipe = File(pipeName),
        _magic = magic,
        _decoder = MessageFramingDecoder(magic: magic) {
    _log.info("Opening pipe $pipeName");
  }

  /// The underlying named pipe resource. Exposed only to be deleted during test
  /// cleanup.
  @visibleForTesting
  final File pipe;
  final int _magic;

  late final Stream<List<int>> _read = pipe.openRead().transform(
        StreamTransformer.fromHandlers(
          handleData: _decoder.processBytes,
        ),
      );

  // The sink is closed by the [_write] [IOSink] automatically.
  // ignore: close_sinks
  late final _controller = StreamController<List<int>>();
  // The sink will be closed by the user of this connection.
  // ignore: close_sinks
  late final _write = IOSink(_controller.sink);

  final MessageFramingDecoder _decoder;

  @override
  Stream<List<int>> get read => _read;

  bool _isSinkSetUp = false;

  @override
  IOSink get write {
    if (!_isSinkSetUp) {
      _isSinkSetUp = true;
      _setUpSink();
    }

    return _write;
  }

  void _setUpSink() {
    final messageStream =
        _controller.stream.map((data) => encodeFramedMessage(data, _magic));

    Future.microtask(() async {
      final fileSink = pipe.openWrite();
      await fileSink.addStream(messageStream);
      await fileSink.flush();
      await fileSink.close();
    });
  }
}
