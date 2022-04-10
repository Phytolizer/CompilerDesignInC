cmake_minimum_required(VERSION 3.20)
project(CompilerDesignInC LANGUAGES C)

set(CMAKE_C_STANDARD 11)

add_library(CompilerDesignInC library.c library.h)
