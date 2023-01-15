import "dart:async";
import "dart:io";

import "src/message_framing.dart";

const _defaultHeaderMagic = 0xf2b49e2c;

/// Manages a simple two-way messaging connection to another process.
///
/// See https://docs.juce.com/master/classInterprocessConnection.html
abstract class JuceInterprocessConnection {
  /// The read end of this connection
  Stream<List<int>> get read;

  /// The write end of this connection
  IOSink get write;
}

/// Manages a simple two-way messaging connection to another process using a named pipe.
class JuceInterprocessConnectionNamedPipe
    implements JuceInterprocessConnection {
  /// Create a new connection
  JuceInterprocessConnectionNamedPipe(String pipeName,
      {int magic = _defaultHeaderMagic,})
      : _pipe = File(pipeName),
        _magic = magic,
        _decoder = MessageFramingDecoder(magic: magic);

  final File _pipe;
  final int _magic;

  late final Stream<List<int>> _read = _pipe.openRead().transform(
    StreamTransformer.fromHandlers(
      handleData: _decoder.processBytes,
    ),
  );

  late final _fileSink = _pipe.openWrite();
  // Controller must not be broadcast while we use shared state and
  // [StreamTransformer.fromHandlers] on it.
  //
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
    final messageStream = _controller.stream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          sink.add(encodeFramedMessage(data, _magic));
        },
        handleDone: (sink) => sink.close(),
      ),
    );

    Future.microtask(() async {
      await _fileSink.addStream(messageStream);
      await _fileSink.flush();
      await _fileSink.close();
    });
  }
}

/// Manages a simple two-way messaging connection to another process using a socket.
class JuceInterprocessConnectionSocket implements JuceInterprocessConnection {
  @override
  // TODO: implement read
  Stream<List<int>> get read => throw UnimplementedError();

  @override
  // TODO: implement write
  IOSink get write => throw UnimplementedError();
}
