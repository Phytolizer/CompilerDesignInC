#include "RecursiveDescent/lex.h"
#include "RecursiveDescent/parse.h"

#include <stdio.h>

void expression(void);

void statements(void) {
    expression();
    if (match(SEMI)) {
        advance();
    } else {
        fprintf(stderr, "%d: Inserting missing semicolon\n", yylineno);
    }

    if (!match(EOI)) {
        statements();
    }
}

void expr_prime(void);
void term(void);

void expression(void) {
    term();
    expr_prime();
}

void expr_prime(void) {
    if (match(PLUS)) {
        advance();
        term();
        expr_prime();
    }
}

void term_prime(void);
void factor(void);

void term(void) {
    factor();
    term_prime();
}

void term_prime(void) {
    if (match(TIMES)) {
        advance();
        factor();
        term_prime();
    }
}

void factor(void) {
    if (match(NUM_OR_ID)) {
        advance();
    } else if (match(LP)) {
        advance();
        expression();
        if (match(RP)) {
            advance();
        } else {
            fprintf(stderr, "%d: Mismatched parenthesis\n", yylineno);
        }
    } else {
        fprintf(stderr, "%d: Number or identifier expected\n", yylineno);
    }
}
