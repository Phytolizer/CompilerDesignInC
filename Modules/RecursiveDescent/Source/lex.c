#include "RecursiveDescent/lex.h"

#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>

char* yytext = "";
int yyleng = 0;
int yylineno = 0;

int lex(void) {
    static char input_buffer[128];
    char* current = yytext + yyleng;

    while (true) {
        while (!*current) {
            current = input_buffer;
            if (!fgets(input_buffer, sizeof(input_buffer), stdin)) {
                *current = '\0';
                return EOI;
            }
            ++yylineno;
            while (isspace(*current)) {
                ++current;
            }
        }

        for (; *current; ++current) {
            yytext = current;
            yyleng = 1;
            switch (*current) {
                case EOF:
                    return EOI;
                case ';':
                    return SEMI;
                case '+':
                    return PLUS;
                case '*':
                    return TIMES;
                case '(':
                    return LP;
                case ')':
                    return RP;

                case '\n':
                case '\t':
                case ' ':
                    break;
                default:
                    if (!isalnum(*current)) {
                        fprintf(stderr, "Ignoring illegal input <%c>\n", *current);
                    } else {
                        while (isalnum(*current)) {
                            ++current;
                        }
                        yyleng = current - yytext;
                        return NUM_OR_ID;
                    }
                    break;
            }
        }
    }
}

static int Lookahead = -1;

bool match(int token) {
    if (Lookahead == -1) {
        Lookahead = lex();
    }

    return token == Lookahead;
}

void advance(void) {
    Lookahead = lex();
}
