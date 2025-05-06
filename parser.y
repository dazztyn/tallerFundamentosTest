%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast_c.h"
int yylex(void);
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
%}

%union {
    int ival;
    float fval;
    char* id;
}

%token <ival> NUMBER
%token <fval> FLOATNUM
%token <id> ID STRING_LITERAL

%token INT FLOAT STRING IF ELSE WHILE FOR PRINT WRITE
%token EQ NEQ LEQ GEQ LT GT

%type <ival> expr

%%

program:
    stmt_list
    ;

stmt_list:
    stmt stmt_list
    | stmt
    ;

stmt:
      INT ID ';'               { printf("Declaración de entero: %s\n", $2); }
    | FLOAT ID ';'             { printf("Declaración de flotante: %s\n", $2); }
    | STRING ID ';'            { printf("Declaración de cadena: %s\n", $2); }
    | ID '=' expr ';'          { printf("Asignación: %s = %d\n", $1, $3); }
    | PRINT expr ';'           { printf("Imprimir: %d\n", $2); }
    | WRITE ID ';'             { printf("Entrada por teclado para: %s\n", $2); }
    | IF '(' expr ')' stmt     { printf("Sentencia if\n"); }
    | IF '(' expr ')' stmt ELSE stmt { printf("Sentencia if-else\n"); }
    | WHILE '(' expr ')' stmt  { printf("Bucle while\n"); }
    | FOR '(' stmt expr ';' stmt ')' stmt  { printf("Bucle for\n"); }
    | '{' stmt_list '}'        { /* Bloque */ }
    ;

expr:
      expr '+' expr            { $$ = $1 + $3; }
    | expr '-' expr            { $$ = $1 - $3; }
    | expr '*' expr            { $$ = $1 * $3; }
    | expr '/' expr            { $$ = $1 / $3; }
    | expr EQ expr             { $$ = $1 == $3; }
    | expr NEQ expr            { $$ = $1 != $3; }
    | expr LEQ expr            { $$ = $1 <= $3; }
    | expr GEQ expr            { $$ = $1 >= $3; }
    | expr LT expr             { $$ = $1 < $3; }
    | expr GT expr             { $$ = $1 > $3; }
    | NUMBER                   { $$ = $1; }
    ;

%%

int main() {
    return yyparse();
}