add_library("RecursiveDescent" "Source/lex.c" "Source/name.c")
target_include_directories("RecursiveDescent" PUBLIC "Include")

add_executable("RecursiveDescent_plain" "Source/main.c" "Source/plain.c")
target_link_libraries("RecursiveDescent_plain" PRIVATE "RecursiveDescent")

add_executable("RecursiveDescent_improved" "Source/main.c" "Source/improved.c")
target_link_libraries("RecursiveDescent_improved" PRIVATE "RecursiveDescent")

add_executable("RecursiveDescent_retval" "Source/main.c" "Source/retval.c")
target_link_libraries("RecursiveDescent_retval" PRIVATE "RecursiveDescent")

add_executable("RecursiveDescent_args" "Source/main.c" "Source/args.c")
target_link_libraries("RecursiveDescent_args" PRIVATE "RecursiveDescent")
