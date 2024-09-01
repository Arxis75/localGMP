if(TARGET ethash::ethash)
    return()
endif()

set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/ethash)
set(ethash_INSTALL ${prefix})   #still unable to separate src/install
set(keccak_LIB_DIR ${ethash_INSTALL}/lib/keccak)
set(keccak_LIBRARY ${keccak_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}keccak${CMAKE_STATIC_LIBRARY_SUFFIX})
set(ethash_INCLUDE_DIR ${prefix}/include)

find_library(libkeccak NAMES keccak HINTS "${keccak_LIB_DIR}")
if(NOT libkeccak)
   message(STATUS "Third-party: creating target 'ethash::ethash'")

   include(FetchContent)
    FetchContent_Declare(
        ethash
        URL         https://github.com/chfast/ethash/archive/refs/tags/v1.0.1.tar.gz
        URL_HASH    SHA256=17e0786ba8437c1b0c61f2065da71ce1b9cc871f8723a747a8aae8b71334d95f
        UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
        BINARY_DIR "${ethash_INSTALL}"
        SOURCE_DIR "${ethash_INSTALL}"
        #SUBBUILD_DIR "${ethash_INSTALL}-subbuild"
    )
    FetchContent_MakeAvailable(ethash)
else()
    add_library(ethash::ethash STATIC IMPORTED GLOBAL)
    set_target_properties(ethash::ethash PROPERTIES IMPORTED_LOCATION ${keccak_LIBRARY})
    target_include_directories(ethash::ethash INTERFACE ${ethash_INCLUDE_DIR})
endif()