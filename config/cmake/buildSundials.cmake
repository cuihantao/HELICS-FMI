# This function is used to force a build on a dependant project at cmake configuration phase.
# 

function (build_sundials_msvc)

	include(escape_string)
	escape_string(cxx_compiler_string ${CMAKE_CXX_COMPILER})
	escape_string(c_compiler_string ${CMAKE_C_COMPILER})
	escape_string(linker_string ${CMAKE_LINKER})
	
    set(trigger_build_dir ${CMAKE_BINARY_DIR}/autobuild/force_sundials)

    #mktemp dir in build tree
    file(MAKE_DIRECTORY ${trigger_build_dir} ${trigger_build_dir}/build)
#find the directory where KLU is located
    
    #message(STATUS "KLU_DIR=${SuiteSparse_LIBRARY_DIR}")
	
	message(STATUS "extra c flags ${EXTRA_C_FLAGS}")
	
    set(CMAKE_LIST_CONTENT "
    cmake_minimum_required(VERSION 3.5)
    include(ExternalProject)
ExternalProject_Add(sundials
    SOURCE_DIR ${PROJECT_BINARY_DIR}/Download/sundials
    GIT_REPOSITORY  https://github.com/llnl/sundials.git
    GIT_TAG v3.1.1
    UPDATE_COMMAND " " 
    BINARY_DIR ${PROJECT_BINARY_DIR}/ThirdParty/sundials
     
    CMAKE_ARGS 
        -DCMAKE_INSTALL_PREFIX=${AUTOBUILD_INSTALL_PATH}
        -DCMAKE_BUILD_TYPE=\$\{CMAKE_BUILD_TYPE\}
        -DBUILD_CVODES=OFF
        -DBUILD_IDAS=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DEXAMPLES_ENABLE_C=OFF
		-DEXAMPLES_ENABLE_CXX=OFF
        -DEXAMPLES_INSTALL=OFF
		-DSUNDIALS_INDEX_TYPE=int32_t
        -DCMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}
        \"-DCMAKE_C_FLAGS=${EXTRA_C_FLAGS}\"
        -DCMAKE_C_COMPILER=${c_compiler_string}
		-DCMAKE_LINKER=${linker_string}
		-DCMAKE_DEBUG_POSTFIX=d
        
        
    INSTALL_DIR ${AUTOBUILD_INSTALL_PATH}
    )")


    file(WRITE ${trigger_build_dir}/CMakeLists.txt "${CMAKE_LIST_CONTENT}")
if (NOT BUILD_RELEASE_ONLY)
	message(STATUS "Configuring Sundials Autobuild for debug: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config_debug.log")
    execute_process(COMMAND ${CMAKE_COMMAND} -Wno-dev -D CMAKE_CXX_COMPILER=${cxx_compiler_string} -D CMAKE_C_COMPILER=${c_compiler_string}
	    -D CMAKE_LINKER=${linker_string}
        -D CMAKE_BUILD_TYPE=Debug -G ${CMAKE_GENERATOR} .. 
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config_debug.log
        )
	
	message(STATUS "Building Sundials Autobuild for debug: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build_debug.log")	
    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config Debug
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build_debug.log
        )
	
	endif()
  if (NOT BUILD_DEBUG_ONLY)	
	if (NOT MSVC_RELEASE_BUILD_TYPE)
		set(MSVC_RELEASE_BUILD_TYPE "Release")
	endif()
	message(STATUS "Configuring Sundials Autobuild for ${MSVC_RELEASE_BUILD_TYPE}: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config_release.log")	
	execute_process(COMMAND ${CMAKE_COMMAND} -Wno-dev -D CMAKE_CXX_COMPILER=${cxx_compiler_string} -D CMAKE_C_COMPILER=${c_compiler_string}
	    -D CMAKE_LINKER=${linker_string}
        -D CMAKE_BUILD_TYPE=${MSVC_RELEASE_BUILD_TYPE} -G ${CMAKE_GENERATOR} .. 
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config_release.log
        )
		
	message(STATUS "Building Sundials Autobuild for ${MSVC_RELEASE_BUILD_TYPE}: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build_release.log")
    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${MSVC_RELEASE_BUILD_TYPE}
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build_release.log
        )
endif()

endfunction()

function (build_sundials_mingw)
 if (CMAKE_BUILD_TYPE)
	list(APPEND valid_btypes "Release" "Debug" "RelWithDebInfo" "MinSizeRel")
	if (${CMAKE_BUILD_TYPE} IN_LIST valid_btypes)
		set(LOCAL_BUILD_TYPE ${CMAKE_BUILD_TYPE})
	else()
		set(LOCAL_BUILD_TYPE "RelWithDebInfo")
	endif()
else ()
	set(LOCAL_BUILD_TYPE "Release")
