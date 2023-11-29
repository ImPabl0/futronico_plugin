# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(futronic_library VERSION 0.0.1 LANGUAGES C)

add_library(futronic SHARED
  "futronic.c"
)

set_target_properties(futronic PROPERTIES
  PUBLIC_HEADER futronic.h
  OUTPUT_NAME "futronic"
)

add_library(${PLUGIN_NAME} SHARED
            "FTRAPI.dll"
            "ftrScanAPI.dll")

target_compile_definitions(futronic PUBLIC DART_SHARED_LIB)
