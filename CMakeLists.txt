################################################################################
# CMakeLists.txt - root CMake configuration file, part PostGIS project
#
# Copyright (C) 2012 Mateusz Loskot <mateusz@loskot.net>
# Copyright (C) 2016, NextGIS <info@nextgis.com>
################################################################################
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
project(postgis C)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} 
     ${CMAKE_SOURCE_DIR}/cmake 
     ${CMAKE_SOURCE_DIR}/cmake/modules
    )
    
include(GNUInstallDirs)

set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}" CACHE INTERNAL "Installation directory for headers" FORCE)

################################################################################
# User options to control PostGIS features

option(POSTGIS_WITH_RASTER
    "Set ON|OFF (default=OFF) to control building raster extension" ON)

option(POSTGIS_WITH_TOPOLOGY
    "Set ON|OFF (default=OFF) to control building topology extension" ON)
    
option(POSTGIS_ENABLE_STATS
    "Set ON|OFF (default=ON) to control use ANALYZE statistics" ON)
set(POSTGIS_USE_STATS 1)
if(NOT POSTGIS_ENABLE_STATS)
    set(POSTGIS_USE_STATS 0)
endif()

option(POSTGIS_ENABLE_AUTOCACHE_BBOX
    "Set ON|OFF (default=ON) to control BBOX caching within geometries" ON)
set(POSTGIS_AUTOCACHE_BBOX 1)
if(NOT POSTGIS_ENABLE_AUTOCACHE_BBOX)
    set(POSTGIS_AUTOCACHE_BBOX 0)
endif()

option(POSTGIS_ENABLE_PROFILE
  "Set ON|OFF (default=OFF) to control use GEOS profiling" OFF)
set(POSTGIS_PROFILE 0)
if(POSTGIS_ENABLE_PROFILE)
    set(POSTGIS_PROFILE 1)
endif()

option(POSTGIS_ENABLE_DEBUG
  "Set ON|OFF (default=OFF) to control verbose debugging messages" OFF)
set(POSTGIS_DEBUG_LEVEL 0)
if(POSTGIS_ENABLE_DEBUG)
    set(POSTGIS_DEBUG_LEVEL 4)
endif()


################################################################################
# Version and build date information

include(util)
check_version(POSTGIS_MAJOR_VERSION POSTGIS_MINOR_VERSION POSTGIS_MICRO_VERSION)
  
set(POSTGIS_USE_PROJ 1) # Proj.4 is required
set(POSTGIS_USE_GEOS 1) # GEOS is required
  
set(POSTGIS_VERSION "${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION} USE_GEOS=${POSTGIS_USE_GEOS} USE_PROJ=${POSTGIS_USE_PROJ} USE_STATS=${POSTGIS_USE_STATS}")
set(POSTGIS_LIB_VERSION "${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}.${POSTGIS_MICRO_VERSION}")
set(POSTGIS_SCRIPTS_VERSION "${POSTGIS_LIB_VERSION}")

report_version(${PROJECT_NAME} ${POSTGIS_VERSION})  

set(TARGET_OBJECTS)

include(FindAnyProject)
include(PostGISUtilities)

if(NOT SUPRESS_VERBOSE_OUTPUT)
    message(STATUS)
    colormsg(_HIBLUE_ "Configuring PostGIS:")
    message(STATUS)
endif()

################################################################################
# Dependency (required): PostgreSQL
#OLD: find_program(PG_CONFIG pg_config)
#if(NOT PG_CONFIG)
#    message(FATAL ERROR " Please check your PostgreSQL installation    ") 
#endif(NOT PG_CONFIG)
find_package(PostgreSQL) # TODO: req version?
if(NOT PG_CONFIG)
    message(FATAL ERROR " Please check your PostgreSQL installation")
endif(NOT PG_CONFIG)

exec_program(${PG_CONFIG} ARGS --version OUTPUT_VARIABLE _PGSQL_VERSION_OUTPUT)

string(REGEX REPLACE 
    "^PostgreSQL[\t ]+([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1.\\2.\\3"
    PGSQL_VERSION "${_PGSQL_VERSION_OUTPUT}")
