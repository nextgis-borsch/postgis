################################################################################
# Project:  CMake4GDAL
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015-2020 NextGIS <info@nextgis.com>
# Copyright (C) 2012-2020 Dmitry Baryshnikov
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

function(check_version major minor rev)

    set(VERSION_FILE ${CMAKE_SOURCE_DIR}/Version.config)
    file(READ ${VERSION_FILE} _POSTGIS_VERSION_CONFIG)
    string(STRIP ${_POSTGIS_VERSION_CONFIG} _POSTGIS_VERSION_CONFIG)

    string(REGEX REPLACE ".*POSTGIS_MAJOR_VERSION=([0-9]+)[\r\n\t\ ].*" "\\1"
        POSTGIS_MAJOR_VERSION ${_POSTGIS_VERSION_CONFIG})
    string(REGEX REPLACE ".*POSTGIS_MINOR_VERSION=([0-9]+)[\r\n\t\ ].*" "\\1"
        POSTGIS_MINOR_VERSION "${_POSTGIS_VERSION_CONFIG}")
    string(REGEX REPLACE ".*POSTGIS_MICRO_VERSION=([0-9]+).*[\r\n\t\ ].*" "\\1"
        POSTGIS_MICRO_VERSION "${_POSTGIS_VERSION_CONFIG}")

    set(${major} ${POSTGIS_MAJOR_VERSION} PARENT_SCOPE)
    set(${minor} ${POSTGIS_MINOR_VERSION} PARENT_SCOPE)
    set(${rev} ${POSTGIS_MICRO_VERSION} PARENT_SCOPE)

    # Store version string in file for installer needs
    file(TIMESTAMP ${VERSION_FILE} VERSION_DATETIME "%Y-%m-%d %H:%M:%S" UTC)
    set(VERSION ${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}.${POSTGIS_MICRO_VERSION})
    file(WRITE ${CMAKE_BINARY_DIR}/version.str "${VERSION}\n${VERSION_DATETIME}")

endfunction()
