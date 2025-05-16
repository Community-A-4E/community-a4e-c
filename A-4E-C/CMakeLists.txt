# CMakeList.txt : Top-level CMake project file, do global configuration
# and include sub-projects here.
#
cmake_minimum_required (VERSION 3.25)

file(GLOB_RECURSE source_list "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.c" "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.cpp" )
file(GLOB_RECURSE headers_list "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.h" "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/FM/*.hpp" )

add_library( Scooter SHARED
    ${source_list}
)

if (CMAKE_VERSION VERSION_GREATER 3.12)
    set_property(TARGET Scooter PROPERTY CXX_STANDARD 23)
endif()

target_compile_definitions(Scooter PRIVATE ED_FM_EXPORTS ED_FM_TEMPLATE_EXPORTS UNICODE _SILENCE_CXX23_DENORM_DEPRECATION_WARNING)
set_target_properties(Scooter PROPERTIES MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")

set(LUA_IMGUI_BIN_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin")

add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/Common")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/Cockpit/Scripts/LuaImGui" "${CMAKE_CURRENT_BINARY_DIR}/Cockpit/Scripts/LuaImGui")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/Avionics" "${CMAKE_CURRENT_BINARY_DIR}/ExternalFM/Avionics")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/build-tools" "${CMAKE_CURRENT_BINARY_DIR}/build-tools")
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/Verify" "${CMAKE_CURRENT_BINARY_DIR}/ExternalFM/Verify")

# target_link_directories( Scooter PRIVATE  )
set(SCOOTER_LIBS
    "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/libs/CockpitBase.lib"
    "${CMAKE_CURRENT_SOURCE_DIR}/Cockpit/Scripts/LuaImGui/ext/dcs-lua/lua.lib"
    Common
    Verify
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

# ## Add lua auto-generation as a dependable target
set(lua_autogen_dep
    "${CMAKE_CURRENT_SOURCE_DIR}/Cockpit/Scripts/devices.lua"
    "${CMAKE_CURRENT_SOURCE_DIR}/Cockpit/Scripts/command_defs.lua"
    "${CMAKE_CURRENT_SOURCE_DIR}/entry.lua"
    "${CMAKE_CURRENT_SOURCE_DIR}/A-4E-C.lua"
    "${CMAKE_CURRENT_SOURCE_DIR}/Cockpit/Scripts/EFM_Data_Bus.lua"
    "${CMAKE_CURRENT_SOURCE_DIR}/Entry/Suspension.lua"
    "${CMAKE_CURRENT_SOURCE_DIR}/Weapons/A4E_Weapons.lua"
)

set(lua_autogen_list
    "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/Common/Common/Devices.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/Common/Common/Commands.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/Common/Common/Hashes.h"
)

set(lua_gen_command "${CMAKE_CURRENT_SOURCE_DIR}/build-tools/generate_headers.bat")

add_custom_command(
        OUTPUT ${lua_autogen_list}
        DEPENDS ${lua_autogen_dep}
        COMMAND ${lua_gen_command} ${CMAKE_SOURCE_DIR}
)

add_custom_target(generate_headers DEPENDS ${lua_autogen_list})

add_dependencies(generate_headers md5)
add_dependencies(Scooter generate_headers)

target_include_directories(Scooter PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/ext/eigen-master/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/Cockpit/Scripts/LuaImGui/ext/dcs-lua/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/ExternalFM/include"
)


add_custom_command(TARGET Scooter POST_BUILD
    COMMAND "${CMAKE_COMMAND}"
    -E copy "$<TARGET_FILE:Scooter>" "${CMAKE_CURRENT_SOURCE_DIR}/bin/$<TARGET_FILE_NAME:Scooter>"
    COMMENT "Copying LuaImGui to bin"
)