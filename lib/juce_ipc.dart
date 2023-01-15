import 'dart:async';
import 'dart:io';

import 'package:juce_ipc/src/message_framing.dart';

const _defaultHeaderMagic = 0xf2b49e2c;

/// Manages a simple two-way messaging connection to another process.
///
/// See https://docs.juce.com/master/classInterprocessConnection.html
abstract class JuceInterprocessConnection {
  Stream<List<int>> get read;
  IOSink get write;
}

/// Manages a simple two-way messaging connection to another process using a named pipe.
class JuceInterprocessConnectionNamedPipe
    implements JuceInterprocessConnection {
  JuceInterprocessConnectionNamedPipe(String pipeName,
      {this.magic = _defaultHeaderMagic})
      : _pipe = File(pipeName),
        _decoder = MessageFramingDecoder(magic: magic);

  final File _pipe;
  final int magic;

  late final Stream<List<int>> _read = _pipe.openRead().transform(
    StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        _decoder.processBytes(data, sink);
      },
    ),
  );

  late final _fileSink = _pipe.openWrite();
  // Controller must not be broadcast while we use shared state and
  // [StreamTransformer.fromHandlers] on it.
  late final _controller = StreamController<List<int>>();
  late final _write = IOSink(_controller.sink);

  final MessageFramingDecoder _decoder;

  @override
  Stream<List<int>> get read => _read;

  bool sinkSetUp = false;

  @override
  IOSink get write {
    if (!sinkSetUp) {
      sinkSetUp = true;
      _setUpSink();
    }

    return _write;
  }

  void _setUpSink() {
    final messageStream = _controller.stream.transform(
      StreamTransformer<List<int>, List<int>>.fromHandlers(
        handleData: (data, sink) {
          sink.add(encodeFramedMessage(data, magic));
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