endif()
#message(STATUS "BUILD SUNDIALS MINGW")
	include(escape_string)
	escape_string(cxx_compiler_string ${CMAKE_CXX_COMPILER})
	escape_string(c_compiler_string ${CMAKE_C_COMPILER})
	escape_string(linker_string ${CMAKE_LINKER})
	
    set(trigger_build_dir ${CMAKE_BINARY_DIR}/autobuild/force_sundials)

    #mktemp dir in build tree
    file(MAKE_DIRECTORY ${trigger_build_dir} ${trigger_build_dir}/build)
    set(CMAKE_LIST_CONTENT "
    cmake_minimum_required(VERSION 3.5)
    include(ExternalProject)
ExternalProject_Add(sundials
    SOURCE_DIR ${PROJECT_BINARY_DIR}/Download/sundials
    GIT_REPOSITORY  https://github.com/llnl/sundials.git
    GIT_TAG v3.1.0
    UPDATE_COMMAND " " 
    BINARY_DIR ${PROJECT_BINARY_DIR}/ThirdParty/sundials
     
    CMAKE_ARGS 
        -DCMAKE_INSTALL_PREFIX=${PROJECT_BINARY_DIR}/libs
        -DCMAKE_BUILD_TYPE=\$\{CMAKE_BUILD_TYPE\}
        -DBUILD_CVODES=OFF
        -DBUILD_IDAS=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DEXAMPLES_ENABLE_C=OFF
		-DEXAMPLES_ENABLE_CXX=OFF
        -DEXAMPLES_INSTALL=OFF
		-DSUNDIALS_INDEX_TYPE=int32_t
        -DCMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}
        \"-DCMAKE_C_FLAGS=${EXTRA_C_FLAGS}\"
        -DCMAKE_C_COMPILER=${c_compiler_string}
        -DCMAKE_LINKER=${linker_string}
        
        
    INSTALL_DIR ${PROJECT_BINARY_DIR}/libs
    )")


    file(WRITE ${trigger_build_dir}/CMakeLists.txt "${CMAKE_LIST_CONTENT}")

	message(STATUS "Configuring Sundials Autobuild for ${LOCAL_BUILD_TYPE}: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config.log")
    execute_process(COMMAND ${CMAKE_COMMAND} -Wno-dev -D CMAKE_CXX_COMPILER=${cxx_compiler_string} -D CMAKE_C_COMPILER=${c_compiler_string}
	    -D CMAKE_LINKER=${linker_string}
        -D CMAKE_BUILD_TYPE=${LOCAL_BUILD_TYPE} -G ${CMAKE_GENERATOR} .. 
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config.log
        )
	
	message(STATUS "Building Sundials Autobuild for ${LOCAL_BUILD_TYPE}: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build.log")	
    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${LOCAL_BUILD_TYPE}
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build.log
        )
	
	
endfunction()

function (build_sundials)
message(STATUS "BUILD SUNDIALS UNIX")
	if (CMAKE_BUILD_TYPE)
	list(APPEND valid_btypes "Release" "Debug" "RelWithDebInfo" "MinSizeRel")
	if (${CMAKE_BUILD_TYPE} IN_LIST valid_btypes)
		set(LOCAL_BUILD_TYPE ${CMAKE_BUILD_TYPE})
	else()
		set(LOCAL_BUILD_TYPE "RelWithDebInfo")
	endif()
else ()
	set(LOCAL_BUILD_TYPE "Release")
endif()
	include(escape_string)
	escape_string(cxx_compiler_string ${CMAKE_CXX_COMPILER})
	escape_string(c_compiler_string ${CMAKE_C_COMPILER})
	escape_string(linker_string ${CMAKE_LINKER})
	
    set(trigger_build_dir ${CMAKE_BINARY_DIR}/autobuild/force_sundials)

    #mktemp dir in build tree
    file(MAKE_DIRECTORY ${trigger_build_dir} ${trigger_build_dir}/build)
#find the directory where KLU is located
    
    #message(STATUS "KLU_DIR=${SuiteSparse_LIBRARY_DIR}")
	
	message(STATUS "extra c flags ${EXTRA_C_FLAGS}")
	
    set(CMAKE_LIST_CONTENT "
    cmake_minimum_required(VERSION 3.5)
    include(ExternalProject)
ExternalProject_Add(sundials
    SOURCE_DIR ${PROJECT_BINARY_DIR}/Download/sundials
    GIT_REPOSITORY  https://github.com/llnl/sundials.git
    GIT_TAG v3.1.1
    UPDATE_COMMAND " " 
    BINARY_DIR ${PROJECT_BINARY_DIR}/ThirdParty/sundials
     
    CMAKE_ARGS 
        -DCMAKE_INSTALL_PREFIX=${AUTOBUILD_INSTALL_PATH}
        -DCMAKE_BUILD_TYPE=\$\{CMAKE_BUILD_TYPE\}
        -DBUILD_CVODES=OFF
        -DBUILD_IDAS=OFF
        -DBUILD_SHARED_LIBS=OFF
        -DEXAMPLES_ENABLE_C=OFF
		-DEXAMPLES_ENABLE_CXX=OFF
        -DEXAMPLES_INSTALL=OFF
		-DSUNDIALS_INDEX_TYPE=int32_t
        -DCMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}
        \"-DCMAKE_C_FLAGS=${EXTRA_C_FLAGS}\"
        -DCMAKE_C_COMPILER=${c_compiler_string}
		-DCMAKE_LINKER=${linker_string}

        
    INSTALL_DIR ${AUTOBUILD_INSTALL_PATH}
    )")


    file(WRITE ${trigger_build_dir}/CMakeLists.txt "${CMAKE_LIST_CONTENT}")
message(STATUS "Configuring Sundials Autobuild for ${LOCAL_BUILD_TYPE}: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config.log")
    execute_process(COMMAND ${CMAKE_COMMAND} -Wno-dev -D CMAKE_CXX_COMPILER=${cxx_compiler_string} -D CMAKE_C_COMPILER=${c_compiler_string}
	    -D CMAKE_LINKER=${linker_string}
        -D CMAKE_BUILD_TYPE=${LOCAL_BUILD_TYPE} -G ${CMAKE_GENERATOR} .. 
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_config.log
        )
	
	message(STATUS "Building Sundials Autobuild for ${LOCAL_BUILD_TYPE}: logging to ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build.log")	
    execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${LOCAL_BUILD_TYPE}
        WORKING_DIRECTORY ${trigger_build_dir}/build
		OUTPUT_FILE ${PROJECT_BINARY_DIR}/logs/sundials_autobuild_build.log
        )
	endfunction()
