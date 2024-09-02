#return()

set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/openssl-3.3.0) #${CMAKE_CURRENT_BINARY_DIR})#
set(OPENSSL_INSTALL_DIR ${prefix}/install)
set(OPENSSL_LIB_DIR ${OPENSSL_INSTALL_DIR}/lib64)
set(OPENSSL_SSL_LIBRARY ${OPENSSL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}ssl${CMAKE_STATIC_LIBRARY_SUFFIX})
set(OPENSSL_CRYPTO_LIBRARY ${OPENSSL_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}crypto${CMAKE_STATIC_LIBRARY_SUFFIX})
set(OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARY} ${OPENSSL_CRYPTO_LIBRARY})
set(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_DIR}/include)

#find_library(libOpenSSL NAMES ssl HINTS "${prefix}/OpenSSL-prefix/src/OpenSSL-build/")
if(TRUE)#NOT libOpenSSL)#
  include(ProcessorCount)
  ProcessorCount(Ncpu)
  include(ExternalProject)

  set(OPENSSL_SOURCE_DIR ${prefix}/src)#/openssl-src)#

  ExternalProject_Add(
    OpenSSL
    SOURCE_DIR ${OPENSSL_SOURCE_DIR}
    PREFIX ${OPENSSL_INSTALL_DIR}           # replace ${CMAKE_CURRENT_BINARY_DIR}
    URL https://github.com/openssl/openssl/releases/download/openssl-3.3.0/openssl-3.3.0.tar.gz
    URL_HASH SHA256=53e66b043322a606abf0087e7699a0e033a37fa13feb9742df35c3a33b18fb02
    UPDATE_DISCONNECTED true                # need this to avoid constant rebuild
    CONFIGURE_COMMAND
      ${OPENSSL_SOURCE_DIR}/config
      no-asm -g3 -O0 -fno-omit-frame-pointer -fno-inline-functions  # debug parameters
      --prefix=${OPENSSL_INSTALL_DIR}       # replace /usr/local
      --openssldir=${OPENSSL_INSTALL_DIR}   # Cf https://wiki.openssl.org/index.php/Compilation_and_Installation
    BUILD_COMMAND make -j${Ncpu}
    TEST_COMMAND make -j${Ncpu} test#""#
    INSTALL_COMMAND make -j${Ncpu} install
    INSTALL_DIR ${OPENSSL_INSTALL_DIR}
    BUILD_BYPRODUCTS ${OPENSSL_LIBRARIES} #Mandatory for Ninja: https://stackoverflow.com/questions/54866067/cmake-and-ninja-missing-and-no-known-rule-to-make-it
  )
endif()

# We cannot use find_library because ExternalProject_Add() is performed at build time.
# And to please the property INTERFACE_INCLUDE_DIRECTORIES,
# we make the include directory in advance (race condition).
file(MAKE_DIRECTORY ${OPENSSL_INCLUDE_DIR})

add_library(OpenSSL::OpenSSL INTERFACE IMPORTED GLOBAL)
add_dependencies(OpenSSL::OpenSSL OpenSSL)
target_include_directories(OpenSSL::OpenSSL INTERFACE ${OPENSSL_INCLUDE_DIR})
target_link_libraries(OpenSSL::OpenSSL INTERFACE "${OPENSSL_LIBRARIES}")  # need the quotes to expand list