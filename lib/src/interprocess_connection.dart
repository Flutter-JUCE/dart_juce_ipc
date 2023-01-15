import "dart:async";
import "dart:io";

import "message_framing.dart";

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
  })  : _pipe = File(pipeName),
        _magic = magic,
        _decoder = MessageFramingDecoder(magic: magic);

  final File _pipe;
  final int _magic;

  late final Stream<List<int>> _read = _pipe.openRead().transform(
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
      final fileSink = _pipe.openWrite();
      await fileSink.addStream(messageStream);
      await fileSink.flush();
      await fileSink.close();
    });
  }
}

/// Manages a simple two-way messaging connection to another process using a socket.
class JuceInterprocessConnectionSocket implements InterprocessConnection {
  @override
  // TODO: implement read
  Stream<List<int>> get read => throw UnimplementedError();

  @override
  // TODO: implement write
  IOSink get write => throw UnimplementedError();
}
