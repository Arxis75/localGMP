set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/openssl)#${CMAKE_CURRENT_BINARY_DIR})#
set(OPENSSL_SOURCE_DIR ${prefix}/openssl-src) # default path by CMake
set(OPENSSL_INSTALL_DIR ${prefix}/openssl)
set(OPENSSL_BUILD_DIR ${OPENSSL_INSTALL_DIR}/src/OpenSSL-build)
set(OPENSSL_INCLUDE_DIR ${OPENSSL_INSTALL_DIR}/include)
set(OPENSSL_CONFIGURE_COMMAND ${OPENSSL_SOURCE_DIR}/config)

#find_library(libOpenSSL NAMES ssl HINTS "${prefix}/OpenSSL-prefix/src/OpenSSL-build/")
if(FALSE)#NOT libOpenSSL)#
  include(ProcessorCount)
  ProcessorCount(Ncpu)
  include(ExternalProject)

  ExternalProject_Add(
    OpenSSL
    PREFIX ${OPENSSL_INSTALL_DIR}#${prefix}/OpenSSL-prefix#
    SOURCE_DIR ${OPENSSL_SOURCE_DIR}
    URL https://github.com/openssl/openssl/releases/download/openssl-3.3.0/openssl-3.3.0.tar.gz
    URL_HASH SHA256=53e66b043322a606abf0087e7699a0e033a37fa13feb9742df35c3a33b18fb02
    USES_TERMINAL_DOWNLOAD TRUE
    CONFIGURE_COMMAND
      ${OPENSSL_CONFIGURE_COMMAND}
      CFLAGS=-g
      --prefix=${OPENSSL_INSTALL_DIR}
      --openssldir=${OPENSSL_INSTALL_DIR}
    BUILD_COMMAND make -j${Ncpu}
    TEST_COMMAND ""
    INSTALL_COMMAND make -j${Ncpu} install
    INSTALL_DIR ${OPENSSL_INSTALL_DIR}
  )
endif()

# We cannot use find_library because ExternalProject_Add() is performed at build time.
# And to please the property INTERFACE_INCLUDE_DIRECTORIES,
# we make the include directory in advance.
file(MAKE_DIRECTORY ${OPENSSL_INCLUDE_DIR})

add_library(OpenSSL::SSL STATIC IMPORTED GLOBAL)
set_property(TARGET OpenSSL::SSL PROPERTY IMPORTED_LOCATION ${OPENSSL_BUILD_DIR}/libssl${CMAKE_STATIC_LIBRARY_SUFFIX})
set_property(TARGET OpenSSL::SSL PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
add_dependencies(OpenSSL::SSL OpenSSL)

add_library(OpenSSL::Crypto STATIC IMPORTED GLOBAL)
set_property(TARGET OpenSSL::Crypto PROPERTY IMPORTED_LOCATION ${OPENSSL_BUILD_DIR}/libcrypto${CMAKE_STATIC_LIBRARY_SUFFIX})
set_property(TARGET OpenSSL::Crypto PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${OPENSSL_INCLUDE_DIR})
add_dependencies(OpenSSL::Crypto OpenSSL)