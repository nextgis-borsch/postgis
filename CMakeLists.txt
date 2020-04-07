################################################################################
# CMakeLists.txt - root CMake configuration file, part PostGIS project
#
# Copyright (C) 2016-2020, NextGIS <info@nextgis.com>
################################################################################
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
project(postgis NONE)

# Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

include(util)
check_version(POSTGIS_MAJOR_VERSION POSTGIS_MINOR_VERSION POSTGIS_MICRO_VERSION)
