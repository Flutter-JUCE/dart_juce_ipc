import "dart:io";

import "package:logging/logging.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";

import "interprocess_connection.dart";

const _connectionMagic = 0x712baf04;

final _log = Logger("juce_ipc.child_process_worker");

/// Acts as the worker end of a coordinator/worker pair of connected processes.
///
/// See https://docs.juce.com/master/classChildProcessWorker.html,
/// https://docs.juce.com/master/classChildProcessCoordinator.html
class ChildProcessWorker implements InterprocessConnection {
  ChildProcessWorker._({
    required InterprocessConnection readConnection,
    required InterprocessConnection writeConnection,
  })  : _readConnection = readConnection,
        _writeConnection = writeConnection;

  /// Create a worker from command line arguments passed by the coordinator.
  ///
  /// The returned Future completes when the named pipe used to communicate with
  /// the coordinator is connected on sides, and the connection is ready to send
  /// messages.
  ///
  /// Null will be returned if the command line arguments do not appear to come
  /// from a coordinator.
  static Future<ChildProcessWorker?> fromCommandLineArguments(
    String uniqueId,
    List<String> arguments,
  ) async {
    if (arguments.isEmpty) return Future.value();
    if (!arguments.first.startsWith("--$uniqueId:")) return Future.value();
    final pipeName = arguments.first.split(":").last;
    _log.fine("Opening pipes with name: $pipeName");

    // TODO:
    // * Add tests for all platforms that JUCE and path_provider return the same
    //   temporary file path
    final temporaryDirectoryPath = (await getTemporaryDirectory()).path;
    _log.fine("Using temporary directory path: $temporaryDirectoryPath");
    final readConnection = InterprocessConnectionNamedPipe(
      p.join(temporaryDirectoryPath, "${pipeName}_out"),
      magic: _connectionMagic,
    );

    final writeConnection = InterprocessConnectionNamedPipe(
      p.join(temporaryDirectoryPath, "${pipeName}_in"),
      magic: _connectionMagic,
    );

    // TODO
    // * handle the messages for setup correctly
    // * Do not expose internal messages to the user
    return Future.value(
      ChildProcessWorker._(
        readConnection: readConnection,
        writeConnection: writeConnection,
      ),
    );
  }

  final InterprocessConnection _readConnection;
  final InterprocessConnection _writeConnection;

  @override

  /// Stream of messages sent by the coordinator.
  ///
  /// This will close when the connection to the coordinator is lost.
  Stream<List<int>> get read => _readConnection.read;

  @override

  /// A sink for sending messages to the coordinator.
  IOSink get write => _writeConnection.write;
}
