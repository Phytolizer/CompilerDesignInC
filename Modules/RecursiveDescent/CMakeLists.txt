add_library("RecursiveDescent" "Source/lex.c")
target_include_directories("RecursiveDescent" PUBLIC "Include")

add_executable("RecursiveDescent_plain" "Source/main.c" "Source/plain.c")
target_link_libraries("RecursiveDescent_plain" PRIVATE "RecursiveDescent")

add_executable("RecursiveDescent_improved" "Source/main.c" "Source/improved.c")
target_link_libraries("RecursiveDescent_improved" PRIVATE "RecursiveDescent")
