#include "RecursiveDescent/lex.h"
#include "RecursiveDescent/name.h"
#include "RecursiveDescent/parse.h"

#include <stdio.h>

void factor(char* tempvar);
void term(char* tempvar);
void expression(char* tempvar);

void statements(void) {
    char* tempvar;

    while (!match(EOI)) {
        tempvar = newname();
        expression(tempvar);
        freename(tempvar);

        if (match(SEMI)) {
            advance();
        } else {
            fprintf(stderr, "%d: Inserting missing semicolon\n", yylineno);
        }
    }
}

void expression(char* tempvar) {
    char* tempvar2;

    term(tempvar);
    while (match(PLUS)) {
        advance();
        tempvar2 = newname();
        term(tempvar2);
        printf("    %s += %s\n", tempvar, tempvar2);
        freename(tempvar2);
    }
}

void term(char* tempvar) {
    char* tempvar2;

    factor(tempvar);
    while (match(TIMES)) {
        advance();
        tempvar2 = newname();
        factor(tempvar2);
        printf("    %s *= %s\n", tempvar, tempvar2);
        freename(tempvar2);
    }
}

void factor(char* tempvar) {
    if (match(NUM_OR_ID)) {
        printf("    %s = %.*s\n", tempvar, yyleng, yytext);
        advance();
    } else if (match(LP)) {
        advance();
        expression(tempvar);
        if (match(RP)) {
            advance();
        } else {
            fprintf(stderr, "%d: Inserting missing right parenthesis\n", yylineno);
        }
    } else {
        fprintf(stderr, "%d: Inserting missing factor\n", yylineno);
    }
}
