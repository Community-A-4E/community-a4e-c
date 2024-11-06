# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required(VERSION 3.20)

# Enable Hot Reload for MSVC compilers if supported.
if(POLICY CMP0141)
    cmake_policy(SET CMP0141 NEW)
    set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

project(Common DESCRIPTION "A-4E C++ Common Code")

file(GLOB_RECURSE source_list "${CMAKE_CURRENT_SOURCE_DIR}/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE headers_list "${CMAKE_CURRENT_SOURCE_DIR}/*.h" "${CMAKE_CURRENT_SOURCE_DIR}/*.hpp")

add_library(Common STATIC
    ${source_list}
)

if(CMAKE_VERSION VERSION_GREATER 3.12)
    set_property(TARGET Common PROPERTY CXX_STANDARD 23)
endif()

target_compile_definitions(Common PRIVATE UNICODE)
set_target_properties(Common PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
target_include_directories(Common
    PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}"
    PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}"
)