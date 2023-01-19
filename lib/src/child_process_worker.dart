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

// TODO how to implement the lost callback?

// TODO implement timeout when coordinator does not send pings
class ChildProcessWorker implements InterprocessConnection {
  ChildProcessWorker._({
    required Stream<List<int>> readConnection,
    required InterprocessConnection writeConnection,
    required StreamSubscription<String> loggingSubscription,
  })  : _readConnection = readConnection,
        _writeConnection = writeConnection,
        _loggingSubscription = loggingSubscription;

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

    final readBroadcast = readConnection.read
        .asBroadcastStream(onCancel: (subscription) => subscription.cancel());

    final loggingSubscription =
        readBroadcast.map((e) => "received ${e.toHex()}").listen(
              _log.fine,
            );

    final pingingSubscription = readBroadcast.listen((e) {
      if (const ListEquality<int>().equals(e, utf8.encode(kPingMessage))) {
        writeConnection.write.write(kPingMessage);
      }
    });

    final killSubscription = readBroadcast.listen((e) {
      if (const ListEquality<int>().equals(e, utf8.encode(kKillMessage))) {
        _log.warning("received kill message");
        // TODO close the read stream, or implement some other way of notifying
        // the user about the coordinator going away
      }
    });

    final startMessageCompleter = Completer<void>();
    final startMessageSubscription = readBroadcast.listen((e) {
      if (const ListEquality<int>().equals(e, utf8.encode(kStartMessage))) {
        startMessageCompleter.complete();
      }
    });

    // Throw TimeoutException if coordinator did not send the start message
    // within the timeout
    try {
      await startMessageCompleter.future.timeout(timeout);
    } on TimeoutException {
      await loggingSubscription.cancel();
      await pingingSubscription.cancel();
      await killSubscription.cancel();
      rethrow;
    } finally {
      await startMessageSubscription.cancel();
    }

    return Future.value(
      ChildProcessWorker._(
        readConnection: readBroadcast,
        writeConnection: writeConnection,
        loggingSubscription: loggingSubscription,
      ),
    );
  }

  final Stream<List<int>> _readConnection;
  final InterprocessConnection _writeConnection;
  // TODO close this subscription at some point
  // ignore: unused_field
  final StreamSubscription<String> _loggingSubscription;

  // TODO also filter out the kill message
  late final _readData = _readConnection.where(
    (e) =>
        e.length != specialMessageLength ||
        !const ListEquality<int>().equals(e, utf8.encode(kPingMessage)),
  );

  /// Stream of messages sent by the coordinator.
  ///
  /// This will close when the connection to the coordinator is lost.

  // TODO probably need a streamcontroller here to close all the internal
  // subscriptions when this subscription is closed
  @override
  Stream<List<int>> get read => _readData;

  /// A sink for sending messages to the coordinator.
  @override
  IOSink get write => _writeConnection.write;
}
