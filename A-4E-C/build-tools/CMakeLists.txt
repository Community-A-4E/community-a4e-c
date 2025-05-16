cmake_minimum_required(VERSION 3.25)

project(md5 DESCRIPTION "Test")
add_library(md5 SHARED "md5_main.c")

if(CMAKE_VERSION VERSION_GREATER 3.12)
    set_property(TARGET md5 PROPERTY CXX_STANDARD 23)
endif()

target_link_libraries(md5 PRIVATE
    Common
    "${CMAKE_CURRENT_SOURCE_DIR}/lua/lua54.lib"
)

target_include_directories(md5 PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/lua/include"
)

set_target_properties(md5 PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")