cmake_minimum_required(VERSION 3.15)
project(GUI_APP_EXAMPLE VERSION 0.0.1)

# If you've installed JUCE somehow (via a package manager, or directly using the CMake install
# target), you'll need to tell this project that it depends on the installed copy of JUCE. If you've
# included JUCE directly in your source tree (perhaps as a submodule), you'll need to tell CMake to
# include that subdirectory as part of the build.

find_package(JUCE CONFIG REQUIRED)        # If you've installed JUCE to your system
# or
# add_subdirectory(JUCE)                    # If you've put JUCE in a subdirectory called JUCE

juce_add_pip(ChildProcessDemo.h)

#target_compile_definitions(GuiAppExample
#    PRIVATE
#        JUCE_WEB_BROWSER=0
#        JUCE_USE_CURL=0
#        JUCE_APPLICATION_NAME_STRING="ChildProcessDemo"
#        JUCE_APPLICATION_VERSION_STRING="")
