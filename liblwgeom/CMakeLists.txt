################################################################################
# Project:  CMake4PostGIS
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, polimax@mail.ru
################################################################################
# Copyright (C) 2016-2018, NextGIS <info@nextgis.com>
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

project(lwgeom)

if(OSX_FRAMEWORK)
    set(INSTALL_INC_DIR "${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Headers" CACHE INTERNAL "Installation directory for headers" FORCE)
    set(INSTALL_CMAKECONF_DIR ${INSTALL_LIB_DIR}/${PROJECT_NAME}.framework/Resources/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
else()
    set(INSTALL_CMAKECONF_DIR ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/CMake CACHE INTERNAL "Installation directory for cmake config files" FORCE)
endif()

configure_file(liblwgeom.h.in ${CMAKE_CURRENT_BINARY_DIR}/liblwgeom.h)

set_property(GLOBAL PROPERTY LIBLWGEOM_INCLUDE_DIRS
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

check_lwgeom_version(LIBLWGEOM_ABI_MAJOR LIBLWGEOM_ABI_MINOR LIBLWGEOM_ABI_PATCH)
report_version(${PROJECT_NAME} ${LIBLWGEOM_ABI_MAJOR}.${LIBLWGEOM_ABI_MINOR}.${LIBLWGEOM_ABI_PATCH})

set(HHEADERS_PUB
    ${CMAKE_CURRENT_BINARY_DIR}/liblwgeom.h
    liblwgeom_topo.h
)

set(HHEADERS ${HHEADERS_PUB}
    bytebuffer.h
    effectivearea.h
    liblwgeom_internal.h
    lwgeodetic.h
    lwgeodetic_tree.h
    liblwgeom_topo_internal.h
    lwgeom_log.h
    lwgeom_geos.h
    lwgeom_log.h
    lwgeom_sfcgal.h
    lwin_wkt.h
    lwin_wkt_parse.h
    lwout_twkb.h
    lwtree.h
    measures3d.h
    measures.h
    stringbuffer.h
    varint.h
  )

set(CSOURCES
    stringbuffer.c
	bytebuffer.c
	measures.c
	measures3d.c
	box2d.c
	ptarray.c
	lwgeom_api.c
	lwgeom.c
	lwpoint.c
	lwline.c
	lwpoly.c
	lwtriangle.c
	lwmpoint.c
	lwmline.c
	lwmpoly.c
	lwboundingcircle.c
	lwcollection.c
	lwcircstring.c
	lwcompound.c
	lwcurvepoly.c
	lwmcurve.c
	lwmsurface.c
	lwpsurface.c
	lwtin.c
	lwout_wkb.c
	lwin_geojson.c
	lwin_wkb.c
	lwin_twkb.c
	lwiterator.c
	lwgeom_median.c
	lwout_wkt.c
	lwout_twkb.c
	lwin_wkt_parse.c
	lwin_wkt_lex.c
	lwin_wkt.c
	lwin_encoded_polyline.c
	lwutil.c
	lwhomogenize.c
	lwalgorithm.c
	lwstroke.c
	lwlinearreferencing.c
	lwprint.c
	g_box.c
	g_serialized.c
	g_util.c
	lwgeodetic.c
	lwgeodetic_tree.c
	lwtree.c
	lwout_gml.c
	lwout_kml.c
	lwout_geojson.c
	lwout_svg.c
	lwout_x3d.c
	lwout_encoded_polyline.c
	lwgeom_debug.c
	lwgeom_geos.c
	lwgeom_geos_clean.c
	lwgeom_geos_cluster.c
	lwgeom_geos_node.c
	lwgeom_geos_split.c
	lwgeom_topo.c
	lwgeom_transform.c
	lwgeom_wrapx.c
	lwunionfind.c
	effectivearea.c
	lwkmeans.c
	kmeans.c
	varint.c
    lwspheroid.c
)

set(LIB_NAME ${PROJECT_NAME})
set_property(GLOBAL PROPERTY LIB_NAME_LWGEOM ${LIB_NAME})

if(BUILD_SHARED_LIBS)
    add_library(${LIB_NAME} SHARED ${CSOURCES} ${HHEADERS})
    if(UNIX)
        set(LIB_OUTPUT_NAME "${LIB_NAME}-${POSTGIS_MAJOR_VERSION}.${POSTGIS_MINOR_VERSION}")
        set_target_properties(${LIB_NAME} PROPERTIES OUTPUT_NAME ${LIB_OUTPUT_NAME})
    endif()
    if(WIN32)
        set(LIB_VERSION ${LIBLWGEOM_ABI_MAJOR})
        if(MSVC)
            set_target_properties(${LIB_NAME} PROPERTIES IMPORT_SUFFIX "_i.lib")
        endif()
    else ()
        set(LIB_VERSION "${LIBLWGEOM_ABI_MAJOR}.${LIBLWGEOM_ABI_MINOR}.${LIBLWGEOM_ABI_PATCH}")
    endif()
    set_target_properties (${LIB_NAME} PROPERTIES
        VERSION ${LIB_VERSION}
        SOVERSION ${LIBLWGEOM_ABI_MAJOR})
elseif(OSX_FRAMEWORK)
    add_library(${LIB_NAME} SHARED ${CSOURCES} ${HHEADERS})
    set(LIB_VERSION "${LIBLWGEOM_ABI_MAJOR}.${LIBLWGEOM_ABI_MINOR}.${LIBLWGEOM_ABI_PATCH}")
    set_target_properties(${LIB_NAME} PROPERTIES
      FRAMEWORK TRUE
      FRAMEWORK_VERSION ${POSTGIS_MAJOR_VERSION}
      MACOSX_FRAMEWORK_SHORT_VERSION_STRING ${VERSION}
      MACOSX_FRAMEWORK_BUNDLE_VERSION ${VERSION}
      MACOSX_FRAMEWORK_IDENTIFIER net.postgis.lwgeom
      XCODE_ATTRIBUTE_INSTALL_PATH "@rpath"
      PUBLIC_HEADER "${HHEADERS_PUB}"
      VERSION ${VERSION}
      SOVERSION ${LIBLWGEOM_ABI_MAJOR}
    )
else()
    add_library(${LIB_NAME} STATIC ${CSOURCES} ${HHEADERS})
endif()


target_link_extlibraries(${LIB_NAME})
set(TARGET_LINK_LIB ${TARGET_LINK_LIB} ${LIB_NAME} PARENT_SCOPE)
set(DEPENDENCY_LIB ${DEPENDENCY_LIB} ${LIB_NAME} PARENT_SCOPE)

if(UNIX AND NOT OSX_FRAMEWORK)
    add_custom_command(
        TARGET ${LIB_NAME} POST_BUILD
        COMMAND ln -sf $<TARGET_LINKER_FILE_NAME:${LIB_NAME}> ${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}
        COMMENT "Create symlink ${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX}"
    )
endif()

# Add path to includes to build-tree export
target_include_directories(${LIB_NAME} INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)

set(PACKAGE_NAME ${PROJECT_NAME})
string(TOUPPER ${PACKAGE_NAME} PACKAGE_UPPER_NAME)

# Add all targets to the build-tree export set
export(TARGETS ${LIB_NAME}
    FILE ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Targets.cmake)

# Create the <Package>Config.cmake file
configure_file(${CMAKE_SOURCE_DIR}/cmake/PackageConfig.cmake.in
    ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake @ONLY)

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME}
        EXPORT ${PACKAGE_UPPER_NAME}Targets
        RUNTIME DESTINATION ${INSTALL_BIN_DIR}
        LIBRARY DESTINATION ${INSTALL_LIB_DIR}
        ARCHIVE DESTINATION ${INSTALL_LIB_DIR}
        INCLUDES DESTINATION ${INSTALL_INC_DIR}
        FRAMEWORK DESTINATION ${INSTALL_LIB_DIR}
    )
    if(UNIX AND NOT OSX_FRAMEWORK)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}${PROJECT_NAME}${CMAKE_SHARED_LIBRARY_SUFFIX} DESTINATION "${INSTALL_LIB_DIR}" COMPONENT libraries)
    endif()
endif()


if(NOT SKIP_INSTALL_FILES AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HHEADERS_PUB} DESTINATION "${INSTALL_INC_DIR}" COMPONENT headers)
endif()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL)
    # Install the <Package>Config.cmake
    install(FILES
      ${CMAKE_BINARY_DIR}/${PACKAGE_UPPER_NAME}Config.cmake
      DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)

    # Install the export set for use with the install-tree
    install(EXPORT ${PACKAGE_UPPER_NAME}Targets DESTINATION ${INSTALL_CMAKECONF_DIR} COMPONENT dev)
endif()
