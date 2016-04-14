################################################################################
# Project:  CMake4PostGIS
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2016, NextGIS <info@nextgis.com>
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

configure_file(postgis_topology.control.in ${CMAKE_CURRENT_BINARY_DIR}/postgis_topology.control)

#prepare_extension_sql(${CMAKE_BINARY_DIR}/postgis/postgis.sql ${CMAKE_CURRENT_BINARY_DIR}/postgis.sql)

#execute_process(COMMAND ${PERL_EXECUTABLE} 
#                    ${CMAKE_SOURCE_DIR}/utils/create_spatial_ref_sys_config_dump.pl
#                    ${CMAKE_SOURCE_DIR}/spatial_ref_sys.sql
#                OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/spatial_ref_sys_config_dump.sql)
#prepare_extension_sql(${CMAKE_SOURCE_DIR}/spatial_ref_sys.sql ${CMAKE_CURRENT_BINARY_DIR}/spatial_ref_sys.sql)

#file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/sql)
#file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/sql/postgis.sql "\\echo Use \"CREATE EXTENSION postgis\" to load this file. \\quit\n")


#if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL ) 
#    install(FILES ${POSTGIS_EXTENSION_FILES} DESTINATION "${PGSQL_SHAREDIR}/extension/")
#endif()

