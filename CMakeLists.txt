# Nous voulons un cmake "récent" pour utiliser les dernières fonctionnalités
cmake_minimum_required(VERSION 3.0)

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -D_GLIBCXX_DEBUG")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Notre projet est étiqueté hello
project(hello)

set(prefix ${PROJECT_SOURCE_DIR}/gmp)
set(gmp_INSTALL ${prefix}/install)
set(gmp_INCLUDE_DIR ${gmp_INSTALL}/include)
set(gmp_LIB_DIR ${gmp_INSTALL}/lib)
set(gmp_LIBRARY 
  ${gmp_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmp${CMAKE_STATIC_LIBRARY_SUFFIX}
  ${gmp_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmpxx${CMAKE_STATIC_LIBRARY_SUFFIX}
  )

find_library(libgmp NAMES gmp HINTS "${gmp_LIB_DIR}")
if(NOT libgmp)
  #message(FATAL_ERROR "gmp library not found")

  include(FetchContent)
  include(ProcessorCount)
  ProcessorCount(Ncpu)
  include(ExternalProject)

  ExternalProject_Add(gmp
    PREFIX ${prefix}
    #URL  https://github.com/alisw/GMP/archive/refs/tags/v6.2.1.tar.gz
    URL https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.gz
    URL_HASH SHA256=e56fd59d76810932a0555aa15a14b61c16bed66110d3c75cc2ac49ddaa9ab24c
    UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
    #PATCH_COMMAND 
    #  curl "https://gist.githubusercontent.com/alecjacobson/d34d9307c17d1b853571699b9786e9d1/raw/8d14fc21cb7654f51c2e8df4deb0f82f9d0e8355/gmp-patch" "|" git apply -v
    #${gmp_ExternalProject_Add_extra_options}
    CONFIGURE_COMMAND 
    #  ${CMAKE_COMMAND} -E env
    #  CFLAGS=${gmp_CFLAGS}
    #  LDFLAGS=${gmp_LDFLAGS}
      ${prefix}/src/gmp/configure 
      --disable-shared --enable-assert --enable-alloca=debug --disable-assembly CFLAGS=-g --enable-cxx CXXFLAGS=-g
    #  --disable-debug
    #  --disable-dependency-tracking
    #  --with-pic
      --prefix=${gmp_INSTALL}
    #  --build=${gmp_BUILD}
    #  --host=${gmp_HOST}
    BUILD_COMMAND make -j${Ncpu}
    INSTALL_COMMAND make -j${Ncpu} install
    INSTALL_DIR ${gmp_INSTALL}
    TEST_COMMAND "" #make -j${Ncpu} check
    BUILD_BYPRODUCTS ${gmp_LIBRARY} #Mandatory for Ninja
  )
  ExternalProject_Get_Property(gmp SOURCE_DIR)
endif()

set(gmp_LIBRARIES ${gmp_LIBRARY})
add_library(gmp::gmp INTERFACE IMPORTED GLOBAL)

if(NOT libgmp)
  file(MAKE_DIRECTORY ${gmp_INCLUDE_DIR})  # avoid race condition if fetching isn't completed and linkage is tried against this folder
  add_dependencies(gmp::gmp gmp)          # builds the external project before building any reference to the library
endif()

target_include_directories(gmp::gmp INTERFACE ${gmp_INCLUDE_DIR})
target_link_libraries(gmp::gmp INTERFACE "${gmp_LIBRARIES}")  # need the quotes to expand list

add_subdirectory(src)

