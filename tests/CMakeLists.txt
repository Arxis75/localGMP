cmake_minimum_required(VERSION 3.0)

project(hello_tests NONE)

add_executable(main_tests main.cpp)

target_link_libraries(main_tests PRIVATE GTest::gtest)

add_subdirectory(unit_tests)

include(GoogleTest)
gtest_discover_tests(main_tests)