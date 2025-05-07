%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast_c.h"

ASTNode* root;

int yylex(void);
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
%}

%union {
    int ival;
    float fval;
    char* id;
    void* node;  // ✅ solución al error: usar puntero genérico
}

%token <ival> NUMBER
%token <fval> FLOATNUM
%token <id> ID STRING_LITERAL

%token INT FLOAT STRING IF ELSE WHILE FOR PRINT WRITE
%token EQ NEQ LEQ GEQ LT GT

%left '+' '-'
%left '*' '/'
%left EQ NEQ LT GT LEQ GEQ
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%type <node> program stmt stmt_list expr

%%

program:
    stmt_list               { root = (ASTNode*)$1; }
    ;

stmt_list:
      stmt                 {
                            ASTNode** stmts = malloc(sizeof(ASTNode*));
                            stmts[0] = (ASTNode*)$1;
                            ASTNode* block = malloc(sizeof(ASTNode));
                            block->type = NODE_BLOCK;
                            block->block.stmts = stmts;
                            block->block.stmt_count = 1;
                            $$ = block;
                          }
    | stmt_list stmt       {
                            ASTNode* block = (ASTNode*)$1;
                            int n = block->block.stmt_count + 1;
                            block->block.stmts = realloc(block->block.stmts, n * sizeof(ASTNode*));
                            block->block.stmts[n-1] = (ASTNode*)$2;
                            block->block.stmt_count = n;
                            $$ = block;
                          }
    ;

stmt:
      INT ID ';'               { $$ = make_decl_node($2, NODE_INT); }
    | FLOAT ID ';'             { $$ = make_decl_node($2, NODE_FLOAT); }
    | STRING ID ';'            { $$ = make_decl_node($2, NODE_STRING); }
    | ID '=' expr ';'          { $$ = make_assign_node($1, (ASTNode*)$3); }
    | PRINT ID ';'             { $$ = make_print_node(make_id_node($2)); }
    | PRINT STRING_LITERAL ';' { $$ = make_print_node(make_id_node($2)); }
    | WRITE ID ';'             { $$ = NULL; } /* aún no implementado */
    | IF '(' expr ')' stmt %prec LOWER_THAN_ELSE
                                { $$ = make_if_node((ASTNode*)$3, (ASTNode*)$5, NULL); }
    | IF '(' expr ')' stmt ELSE stmt
                                { $$ = make_if_node((ASTNode*)$3, (ASTNode*)$5, (ASTNode*)$7); }
    | WHILE '(' expr ')' stmt  { $$ = make_while_node((ASTNode*)$3, (ASTNode*)$5); }
    | '{' stmt_list '}'        { $$ = $2; }
    ;

expr:
      expr '+' expr            { $$ = make_binop_node("+", (ASTNode*)$1, (ASTNode*)$3); }
    | expr '-' expr            { $$ = make_binop_node("-", (ASTNode*)$1, (ASTNode*)$3); }
    | expr '*' expr            { $$ = make_binop_node("*", (ASTNode*)$1, (ASTNode*)$3); }
    | expr '/' expr            { $$ = make_binop_node("/", (ASTNode*)$1, (ASTNode*)$3); }
    | expr EQ expr             { $$ = make_binop_node("==", (ASTNode*)$1, (ASTNode*)$3); }
    | expr NEQ expr            { $$ = make_binop_node("!=", (ASTNode*)$1, (ASTNode*)$3); }
    | expr LEQ expr            { $$ = make_binop_node("<=", (ASTNode*)$1, (ASTNode*)$3); }
    | expr GEQ expr            { $$ = make_binop_node(">=", (ASTNode*)$1, (ASTNode*)$3); }
    | expr LT expr             { $$ = make_binop_node("<", (ASTNode*)$1, (ASTNode*)$3); }
    | expr GT expr             { $$ = make_binop_node(">", (ASTNode*)$1, (ASTNode*)$3); }
    | NUMBER                   { $$ = make_int_node($1); }
    | ID                       { $$ = make_id_node($1); }
    ;

%%

int main() {
    if (yyparse() == 0) {
        printf("Árbol de sintaxis generado correctamente:\n");
        print_ast(root, 0);
    }
    return 0;
}
