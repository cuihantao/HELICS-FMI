# LLNS Copyright Start
# Copyright (c) 2017, Lawrence Livermore National Security
# This work was performed under the auspices of the U.S. Department
# of Energy by Lawrence Livermore National Laboratory in part under
# Contract W-7405-Eng-48 and in part under Contract DE-AC52-07NA27344.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# LLNS Copyright End

#project name

set(utilities_sources
argParser.cpp
	gridRandom.cpp
	stringOps.cpp
	string_viewOps.cpp
	matrixOps.cpp
	stringConversion.cpp
	units.cpp
	vectorOps.cpp
	functionInterpreter.cpp
	charMapper.cpp
	workQueue.cpp
	zipUtilities.cpp
	base64.cpp
	matrixCreation.cpp
	logger.cpp
	matrixDataSparse.cpp
	stringToCmdLine.cpp
	)

set(utilities_headers
	units.h
	argParser.h
	dataDictionary.hpp
	timeSeries.hpp
	charMapper.h
	timeSeriesMulti.hpp
	vectorOps.hpp
	generic_string_ops.hpp
	stringOps.h
	string_viewOps.h
	string_viewDef.h
	optionalDef.hpp
	matrixData.hpp
	matrixOps.h
	matrixDataCompact.hpp
	matrixDataSparse.hpp
	matrixDataSparse_impl.hpp
	matrixDataTranslate.hpp
	matrixDataContainer.hpp
	matrixDataScale.hpp
	matrixDataOrdered.hpp
	matrixDataOrdering.hpp
	matrixDataFilter.hpp
	matrixDataCustomWriteOnly.hpp
	functionInterpreter.h
	workQueue.h
	simpleQueue.hpp
	zipUtilities.h
	base64.h
	stringConversion.h
	string_viewConversion.h
	mapOps.hpp
	valuePredictor.hpp
	matrixCreation.h
	timeRepresentation.hpp
	indexTypes.hpp
	logger.h
	stringToCmdLine.h
	)

add_library(utilities STATIC ${utilities_sources} ${utilities_headers})


include(buildZlib)

include(buildMiniZip)
###########################################
# building zlib
###########################################
set(ZLIB_ROOT_DIR ${PROJECT_BINARY_DIR}/libs)

if (NOT EXISTS ${PROJECT_BINARY_DIR}/libs/cmake/zlib-targets.cmake)
build_zlib()
endif()
include(${PROJECT_BINARY_DIR}/libs/cmake/zlib-targets.cmake)

###########################################
# building minizip
###########################################
set(ZLIB_INCLUDES ${PROJECT_BINARY_DIR}/libs/include)
if (NOT EXISTS ${PROJECT_BINARY_DIR}/libs/cmake/minizip-targets.cmake)
build_minizip()
endif()
include(${PROJECT_BINARY_DIR}/libs/cmake/minizip-targets.cmake)

target_link_libraries(utilities PUBLIC minizip::minizip zlib::zlib)

INSTALL(TARGETS utilities
       LIBRARY DESTINATION lib
       ARCHIVE DESTINATION lib)

