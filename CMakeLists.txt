################################################################################
# CMakeLists.txt - root CMake configuration file, part PostGIS project
#
# Copyright (C) 2012 Mateusz Loskot <mateusz@loskot.net>
# Copyright (C) 2016, NextGIS <info@nextgis.com>
################################################################################
cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
project(postgis)

# Some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# Set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

if(OSX_FRAMEWORK AND (BUILD_SHARED_LIBS OR BUILD_STATIC_LIBS))
  message(FATAL_ERROR "Only OSX_FRAMEWORK key or any or both BUILD_SHARED_LIBS
                       and BUILD_STATIC_LIBS keys are permitted")
endif()

if(OSX_FRAMEWORK)
    set(INSTALL_BIN_DIR "bin" CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR "Library/Frameworks" CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(SKIP_INSTALL_HEADERS ON)
    set(SKIP_INSTALL_EXECUTABLES ON)
    set(SKIP_INSTALL_FILES ON)
    set(SKIP_INSTALL_EXPORT ON)
    set(CMAKE_MACOSX_RPATH ON)
else()
    include(GNUInstallDirs)

    set(INSTALL_BIN_DIR ${CMAKE_INSTALL_BINDIR} CACHE INTERNAL "Installation directory for executables" FORCE)
    set(INSTALL_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE INTERNAL "Installation directory for libraries" FORCE)
    set(INSTALL_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_DOC_DIR ${CMAKE_INSTALL_DOCDIR} CACHE INTERNAL "Share directory for data" FORCE)
    set(INSTALL_MAN_DIR ${CMAKE_INSTALL_MANDIR} CACHE INTERNAL "Installation directory for headers" FORCE)
endif()

################################################################################
# User options to control PostGIS features

option(POSTGIS_WITH_RASTER
    "Set ON|OFF (default=ON) to control building raster extension" ON)

option(POSTGIS_WITH_TOPOLOGY
    "Set ON|OFF (default=ON) to control building topology extension" ON)

# TODO: Add cgal support from https://github.com/nextgis-borsch/lib_cgal
option(POSTGIS_WITH_SFCGAL
    "Set ON|OFF (default=OFF) to control building SFCGAL extension" OFF)

option(POSTGIS_WITH_ADDRESS_STD
    "Set ON|OFF (default=ON) to control building address standardizer extension" ON)

option(POSTGIS_WITH_RASTER_WARN_ON_TRUNCATION
    "Set ON|OFF (default=OFF) to control warning outputted every time a double is truncated" OFF)
set(POSTGIS_RASTER_WARN_ON_TRUNCATION 0)
if(POSTGIS_WITH_RASTER_WARN_ON_TRUNCATION)
    set(POSTGIS_RASTER_WARN_ON_TRUNCATION 1)
endif()

option(POSTGIS_ENABLE_STATS
    "Set ON|OFF (default=ON) to control use ANALYZE statistics" ON)
set(POSTGIS_USE_STATS 1)
if(NOT POSTGIS_ENABLE_STATS)
    set(POSTGIS_USE_STATS 0)
endif()


################################################################################
# Version and build date information

include(util)
check_version(POSTGIS_MAJOR_VERSION POSTGIS_MINOR_VERSION POSTGIS_MICRO_VERSION)
check_raster_version(POSTGIS_RASTER_MAJOR_VERSION POSTGIS_RASTER_MINOR_VERSION POSTGIS_RASTER_MICRO_VERSION)

set(POSTGIS_USE_PROJ 1) # Proj.4 is required
set(POSTGIS_USE_GEOS 1) # GEOS is required

set(POSTGIS_VERSION "${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION} USE_GEOS=${POSTGIS_USE_GEOS} USE_PROJ=${POSTGIS_USE_PROJ} USE_STATS=${POSTGIS_USE_STATS}")
set(POSTGIS_LIB_VERSION "${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}.${POSTGIS_MICRO_VERSION}")
set(POSTGIS_SCRIPTS_VERSION "${POSTGIS_LIB_VERSION}")

set(POSTGIS_RASTER_VERSION "${POSTGIS_RASTER_MAJOR_VERSION}.${POSTGIS_RASTER_MINOR_VERSION}")
set(POSTGIS_RASTER_LIB_VERSION "${POSTGIS_RASTER_MAJOR_VERSION}.${POSTGIS_RASTER_MINOR_VERSION}.${POSTGIS_RASTER_MICRO_VERSION}")
set(POSTGIS_RASTER_SCRIPTS_VERSION "${POSTGIS_RASTER_LIB_VERSION}")

check_svn_revision(POSTGIS_SVN_REVISION)

set(VERSION ${POSTGIS_LIB_VERSION})
report_version(${PROJECT_NAME} ${VERSION})

set(TARGET_OBJECTS)

include(FindAnyProject)
include(PostGISUtilities)

if(NOT SUPPRESS_VERBOSE_OUTPUT)
    message(STATUS)
    colormsg(_HIBLUE_ "Configuring PostGIS:")
    message(STATUS)
endif()

################################################################################
# Dependency (required): PostgreSQL

if(UNIX AND NOT OSX_FRAMEWORK)
    find_package(PostgreSQL 9.1) # version 9.1 support extensions
    if(POSTGRESQL_FOUND)
        set(WITH_POSTGRESQL ${POSTGRESQL_FOUND})
    endif()

    if(NOT PG_CONFIG)
        message(FATAL ERROR " Please check your PostgreSQL installation")
    endif(NOT PG_CONFIG)

    set(HAVE_LIBPQ 1)

    if(POSTGRESQL_VERSION)
        string(REGEX REPLACE
            "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\1"
            PGSQL_VERSION_MAJOR "${POSTGRESQL_VERSION}")
        string(REGEX REPLACE
            "([0-9]+)\\.([0-9]+)\\.([0-9]+)" "\\2"
            PGSQL_VERSION_MINOR "${POSTGRESQL_VERSION}")

        set(POSTGIS_PGSQL_VERSION ${PGSQL_VERSION_MAJOR}${PGSQL_VERSION_MINOR})
    endif()

    exec_program(${PG_CONFIG} ARGS --includedir
        OUTPUT_VARIABLE PGSQL_INCLUDEDIR)
    exec_program(${PG_CONFIG} ARGS --includedir-server
        OUTPUT_VARIABLE PGSQL_INCLUDEDIR_SERVER)
    exec_program(${PG_CONFIG} ARGS --pgxs
        OUTPUT_VARIABLE PGSQL_PGXS)

    if(NOT EXISTS ${PGSQL_PGXS})
        message(FATAL_ERROR "The PGXS Makefile '${PGSQL_PGXS}' cannot be found. Please install the PostgreSQL server development packages")
    endif()

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
    exec_program(${PG_CONFIG} ARGS --bindir OUTPUT_VARIABLE PGSQL_PKGBINDIR)
    exec_program(${PG_CONFIG} ARGS --localedir OUTPUT_VARIABLE PGSQL_LOCALEDIR)

    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${POSTGRESQL_LIBRARIES})

    find_anyproject(ICONV DEFAULT ON) #as default is OFF, to set ON add DEFAULT ON
    if(ICONV_FOUND)
        set(HAVE_ICONV TRUE)
    endif()

    ################################################################################
    # Dependency (optional): GDAL
    if(POSTGIS_WITH_RASTER)
        find_anyproject(GDAL DEFAULT ON)
        if(GDAL_FOUND)
            THREE_PART_VERSION_TO_VARS(${GDAL_VERSION_STRING} GDAL_MAJOR GDAL_MINOR GDAL_PATCH)
            set(POSTGIS_GDAL_VERSION ${GDAL_MAJOR}${GDAL_MINOR})
        else()
            set(POSTGIS_WITH_RASTER OFF)
        endif()
    endif()

    find_anyproject(LibXml2 REQUIRED)
    if(LIBXML2_FOUND)
        set(POSTGIS_LIBXML2_VERSION ${LIBXML2_VERSION_STRING})
    endif()

    find_package(Perl)

    find_package(Protobuf)

endif(UNIX AND NOT OSX_FRAMEWORK)

################################################################################
# Dependency (required): PROJ.4
find_anyproject(PROJ4 VERSION 4.6 REQUIRED)
if(PROJ4_FOUND)
    if(PROJ4_VERSION)
        set(PROJ4_VERSION_STRING ${PROJ4_VERSION})
    endif()
    set(HAVE_LIBPROJ TRUE)
    THREE_PART_VERSION_TO_VARS(${PROJ4_VERSION_STRING} PROJ4_MAJOR PROJ4_MINOR PROG4_PATCH)
    set(POSTGIS_PROJ_VERSION ${PROJ4_MAJOR}${PROJ4_MINOR})
endif()

################################################################################
# Dependency (required): GEOS
find_anyproject(GEOS VERSION 3.4 REQUIRED)
if(GEOS_FOUND)
    if(GEOS_VERSION)
        set(GEOS_VERSION_STR ${GEOS_VERSION})
    endif()
    set(HAVE_LIBGEOS_C TRUE)
    THREE_PART_VERSION_TO_VARS(${GEOS_VERSION_STR} GEOS_MAJOR GEOS_MINOR GEOS_PATCH)
    set(POSTGIS_GEOS_VERSION ${GEOS_MAJOR}${GEOS_MINOR})
endif()

# Determine build date and time
string(TIMESTAMP POSTGIS_BUILD_DATE "%Y-%m-%d %H:%M:%S" UTC)
string(TIMESTAMP POSTGIS_RASTER_BUILD_DATE "%Y-%m-%d %H:%M:%S" UTC)

include(configure)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

if(WIN32)
    add_definitions(-DDLL_EXPORT)
else()
  # Warnings specification
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wmissing-prototypes")

  if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffloat-store")
  endif()

  # Turn on Position Independent Code generation for GEOS C shared library
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -DPIC")
endif()

message(STATUS "POSTGIS_PGSQL_VERSION: ${POSTGIS_PGSQL_VERSION}")

################################################################################
# Configure all subdirectories with any build targets
### Object libraries
add_subdirectory(liblwgeom)

if(UNIX AND NOT OSX_FRAMEWORK)
    get_property(LIBLWGEOM_INCLUDE_DIRS GLOBAL PROPERTY LIBLWGEOM_INCLUDE_DIRS)
    include_directories(${LIBLWGEOM_INCLUDE_DIRS})

    add_subdirectory(libpgcommon)

    get_property(LIBPGCOMMON_INCLUDE_DIRS GLOBAL PROPERTY LIBPGCOMMON_INCLUDE_DIRS)
    include_directories(${LIBPGCOMMON_INCLUDE_DIRS})

    if(POSTGIS_WITH_RASTER)
        add_subdirectory(raster)
    endif()

    if(POSTGIS_WITH_TOPOLOGY)
        add_subdirectory(topology)
    endif()

    if(POSTGIS_WITH_SFCGAL)
    #TODO:
        message(FATAL_ERROR "Not implemented yet!")
    endif()

    ### Shared libraries
    add_subdirectory(postgis)
    add_subdirectory(extensions)

    set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${PostgreSQL_LIBRARIES})
    add_subdirectory(loader)
endif(UNIX AND NOT OSX_FRAMEWORK)

################################################################################
# uninstall
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

# info
if(NOT SUPPRESS_VERBOSE_OUTPUT)
    include(summary)
endif()

# Export package ===============================================================
# TODO:
# if(REGISTER_PACKAGE)
#     # Export the package for use from the build-tree
#     # (this registers the build-tree with a global CMake-registry)
#     export(PACKAGE ${PACKAGE_UPPER_NAME})
# endif()


# Archiving ====================================================================

set(CPACK_PACKAGE_NAME "${PACKAGE_NAME}")
set(CPACK_PACKAGE_VENDOR "${PACKAGE_VENDOR}")
set(CPACK_PACKAGE_VERSION "${VERSION}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${PACKAGE_NAME} Installation")
set(CPACK_PACKAGE_RELOCATABLE TRUE)
set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
set(CPACK_GENERATOR "ZIP")
set(CPACK_MONOLITHIC_INSTALL ON)
set(CPACK_STRIP_FILES TRUE)

# Get cpack zip archive name
get_cpack_filename(${VERSION} PROJECT_CPACK_FILENAME)
set(CPACK_PACKAGE_FILE_NAME ${PROJECT_CPACK_FILENAME})

include(CPack)
