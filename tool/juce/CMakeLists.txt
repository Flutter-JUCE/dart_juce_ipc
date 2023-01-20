cmake_minimum_required(VERSION 3.15)
project(CHILD_PROCESS_DEMO VERSION 1.0.0 LANGUAGES CXX)

# std::filesystem
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(JUCE)

juce_add_pip(ChildProcessDemo.h)
