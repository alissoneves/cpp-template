cmake_minimum_required(VERSION 3.15)

# 1. Pega o nome da pasta onde o projeto está e define como nome do projeto
get_filename_component(DIR_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${DIR_NAME} LANGUAGES CXX)

# 2. Define o nome do executável baseado no nome do projeto/pasta
set(APP_NAME ${PROJECT_NAME})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Dependências (Conan cuidará de encontrar estas)
find_package(fmt REQUIRED)
find_package(spdlog REQUIRED)

# Executável principal usando o nome dinâmico
add_executable(${APP_NAME} src/main.cpp)

target_link_libraries(${APP_NAME}
    PRIVATE
    fmt::fmt
    spdlog::spdlog
)

# --- TESTES ---
find_package(GTest REQUIRED)
enable_testing()

add_executable(${APP_NAME}_tests tests/test_main.cpp)

target_link_libraries(${APP_NAME}_tests 
    PRIVATE 
    fmt::fmt 
    spdlog::spdlog 
    GTest::gtest 
    GTest::gtest_main
)

add_test(NAME MathTest.BasicAssertion COMMAND ${APP_NAME}_tests)