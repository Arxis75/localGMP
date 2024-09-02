set(MY_LIBRARY_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

include(ethash.cmake)
include(gmp.cmake)
include(givaro.cmake)
include(openssl.cmake)

set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)