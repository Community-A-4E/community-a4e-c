# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required(VERSION 3.25)

project(Verify DESCRIPTION "Hashing")

file(GLOB_RECURSE source_list "${CMAKE_CURRENT_SOURCE_DIR}/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE headers_list "${CMAKE_CURRENT_SOURCE_DIR}/*.h" "${CMAKE_CURRENT_SOURCE_DIR}/*.hpp")

add_library(Verify STATIC
    ${source_list}
)

if(CMAKE_VERSION VERSION_GREATER 3.12)
    set_property(TARGET Verify PROPERTY CXX_STANDARD 23)
endif()

target_compile_definitions(Verify PRIVATE UNICODE)
set_target_properties(Verify PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
target_include_directories(Verify
    PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}"
    PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(Verify PRIVATE Common)