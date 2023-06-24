cmake_minimum_required(VERSION 3.15)
project(CHILD_PROCESS_DEMO VERSION 1.0.0 LANGUAGES CXX)

# std::filesystem
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(JUCE)
add_subdirectory(juce-end-to-end)

add_library (juce_modules STATIC)
add_library (focusrite-e2e::juce_modules ALIAS juce_modules)

target_link_libraries (juce_modules PRIVATE juce::juce_gui_basics)

# We're linking the modules privately, but we need to export their compile flags
target_compile_definitions (
  juce_modules PUBLIC JUCE_WEB_BROWSER=0 JUCE_USE_CURL=0
  INTERFACE $<TARGET_PROPERTY:juce_modules,COMPILE_DEFINITIONS>)

# We also need to export the include directories for the modules
target_include_directories (
  juce_modules INTERFACE $<TARGET_PROPERTY:juce_modules,INCLUDE_DIRECTORIES>)


juce_add_gui_app (child-process-demo VERSION 0.0.0)

target_sources (
    child-process-demo PRIVATE ./ChildProcessDemo.cpp)

target_include_directories (child-process-demo PRIVATE source)

target_link_libraries (child-process-demo PRIVATE focusrite-e2e)

target_compile_definitions (
  child-process-demo
  PRIVATE
    JUCE_APPLICATION_NAME_STRING="$<TARGET_PROPERTY:child-process-demo,JUCE_PRODUCT_NAME>"
    JUCE_APPLICATION_VERSION_STRING="$<TARGET_PROPERTY:child-process-demo,JUCE_VERSION>"
)

target_link_libraries (
  child-process-demo PRIVATE juce_modules
  PUBLIC juce::juce_recommended_config_flags juce::juce_recommended_lto_flags
         juce::juce_recommended_warning_flags)

set_target_properties (child-process-demo PROPERTIES CXX_STANDARD 17)
