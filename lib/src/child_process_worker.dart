import "dart:async";
import "dart:convert";
import "dart:io";

import "package:collection/collection.dart";
import "package:logging/logging.dart";
import "package:path/path.dart" as p;

import "debug_print.dart";
import "interprocess_connection.dart";
import "path.dart";

/// The magic number used by the coordinator when creating its
/// [InterprocessConnectionNamedPipe].
const kConnectionMagic = 0x712baf04;

/// Message sent by the coordinator after connecting to the ChildProcessWorker
const kStartMessage = "__ipc_st";

/// Message sent by the coordinator when it wants the ChildProcessWorker to exit
const kKillMessage = "__ipc_k_";

/// Message sent periodically by the coordinator. The ChildProcessWorker must
/// respond with the same message, or it will be killed.
const kPingMessage = "__ipc_p_";

/// The length of internal messages sent by the coordinator.
const specialMessageLength = 8;

final _log = Logger("juce_ipc.child_process_worker");

/// Acts as the worker end of a coordinator/worker pair of connected processes.
///
/// See https://docs.juce.com/master/classChildProcessWorker.html,
/// https://docs.juce.com/master/classChildProcessCoordinator.html
class ChildProcessWorker implements InterprocessConnection {
  ChildProcessWorker._({
    required Stream<List<int>> readStream,
    required InterprocessConnection writeConnection,
  })  : _readStream = readStream,
        _writeConnection = writeConnection;

  /// Create a worker from command line arguments passed by the coordinator.
  ///
  /// The returned Future completes when the named pipe used to communicate with
  /// the coordinator is connected on sides, and the connection is ready to send
  /// messages.
  ///
  /// Null will be returned if the command line arguments do not appear to come
  /// from a coordinator.
  ///
  /// A TimeoutException is thrown if the coordinator does not send a start
  /// message within the configured timeout.
  static Future<ChildProcessWorker?> fromCommandLineArguments(
    List<String> arguments, {
    required String uniqueId,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    _log.finer("Trying to create ChildProcessWorker from arguments: "
        "$arguments with unique ID $uniqueId");

    if (arguments.isEmpty) {
      _log.warning("Can't create ChildProcessWorker, arguments are empty");
      return Future.value();
    }

    if (!arguments.first.startsWith("--$uniqueId:")) {
      _log.warning("Can't create ChildProcessWorker, arguments do not contain "
          "the configured unique ID");
      return Future.value();
    }

    final pipeName = arguments.first.split(":").last;
    _log.info("Opening pipes with name: $pipeName");

    final temporaryDirectoryPath = getTemporaryDirectory();
    _log.info("Using temporary directory path: $temporaryDirectoryPath");
    final readConnection = InterprocessConnectionNamedPipe(
      p.join(temporaryDirectoryPath, "${pipeName}_out"),
      magic: kConnectionMagic,
    );

    final writeConnection = InterprocessConnectionNamedPipe(
      p.join(temporaryDirectoryPath, "${pipeName}_in"),
      magic: kConnectionMagic,
    );

    final readController = StreamController<List<int>>.broadcast();
    final readSubscription = readConnection.read.listen(
      readController.add,
      onDone: readController.close,
    );

    readController.stream
      ..map((e) => "received ${e.toHex()}").listen(_log.fine)
      ..listen((e) {
        if (const ListEquality<int>().equals(e, utf8.encode(kPingMessage))) {
          writeConnection.write.write(kPingMessage);
        }
      })
      ..listen((e) {
        if (const ListEquality<int>().equals(e, utf8.encode(kKillMessage))) {
          _log.info("received kill message");

          // TODO close the read stream. How?
          // check io docs. maybe unlisten the stream?
          // Right now, the user listener is causing the broadcast stream to stay
          // alive. We want to ignore that, and close it regardless, emitting a
          // done event. Do we need to refactor and have a broadcast controller to
          // close?
          readSubscription.cancel();
          readController.close();
        }
      });

    final startMessage = readController.stream.firstWhere(
      (e) => const ListEquality<int>().equals(e, utf8.encode(kStartMessage)),
    );

    // Throw TimeoutException if coordinator did not send the start message
    // within the timeout
    try {
      await startMessage.timeout(timeout);
    } on TimeoutException {
      await readSubscription.cancel();
      await readController.close();
      rethrow;
    }

    return Future.value(
      ChildProcessWorker._(
        readStream: readController.stream,
        writeConnection: writeConnection,
      ),
    );
  }

  final Stream<List<int>> _readStream;
  final InterprocessConnection _writeConnection;

  // Start message is not filtered, because only one is ever sent, and it is
  // already received in the fromCommandLineArguments static factory
  late final _readData = _readStream.where(
    (e) =>
        !const ListEquality<int>().equals(e, utf8.encode(kPingMessage)) &&
        !const ListEquality<int>().equals(e, utf8.encode(kKillMessage)),
  );

  /// Stream of messages sent by the coordinator.
  ///
  /// This will close when the connection to the coordinator is lost, or when
  /// the coordinator sends a kill message. In either case, the child process
  /// should exit.
  @override
  Stream<List<int>> get read => _readData;

  /// A sink for sending messages to the coordinator.
  @override
  IOSink get write => _writeConnection.write;
}
