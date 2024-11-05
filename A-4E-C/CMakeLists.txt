# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.25)

#set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Enable Hot Reload for MSVC compilers if supported.
# if (POLICY CMP0141)
#   cmake_policy(SET CMP0141 NEW)
#   set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
# endif()

project(Scooter DESCRIPTION "A-4E C++ Project")

file(GLOB_RECURSE source_list "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.cpp" )
file(GLOB_RECURSE headers_list "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.h" "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.hpp" )


# set(FMGUI_SRC_PATH "${CMAKE_SOURCE_DIR}/ext/DCS-EFM-ImGui/")
# set(FMGUI_SRC
#     Source/FmGui.cpp
# )
# list(TRANSFORM FMGUI_SRC PREPEND ${FMGUI_SRC_PATH})

# set(IMPLOT_SRC_PATH "${CMAKE_SOURCE_DIR}/ext/implot/")
# set(IMPLOT_SRC
#     implot.cpp
#     implot_items.cpp
# )
# list(TRANSFORM IMPLOT_SRC PREPEND ${IMPLOT_SRC_PATH})

# set(IMGUI_SRC_PATH "${CMAKE_SOURCE_DIR}/ext/imgui/")
# set(IMGUI_SRC
#     backends/imgui_impl_dx11.cpp
#     backends/imgui_impl_win32.cpp
#     imgui.cpp
#     imgui_demo.cpp
#     imgui_draw.cpp
#     imgui_tables.cpp
#     imgui_widgets.cpp
# )
# list(TRANSFORM IMGUI_SRC PREPEND ${IMGUI_SRC_PATH})



add_library( Scooter SHARED
    ${source_list}
)

if (CMAKE_VERSION VERSION_GREATER 3.12)
    set_property(TARGET Scooter PROPERTY CXX_STANDARD 23)
endif()

#set_target_properties(Scooter PROPERTIES OUTPUT_NAME "A-4E-C")
# set_target_properties(Scooter PROPERTIES
#     ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
#     LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin"
#     RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")

target_compile_definitions(Scooter PRIVATE ED_FM_EXPORTS ED_FM_TEMPLATE_EXPORTS UNICODE _SILENCE_CXX23_DENORM_DEPRECATION_WARNING)

add_subdirectory("${CMAKE_SOURCE_DIR}/ExternalFM/Common")

add_subdirectory("${CMAKE_SOURCE_DIR}/Cockpit/Scripts/LuaImGui" "${CMAKE_BINARY_DIR}/Cockpit/Scripts/LuaImGui")
add_subdirectory("${CMAKE_SOURCE_DIR}/ExternalFM/Avionics" "${CMAKE_BINARY_DIR}/ExternalFM/Avionics")

# target_link_directories( Scooter PRIVATE  )
set(SCOOTER_LIBS
    "${CMAKE_SOURCE_DIR}/ExternalFM/libs/CockpitBase.lib"
    "${CMAKE_SOURCE_DIR}/Cockpit/Scripts/LuaImGui/ext/dcs-lua/lua.lib"
    Common
    ScooterAvionics
    LuaImGui
)

# 
# option(SCOOTER_IMGUI_ENABLED "Whether the ImGui is Enabled." true)
# if(${SCOOTER_IMGUI_ENABLED})
#     list(APPEND SCOOTER_LIBS LuaImGui)
# endif()

# option(SCOOTER_AVIONICS_ENABLED "Whether the ScooterAvionics Hacks are Enabled." true)

# if(${SCOOTER_AVIONICS_ENABLED})
#     
#     list(APPEND SCOOTER_LIBS ScooterAvionics)
# endif()

target_link_libraries(Scooter
    PRIVATE
    ${SCOOTER_LIBS}
)

MESSAGE(INFO " ${SCOOTER_LIBS}")

### Add lua auto-generation as a dependable target
set(lua_autogen_dep
        "${CMAKE_SOURCE_DIR}/Cockpit/Scripts/devices.lua"
        "${CMAKE_SOURCE_DIR}/Cockpit/Scripts/command_defs.lua"
)

set(lua_autogen_list
        "${CMAKE_SOURCE_DIR}/ExternalFM/Common/Common/Devices.h"
        "${CMAKE_SOURCE_DIR}/ExternalFM/Common/Common/Commands.h"
)

set(lua_gen_command "${CMAKE_SOURCE_DIR}/build-tools/generate_headers.bat")

add_custom_command(
        OUTPUT ${lua_autogen_list}
        DEPENDS ${lua_autogen_dep}
        COMMAND ${lua_gen_command} ${CMAKE_SOURCE_DIR}
)

add_custom_target(generate_headers DEPENDS ${lua_autogen_list})
add_dependencies(Scooter generate_headers)

target_include_directories(Scooter PRIVATE
    "${CMAKE_SOURCE_DIR}/ExternalFM/ext/eigen-master/include"
    "${CMAKE_SOURCE_DIR}/Cockpit/Scripts/LuaImGui/ext/dcs-lua/include"
    "${CMAKE_SOURCE_DIR}/ExternalFM/include"
)


add_custom_command( TARGET Scooter POST_BUILD
    COMMAND "${CMAKE_COMMAND}"
    -E copy "$<TARGET_FILE:Scooter>" "${CMAKE_SOURCE_DIR}/bin/$<TARGET_FILE_NAME:Scooter>" 
    COMMENT "Copying LuaImGui to bin"
)