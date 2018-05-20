###############################################################################
# CMake module to search for protobuf-c library
#
# On success, the macro sets the following variables:
# PROTOBUF-C_FOUND       = if the library found
# PROTOBUF-C_LIBRARIES   = full path to the library
# PROTOBUF-C_INCLUDE_DIRS = where to find the library headers
# PROTOBUF-C_COMPILER    = protoc-c executable
#
# Copyright (c) 2018 Dmitry Baryshnikov, <dmitry.baryshnikov@nextgis.com>
# Copyright (c) 2018 NextGIS, <info@nextgis.com>
#
# Redistribution and use is allowed according to the terms of the GPLv2 license.
#
###############################################################################

find_path(PROTOBUF-C_INCLUDE_DIRS protobuf-c.h
    PATH_SUFFIXES protobuf-c google/protobuf-c
    DOC "Path to protobuf-c library include directory"
)

SET(PROTOBUF-C_NAMES protobuf-c protobuf-c_i)
find_library(PROTOBUF-C_LIBRARIES
    NAMES ${PROTOBUF-C_NAMES}
    DOC "Path to protobuf-c library file"
)

if(PROTOBUF-C_INCLUDE_DIRS)
    set(PROTOBUF-C_VERSION "0.0.0")

    set(VERSION_FILE "${PROTOBUF-C_INCLUDE_DIRS}/protobuf-c.h")
    if(EXISTS ${VERSION_FILE})
        file(READ ${VERSION_FILE} _H_CONTENTS)
        string(REGEX MATCH "\"([0-9]+)\\.([0-9]+)\\.([0-9]+)\""
          PROTOBUF-C_VERSION ${_H_CONTENTS})

        unset(_H_CONTENTS)
    endif()
endif ()

find_program(PROTOBUF-C_COMPILER protoc-c
    DOC "Protobuf-c compiler program"
)

# Handle the QUIETLY and REQUIRED arguments and set SPATIALINDEX_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PROTOBUF-C
                                  REQUIRED_VARS PROTOBUF-C_LIBRARIES PROTOBUF-C_INCLUDE_DIRS
                                  VERSION_VAR PROTOBUF-C_VERSION)

IF(PROTOBUF-C_FOUND)
    set(PROTOBUF-C_LIBRARY ${PROTOBUF-C_LIBRARIES})
    set(PROTOBUF-C_INCLUDE_DIR ${PROTOBUF-C_INCLUDE_DIRS})
ENDIF()

# Hide internal variables
mark_as_advanced(
    PROTOBUF-C_INCLUDE_DIR
    PROTOBUF-C_LIBRARY
)
