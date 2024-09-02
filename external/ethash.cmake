set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/ethash-1.0.1)
set(ETHASH_INSTALL ${prefix})   #still unable to separate src/install
set(KECCAK_LIB_DIR ${ETHASH_INSTALL}/lib/keccak)
set(KECCAK_LIBRARY ${KECCAK_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}keccak${CMAKE_STATIC_LIBRARY_SUFFIX})
set(ETHASH_INCLUDE_DIR ${prefix}/include)

find_library(libkeccak NAMES keccak PATHS "${KECCAK_LIB_DIR}")
if(NOT libkeccak)
   message(STATUS "Third-party: creating target 'ethash::ethash'")

   include(FetchContent)
    FetchContent_Declare(
        ethash
        URL         https://github.com/chfast/ethash/archive/refs/tags/v1.0.1.tar.gz
        URL_HASH    SHA256=17e0786ba8437c1b0c61f2065da71ce1b9cc871f8723a747a8aae8b71334d95f
        UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
        BINARY_DIR "${ETHASH_INSTALL}"
        SOURCE_DIR "${ETHASH_INSTALL}"
        #SUBBUILD_DIR "${ETHASH_INSTALL}-subbuild"
    )
    FetchContent_MakeAvailable(ethash)
else()
    add_library(ethash::ethash STATIC IMPORTED GLOBAL)
    set_target_properties(ethash::ethash PROPERTIES IMPORTED_LOCATION ${KECCAK_LIBRARY})
    target_include_directories(ethash::ethash INTERFACE ${ETHASH_INCLUDE_DIR})
endif()