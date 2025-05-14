cmake_minimum_required(VERSION 3.25)

project(Scooter DESCRIPTION "A-4E C++ Project")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_compile_definitions(LUA_IMGUI_DISABLED)

add_subdirectory("${CMAKE_SOURCE_DIR}/A-4E-C")