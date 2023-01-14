#include "include/juce_ipc/juce_ipc_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define JUCE_IPC_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), juce_ipc_plugin_get_type(), \
                              JuceIpcPlugin))

struct _JuceIpcPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(JuceIpcPlugin, juce_ipc_plugin, g_object_get_type())

static FlMethodResponse *handle_get_platform_version(FlMethodCall *method_call);
static FlMethodResponse *handle_say_hello_and_return_count(FlMethodCall *method_call);

// Called when a method call is received from Flutter.
static void juce_ipc_plugin_handle_method_call(
    JuceIpcPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0) {
    response = handle_get_platform_version(method_call);
  } else if (strcmp(method, "sayHelloAndReturnCount") == 0) {
    response = handle_say_hello_and_return_count(method_call);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}


static FlMethodResponse *handle_get_platform_version(FlMethodCall *method_call) {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    // TODO WTF is the memory ownership model in the flutter API? It's not
    // documented. Is this invalid? result is freed when we return, while a copy
    // of it may be returned inside the new response.
    g_autoptr(FlValue) result = fl_value_new_string(version);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static FlMethodResponse *handle_say_hello_and_return_count(FlMethodCall *method_call) {
    const auto args = fl_method_call_get_args(method_call);
    const auto type = fl_value_get_type(args);
    if(type != FL_VALUE_TYPE_STRING)
    {
        return FL_METHOD_RESPONSE(fl_method_error_response_new(
                    "",
                    "Arg must be a string",
                    nullptr));
    }
    const auto greeting = fl_value_get_string(args);
    
    g_print("type: %d\n", type);
    
    g_print("%s\n", greeting);

    static int count = 0;
    count++;
    g_autoptr(FlValue) result = fl_value_new_int(count);
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
}

static void juce_ipc_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(juce_ipc_plugin_parent_class)->dispose(object);
}

static void juce_ipc_plugin_class_init(JuceIpcPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = juce_ipc_plugin_dispose;
}

static void juce_ipc_plugin_init(JuceIpcPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  JuceIpcPlugin* plugin = JUCE_IPC_PLUGIN(user_data);
  juce_ipc_plugin_handle_method_call(plugin, method_call);
}

void juce_ipc_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  JuceIpcPlugin* plugin = JUCE_IPC_PLUGIN(
      g_object_new(juce_ipc_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "juce_ipc",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