unset(_PGSQL_VERSION_OUTPUT)

if(PGSQL_VERSION)
    string(REGEX REPLACE
        "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1"
        PGSQL_VERSION_MAJOR "${PGSQL_VERSION}")
    string(REGEX REPLACE
        "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\2"
        PGSQL_VERSION_MINOR "${PGSQL_VERSION}")

    set(POSTGIS_PGSQL_VERSION ${PGSQL_VERSION_MAJOR}${PGSQL_VERSION_MINOR})
endif()

exec_program(${PG_CONFIG} ARGS --includedir
    OUTPUT_VARIABLE PGSQL_INCLUDEDIR)
exec_program(${PG_CONFIG} ARGS --includedir-server
    OUTPUT_VARIABLE PGSQL_INCLUDEDIR_SERVER)

include_directories(${PGSQL_INCLUDEDIR})
include_directories(${PGSQL_INCLUDEDIR_SERVER})
if(WIN32)
    include_directories(${PGSQL_INCLUDEDIR_SERVER}/port/win32)
    if(MSVC)    
        include_directories(${PGSQL_INCLUDEDIR_SERVER}/port/win32_msvc)
    endif()
endif()

exec_program(${PG_CONFIG} ARGS --pkglibdir OUTPUT_VARIABLE PGSQL_PKGLIBDIR)
exec_program(${PG_CONFIG} ARGS --sharedir OUTPUT_VARIABLE PGSQL_SHAREDIR)

################################################################################
# Dependency (required): PROJ.4
find_anyproject(PROJ4 VERSION 4.6 REQUIRED)
################################################################################
# Dependency (required): GEOS
find_anyproject(GEOS VERSION 3.4 REQUIRED)

################################################################################
# Dependency (optional): GDAL
if(POSTGIS_WITH_RASTER)
    find_anyproject(GDAL DEFAULT ON)
    if(NOT GDAL_FOUND)
        set(POSTGIS_WITH_RASTER OFF)
    endif()
endif()

# Determine build date and time
string(TIMESTAMP POSTGIS_BUILD_DATE "%Y-%m-%d %H:%M:%S" UTC)

################################################################################
# Predefined constants
set(SRID_MAX 999999)
set(SRID_USR_MAX 998999)

################################################################################
# Generate config header
configure_file(${CMAKE_SOURCE_DIR}/cmake/postgis_config.h.cmake
    ${CMAKE_BINARY_DIR}/postgis_config.h @ONLY)
configure_file(${CMAKE_SOURCE_DIR}/cmake/uninstall.cmake.in 
    ${CMAKE_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)
    
include_directories(${CMAKE_CURRENT_BINARY_DIR})


################################################################################
# Configure all subdirectories with any build targets
### Object libraries
add_subdirectory(liblwgeom)

get_property(LIBLWGEOM_INCLUDE_DIRS GLOBAL PROPERTY LIBLWGEOM_INCLUDE_DIRS)
include_directories(${LIBLWGEOM_INCLUDE_DIRS})

add_subdirectory(libpgcommon)

get_property(LIBPGCOMMON_INCLUDE_DIRS GLOBAL PROPERTY LIBPGCOMMON_INCLUDE_DIRS)
include_directories(${LIBPGCOMMON_INCLUDE_DIRS})

### Shared libraries
add_subdirectory(postgis)

################################################################################
# Install

# TODO

################################################################################
# Configuration summary
if(NOT SUPRESS_VERBOSE_OUTPUT)
    message(STATUS)
    postgis_report_value(POSTGIS_VERSION)
    postgis_report_value(POSTGIS_LIB_VERSION)
    postgis_report_value(POSTGIS_SCRIPTS_VERSION)
    postgis_report_value(POSTGIS_BUILD_DATE)
    postgis_report_value(POSTGIS_WITH_TOPOLOGY)
    postgis_report_value(POSTGIS_WITH_RASTER)
    postgis_report_value(POSTGIS_WITH_TOPOLOGY)
    postgis_report_value(POSTGIS_PGSQL_VERSION)
endif()

# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
