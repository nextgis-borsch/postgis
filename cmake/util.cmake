################################################################################
# Project:  CMake4GDAL
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
# Copyright (C) 2012,2013,2014 Dmitry Baryshnikov
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

    file(READ "${CMAKE_SOURCE_DIR}/Version.config" _POSTGIS_VERSION_CONFIG)
    string(STRIP ${_POSTGIS_VERSION_CONFIG} _POSTGIS_VERSION_CONFIG)

    string(REGEX REPLACE ".*POSTGIS_MAJOR_VERSION=([0-9]+)[\r\n\t\ ].*" "\\1"
        POSTGIS_MAJOR_VERSION ${_POSTGIS_VERSION_CONFIG})
    string(REGEX REPLACE ".*POSTGIS_MINOR_VERSION=([0-9]+)[\r\n\t\ ].*" "\\1"
        POSTGIS_MINOR_VERSION "${_POSTGIS_VERSION_CONFIG}")
    string(REGEX REPLACE ".*POSTGIS_MICRO_VERSION=([0-9]+)[\r\n\t\ ].*" "\\1"
        POSTGIS_MICRO_VERSION "${_POSTGIS_VERSION_CONFIG}")
  
    set(${major} ${POSTGIS_MAJOR_VERSION} PARENT_SCOPE)
    set(${minor} ${POSTGIS_MINOR_VERSION} PARENT_SCOPE)
    set(${rev} ${POSTGIS_MICRO_VERSION} PARENT_SCOPE)
endfunction(check_version)

function(report_version name ver)

    string(ASCII 27 Esc)
    set(BoldYellow  "${Esc}[1;33m")
    set(ColourReset "${Esc}[m")
        
    message(STATUS "${BoldYellow}${name} version ${ver}${ColourReset}")
    
endfunction()    
