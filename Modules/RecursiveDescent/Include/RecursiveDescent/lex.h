#ifndef COMPILERDESIGNINC_LEX_H
#define COMPILERDESIGNINC_LEX_H

#include <stdbool.h>

enum {
    EOI,
    SEMI,
    PLUS,
    TIMES,
    LP,
    RP,
    NUM_OR_ID,
};

extern char* yytext;
extern int yyleng;
extern int yylineno;

int lex(void);
bool match(int token);
void advance(void);

#endif // COMPILERDESIGNINC_LEX_H
