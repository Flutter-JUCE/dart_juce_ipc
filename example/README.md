# juce_ipc Example

This example implement the child process from the
[ChildProcessDemo](https://github.com/juce-framework/JUCE/blob/69795dc8e589a9eb5df251b6dd994859bf7b3fab/examples/Utilities/ChildProcessDemo.h)
JUCE example.

## Running the example

1. Build the example for release: e.g. `flutter build linux`
1. Build host application after changing the current directory to `tool/host`: `cmake -G Ninja -B build && cmake --build build`
1. Run the host application: `./build/ChildProcessDemo_artefacts/ChildProcessDemo`
1. (optional) Observe the child process logs: `tail -f /tmp/juce_ipc_logs`
