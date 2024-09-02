if(TARGET gmp::gmp)
    return()
endif()

set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/gmp-6.3.0) #${CMAKE_CURRENT_BINARY_DIR})#
set(gmp_INSTALL_DIR ${prefix}/install)
set(gmp_LIB_DIR ${gmp_INSTALL_DIR}/lib)
set(gmp_C_LIBRARY ${gmp_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmp${CMAKE_STATIC_LIBRARY_SUFFIX})      # C library, mandatory for Givaro
set(gmp_CPP_LIBRARY ${gmp_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmpxx${CMAKE_STATIC_LIBRARY_SUFFIX})  # C++ library
set(gmp_LIBRARIES ${gmp_C_LIBRARY} ${gmp_CPP_LIBRARY})
set(gmp_INCLUDE_DIR ${gmp_INSTALL_DIR}/include)

find_library(libgmp NAMES gmp HINTS "${gmp_LIB_DIR}")
if(NOT libgmp)
  message(STATUS "Third-party: creating target 'gmp::gmp'")

  include(ProcessorCount)
  ProcessorCount(Ncpu)
  include(ExternalProject)

  set(gmp_SOURCE_DIR ${prefix}/src/gmp)
  
  ExternalProject_Add(
    gmp
    SOURCE_DIR ${OPENSSL_SOURCE_DIR}
    PREFIX ${prefix}             #remplace ${CMAKE_CURRENT_BINARY_DIR}
    URL https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.gz
    URL_HASH SHA256=e56fd59d76810932a0555aa15a14b61c16bed66110d3c75cc2ac49ddaa9ab24c
    UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
    CONFIGURE_COMMAND 
      ${gmp_SOURCE_DIR}/configure 
      --disable-shared --enable-assert --enable-alloca=debug --disable-assembly CFLAGS=-g --enable-cxx CXXFLAGS=-g  # debug parameters
      --prefix=${gmp_INSTALL_DIR}  #remplace /usr/local
    BUILD_COMMAND make -j${Ncpu}
    INSTALL_COMMAND make -j${Ncpu} install
    INSTALL_DIR ${gmp_INSTALL_DIR}
    TEST_COMMAND make -j${Ncpu} check
    BUILD_BYPRODUCTS ${gmp_LIBRARIES} #Mandatory for Ninja: https://stackoverflow.com/questions/54866067/cmake-and-ninja-missing-and-no-known-rule-to-make-it
  )
endif()

# We cannot use find_library because ExternalProject_Add() is performed at build time.
# And to please the property INTERFACE_INCLUDE_DIRECTORIES,
# we make the include directory in advance (race condition).
file(MAKE_DIRECTORY ${gmp_INCLUDE_DIR})

add_library(gmp::gmp INTERFACE IMPORTED GLOBAL)
add_dependencies(gmp::gmp gmp)          # builds the external project before building any reference to the library
target_include_directories(gmp::gmp INTERFACE ${gmp_INCLUDE_DIR})
target_link_libraries(gmp::gmp INTERFACE "${gmp_LIBRARIES}")  # need the quotes to expand list