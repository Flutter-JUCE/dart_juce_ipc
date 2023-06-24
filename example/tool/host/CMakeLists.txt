cmake_minimum_required(VERSION 3.15)
project(CHILD_PROCESS_DEMO VERSION 1.0.0 LANGUAGES CXX)

# std::filesystem
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(JUCE)

include (FetchContent)
FetchContent_Declare (juce-end-to-end
                      GIT_REPOSITORY https://github.com/FocusriteGroup/juce-end-to-end
                      GIT_TAG v0.0.15)

FetchContent_MakeAvailable (juce-end-to-end)

juce_add_pip(ChildProcessDemo.h)
target_link_libraries(ChildProcessDemo PRIVATE focusrite-e2e::focusrite-e2e)

