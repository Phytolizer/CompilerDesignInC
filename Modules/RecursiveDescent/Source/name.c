#include "RecursiveDescent/name.h"

#include "RecursiveDescent/lex.h"

#include <stdio.h>
#include <stdlib.h>

static char* names[] = {"t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7"};
char** namep = names;

char* newname(void) {
    if (namep >= &names[sizeof names / sizeof *names]) {
        fprintf(stderr, "%d: Expression too complex\n", yylineno);
        exit(1);
    }

    return *namep++;
}

void freename(char* s) {
    if (namep > names) {
        *--namep = s;
    } else {
        fprintf(stderr, "%d: (Internal error) Name stack underflow\n", yylineno);
    }
}
