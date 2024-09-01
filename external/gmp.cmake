if(TARGET gmp::gmp)
    return()
endif()

set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/gmp)
set(gmp_INSTALL ${prefix}/install)
set(gmp_LIB_DIR ${gmp_INSTALL}/lib)
set(gmp_LIBRARY 
  ${gmp_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmp${CMAKE_STATIC_LIBRARY_SUFFIX}
  ${gmp_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}gmpxx${CMAKE_STATIC_LIBRARY_SUFFIX}
  )
set(gmp_INCLUDE_DIR ${gmp_INSTALL}/include)

find_library(libgmp NAMES gmp HINTS "${gmp_LIB_DIR}")
if(NOT libgmp)
  message(STATUS "Third-party: creating target 'gmp::gmp'")

  include(FetchContent)
  include(ProcessorCount)
  ProcessorCount(Ncpu)
  include(ExternalProject)

  ExternalProject_Add(gmp
    PREFIX ${prefix}
    URL https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.gz
    URL_HASH SHA256=e56fd59d76810932a0555aa15a14b61c16bed66110d3c75cc2ac49ddaa9ab24c
    UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
    CONFIGURE_COMMAND 
      ${prefix}/src/gmp/configure 
      --disable-shared --enable-assert --enable-alloca=debug CFLAGS=-g --enable-cxx CXXFLAGS=-g
      --prefix=${gmp_INSTALL}
    BUILD_COMMAND make -j${Ncpu}
    INSTALL_COMMAND make -j${Ncpu} install
    INSTALL_DIR ${gmp_INSTALL}
    TEST_COMMAND make -j${Ncpu} check
    BUILD_BYPRODUCTS ${gmp_LIBRARY} #Mandatory for Ninja
  )
  ExternalProject_Get_Property(gmp SOURCE_DIR)
endif()

set(gmp_LIBRARIES ${gmp_LIBRARY})
add_library(gmp::gmp INTERFACE IMPORTED GLOBAL)

if(NOT libgmp)
  file(MAKE_DIRECTORY ${gmp_INCLUDE_DIR})  # avoid race condition if building hasn't completed and linkage is tested against this folder
  add_dependencies(gmp::gmp gmp)          # builds the external project before building any reference to the library
endif()

target_include_directories(gmp::gmp INTERFACE ${gmp_INCLUDE_DIR})
target_link_libraries(gmp::gmp INTERFACE "${gmp_LIBRARIES}")  # need the quotes to expand list