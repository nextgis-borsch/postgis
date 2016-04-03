################################################################################
# Project:  CMake4PostGIS
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2016, NextGIS <info@nextgis.com>
# Copyright (C) 2012 Mateusz Loskot <mateusz@loskot.net>
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
project(postgis)

configure_file(sqldefines.h.in ${CMAKE_CURRENT_BINARY_DIR}/sqldefines.h)
set_property(GLOBAL PROPERTY POSTGIS_INCLUDE_DIRS
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(HHEADERS
  geography.h
  geography_measurement_trees.h
  lwgeom_export.h
  lwgeom_functions_analytic.h
  lwgeom_geos.h
  lwgeom_geos_prepared.h
  lwgeom_rtree.h
)

set(CSOURCES
	postgis_module.c
	lwgeom_accum.c
	lwgeom_spheroid.c
	lwgeom_ogc.c
	lwgeom_functions_analytic.c
	lwgeom_inout.c
	lwgeom_functions_basic.c
	lwgeom_btree.c
	lwgeom_box.c
	lwgeom_box3d.c
	lwgeom_backend_api.c
	lwgeom_geos_prepared.c
	lwgeom_geos_clean.c
	lwgeom_geos_relatematch.c
	lwgeom_export.c
	lwgeom_in_gml.c
	lwgeom_in_kml.c
	lwgeom_in_geohash.c
	lwgeom_in_geojson.c
	lwgeom_in_encoded_polyline.c
	lwgeom_triggers.c
	lwgeom_dump.c
	lwgeom_dumppoints.c
	lwgeom_functions_lrs.c
	lwgeom_functions_temporal.c
	long_xact.c
	lwgeom_sqlmm.c
	lwgeom_rtree.c
	lwgeom_transform.c
	gserialized_typmod.c
	gserialized_gist_2d.c
	gserialized_gist_nd.c
	gserialized_estimate.c
	geography_inout.c
	geography_btree.c
	geography_measurement.c
	geography_measurement_trees.c
	geometry_inout.c
)

# Files to be copied to the contrib/ directory
set(SQL_built postgis.sql uninstall_postgis.sql postgis_upgrade.sql postgis_proc_set_search_path.sql legacy.sql uninstall_legacy.sql legacy_minimal.sql legacy_gist.sql) 
set(DATA spatial_ref_sys.sql)

# SQL objects (files requiring pre-processing)
set(SQL_objs postgis.sql legacy.sql legacy_minimal.sql)

get_property(LIB_NAME_LWGEOM GLOBAL PROPERTY LIB_NAME_LWGEOM)
set(LIB_NAME_POSTGIS ${PROJECT_NAME})

add_library(${LIB_NAME_POSTGIS}
  $<TARGET_OBJECTS:libpgcommon>
  ${CSOURCES}
  ${HHEADERS}
)

target_link_extlibraries(${LIB_NAME_POSTGIS})

set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${LIB_NAME_POSTGIS} PARENT_SCOPE)


if(UNIX)
    set_target_properties(${LIB_NAME_POSTGIS} PROPERTIES OUTPUT_NAME "${LIB_NAME_POSTGIS}-${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}")
elseif(BUILD_SHARED_LIBS AND WIN32)
    set_target_properties(${LIB_NAME_POSTGIS} PROPERTIES SUFFIX "${POSTGIS_MAJOR_VERSION}${POSTGIS_MINOR_VERSION}.dll")
endif()

#/usr/lib/postgresql/9.3/lib/postgis-2.1.so
if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME_POSTGIS}
        EXPORT ${LIB_NAME_POSTGIS}
        RUNTIME DESTINATION ${PGSQL_PKGBINDIR} COMPONENT libraries
        ARCHIVE DESTINATION ${PGSQL_PKGLIBDIR} COMPONENT libraries
        LIBRARY DESTINATION ${PGSQL_PKGLIBDIR} COMPONENT libraries
    )
endif()

#target_link_libraries(postgis)

#add_custom_command(OUTPUT postgis.sql.in
#  COMMAND
#  "${CMAKE_C_COMPILER}" -E -P -w ${CMAKE_CURRENT_SOURCE_DIR}/postgis.sql.in.c -o postgis.sql.in -I${CMAKE_CURRENT_BINARY_DIR} -I${CMAKE_SOURCE_DIR}/#libpgcommon
#  MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/postgis.sql.in.c
#  COMMENT "Preprocessing postgis.sql.in file"
#  VERBATIM
#)
#add_custom_target(PreprocessSQL
#  ALL
#  DEPENDS postgis.sql.in
#  COMMENT "Preprocessing SQL files"
# VERBATIM
#  SOURCES postgis.sql.in.c)
