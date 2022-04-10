#include "RecursiveDescent/lex.h"
#include "RecursiveDescent/parse.h"

#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>

void factor(void);
void term(void);
void expression(void);
bool legal_lookahead(int first_arg, ...);

void statements(void) {
    while (!match(EOI)) {
        expression();

        if (match(SEMI)) {
            advance();
        } else {
            fprintf(stderr, "%d: Inserting missing semicolon\n", yylineno);
        }
    }
}

void expression(void) {
    if (!legal_lookahead(NUM_OR_ID, LP, 0)) {
        return;
    }

    term();
    while (match(PLUS)) {
        advance();
        term();
    }
}

#define MAXFIRST 16
#define SYNCH SEMI

bool legal_lookahead(int first_arg, ...) {
    va_list args;
    va_start(args, first_arg);
    bool rval = false;
    int lookaheads[MAXFIRST] = {0};
    int* p = lookaheads;
    bool error_printed = false;

    if (!first_arg) {
        if (match(EOI)) {
            rval = true;
        }
    } else {
        *p++ = first_arg;
        int tok;
        while ((tok = va_arg(args, int)) != 0 && p < &lookaheads[MAXFIRST]) {
            *p++ = tok;
        }

        while (!match(SYNCH)) {
            for (int* current = lookaheads; current < p; ++current) {
                if (match(*current)) {
                    rval = true;
                    goto done;
                }
            }

            if (!error_printed) {
                fprintf(stderr, "%d: Syntax error\n", yylineno);
                error_printed = true;
            }

            advance();
        }
    }

done:
    va_end(args);
    return rval;
}

void term(void) {
    if (!legal_lookahead(NUM_OR_ID, LP, 0)) {
        return;
    }

    factor();
    while (match(TIMES)) {
        advance();
        factor();
    }
}

void factor(void) {
    if (!legal_lookahead(NUM_OR_ID, LP, 0)) {
        return;
    }

    if (match(NUM_OR_ID)) {
        advance();
    } else if (match(LP)) {
        advance();
        expression();
        if (match(RP)) {
            advance();
        } else {
            fprintf(stderr, "%d: Inserting missing right parenthesis\n", yylineno);
        }
    } else {
        fprintf(stderr, "%d: Number or identifier expected\n", yylineno);
    }
}
