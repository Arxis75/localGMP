set(GTest_PREFIX ${CMAKE_SOURCE_DIR}/build-external/googletest-1.15.2) #${CMAKE_CURRENT_BINARY_DIR})#
set(GTest_TMP_DIR ${GTest_PREFIX}/tmp)
set(GTest_STAMP_DIR ${GTest_PREFIX}/stamp)
set(GTest_SRC_DIR ${GTest_PREFIX}/src)
set(GTest_INSTALL_DIR ${GTest_PREFIX}/install)

if(NOT EXISTS ${GTest_INSTALL_DIR})
    include(ExternalProject)
    ExternalProject_Add(
        GTest
        URL
        URL               https://github.com/google/googletest/releases/download/v1.15.2/googletest-1.15.2.tar.gz
        URL_HASH          SHA256=7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926
        PREFIX            "${GTest_PREFIX}"
        TMP_DIR           "${GTest_TMP_DIR}"
        STAMP_DIR         "${GTest_STAMP_DIR}"
        SOURCE_DIR        "${GTest_SRC_DIR}"
        BINARY_DIR        "${GTest_INSTALL_DIR}"
        CONFIGURE_COMMAND ""
        BUILD_COMMAND     ""
        INSTALL_COMMAND   ""
        TEST_COMMAND      ""
    )

    include(${GTest_STAMP_DIR}/download-GTest.cmake)
    include(${GTest_STAMP_DIR}/extract-GTest.cmake)
endif()

# Add googletest directly to our build. This adds the following targets:
# gtest, gtest_main, gmock and gmock_main
add_subdirectory("${GTest_SRC_DIR}" "${GTest_INSTALL_DIR}")