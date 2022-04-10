#include "RecursiveDescent/lex.h"
#include "RecursiveDescent/name.h"
#include "RecursiveDescent/parse.h"

#include <stdio.h>

char* factor(void);
char* term(void);
char* expression(void);

void statements(void) {
    char* tempvar;

    while (!match(EOI)) {
        tempvar = expression();

        if (match(SEMI)) {
            advance();
        } else {
            fprintf(stderr, "%d: Inserting missing semicolon\n", yylineno);
        }

        freename(tempvar);
    }
}

char* expression(void) {
    char* tempvar;
    char* tempvar2;

    tempvar = term();
    while (match(PLUS)) {
        advance();
        tempvar2 = term();
        printf("    %s += %s\n", tempvar, tempvar2);
        freename(tempvar2);
    }

    return tempvar;
}

char* term(void) {
    char* tempvar;
    char* tempvar2;

    tempvar = factor();
    while (match(TIMES)) {
        advance();
        tempvar2 = factor();
        printf("    %s *= %s\n", tempvar, tempvar2);
        freename(tempvar2);
    }

    return tempvar;
}

char* factor(void) {
    char* tempvar;

    if (match(NUM_OR_ID)) {
        tempvar = newname();
        printf("    %s = %.*s\n", tempvar, yyleng, yytext);
        advance();
    } else if (match(LP)) {
        advance();
        tempvar = expression();
        if (match(RP)) {
            advance();
        } else {
            fprintf(stderr, "%d: Inserting missing right parenthesis\n", yylineno);
        }
    } else {
        fprintf(stderr, "%d: Illegal lookahead\n", yylineno);
    }

    return tempvar;
}
