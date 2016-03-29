configure_file(liblwgeom.h.in ${CMAKE_CURRENT_BINARY_DIR}/liblwgeom.h)

set_property(GLOBAL PROPERTY LIBLWGEOM_INCLUDE_DIRS
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

set(HHEADERS_PUB
    ${CMAKE_CURRENT_BINARY_DIR}/liblwgeom.h
    liblwgeom_topo.h
)  

set(HHEADERS ${HHEADERS_PUB}
    bytebuffer.h
    effectivearea.h
    liblwgeom_internal.h
    libtgeom.h
    lwgeodetic.h
    lwgeodetic_tree.h
    lwgeom_geos.h
    liblwgeom_topo.h
    liblwgeom_topo_internal.h
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
	lwunionfind.c
	effectivearea.c
	varint.c
)  

add_library(liblwgeom OBJECT ${CSOURCES} ${HEADERS})
  
if(NOT SKIP_INSTALL_FILES AND NOT SKIP_INSTALL_ALL )
    install(FILES ${HHEADERS_PUB} DESTINATION "${INSTALL_INC_DIR}" COMPONENT headers)
endif()

