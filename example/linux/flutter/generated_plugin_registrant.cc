//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <juce_ipc/juce_ipc_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) juce_ipc_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "JuceIpcPlugin");
  juce_ipc_plugin_register_with_registrar(juce_ipc_registrar);
}
