if(TARGET givaro::givaro)
    return()
endif()

set(prefix ${CMAKE_CURRENT_SOURCE_DIR}/givaro)
set(givaro_INSTALL ${prefix}/install)
set(givaro_LIB_DIR ${givaro_INSTALL}/lib)
set(givaro_LIBRARY ${givaro_LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}givaro${CMAKE_STATIC_LIBRARY_SUFFIX})
set(givaro_INCLUDE_DIR ${givaro_INSTALL}/include)

find_library(libgivaro NAMES givaro HINTS "${givaro_LIB_DIR}")
if(NOT libgivaro)
  message(STATUS "Third-party: creating target 'givaro::givaro'")

  include(FetchContent)
  include(ProcessorCount)
  ProcessorCount(Ncpu)
  include(ExternalProject)

  ExternalProject_Add(givaro
    PREFIX ${prefix}
    URL https://github.com/linbox-team/givaro/releases/download/v4.2.0/givaro-4.2.0.tar.gz
    URL_HASH SHA256=865e228812feca971dfb6e776a7bc7ac959cf63ebd52b4f05492730a46e1f189
    UPDATE_DISCONNECTED true  # need this to avoid constant rebuild
    CONFIGURE_COMMAND 
      ${prefix}/src/givaro/configure
      --disable-shared CFLAGS=-g CXXFLAGS=-g
      --prefix=${givaro_INSTALL}
      --with-gmp=${CMAKE_CURRENT_SOURCE_DIR}/gmp/install
    BUILD_COMMAND make -j${Ncpu}
    INSTALL_COMMAND make -j${Ncpu} install
    INSTALL_DIR ${givaro_INSTALL}
    TEST_COMMAND ""
    BUILD_BYPRODUCTS ${givaro_LIBRARY} #Mandatory for Ninja
  )
  ExternalProject_Get_Property(givaro SOURCE_DIR)
endif()

add_library(givaro::givaro INTERFACE IMPORTED GLOBAL)

if(NOT libgivaro)
  file(MAKE_DIRECTORY ${givaro_INCLUDE_DIR}) # avoid race condition if building hasn't completed and linkage is tested against this folder
  add_dependencies(givaro gmp::gmp)          # builds gmp before building givaro
  add_dependencies(givaro::givaro givaro)    # builds the external project before building any reference to the library
endif()

target_include_directories(givaro::givaro INTERFACE ${givaro_INCLUDE_DIR})
target_link_libraries(givaro::givaro INTERFACE ${givaro_LIBRARY} gmp::gmp)  #l'ordre après INTERFACE est important!