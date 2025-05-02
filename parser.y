
%{
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include "ast.hpp"

using namespace std;

extern int yylex();
void yyerror(const char *s) {
    cerr << "Error: " << s << endl;
}

ASTNode* root;
%}

%union {
    int ival;
    float fval;
    char* id;
    ASTNode* node;
}

%token <ival> NUMBER
%token <fval> FLOATNUM
%token <id> ID STRING_LITERAL

%token INT FLOAT STRING IF ELSE WHILE FOR PRINT WRITE
%token EQ NEQ LEQ GEQ LT GT

%type <node> stmt expr stmt_list


%%

program:
    stmt_list { root = $1; }
    ;

stmt_list:
    stmt stmt_list { $$ = new CompoundStatement($1, $2); }
  | stmt           { $$ = $1; }
    ;

stmt:
      INT ID ';'               { $$ = new VarDecl("int", $2); }
    | FLOAT ID ';'             { $$ = new VarDecl("float", $2); }
    | STRING ID ';'            { $$ = new VarDecl("string", $2); }
    | ID '=' expr ';'          { $$ = new Assignment($1, $3); }
    | PRINT expr ';'           { $$ = new PrintStatement($2); }
    | WRITE ID ';'             { $$ = new ReadStatement($2); }
    | IF '(' expr ')' stmt     { $$ = new IfStatement($3, $5, nullptr); }
    | IF '(' expr ')' stmt ELSE stmt { $$ = new IfStatement($3, $5, $7); }
    | WHILE '(' expr ')' stmt  { $$ = new WhileStatement($3, $5); }
    | '{' stmt_list '}'        { $$ = $2; }
    | FOR '(' stmt expr ';' stmt ')' stmt  { $$ = new ForStatement($3, $4, $6, $8); }
    ;

expr:
      expr '+' expr            { $$ = new BinaryExpr("+", $1, $3); }
    | expr '-' expr            { $$ = new BinaryExpr("-", $1, $3); }
    | expr '*' expr            { $$ = new BinaryExpr("*", $1, $3); }
    | expr '/' expr            { $$ = new BinaryExpr("/", $1, $3); }
    | expr EQ expr             { $$ = new BinaryExpr("==", $1, $3); }
    | expr NEQ expr            { $$ = new BinaryExpr("!=", $1, $3); }
    | expr LEQ expr            { $$ = new BinaryExpr("<=", $1, $3); }
    | expr GEQ expr            { $$ = new BinaryExpr(">=", $1, $3); }
    | expr LT expr             { $$ = new BinaryExpr("<", $1, $3); }
    | expr GT expr             { $$ = new BinaryExpr(">", $1, $3); }
    | NUMBER                   { $$ = new IntegerLiteral($1); }
    | FLOATNUM                 { $$ = new FloatLiteral($1); }
    | STRING_LITERAL           { $$ = new StringLiteral($1); }
    | ID                       { $$ = new Variable($1); }
    ;

%%

int main() {
    if (yyparse() == 0) {
        ofstream out("output.cpp");
        out << "#include <iostream>\nint main() {\n";
        out << root->generate() << "\n";
        out << "return 0;\n}\n";
        cout << "Código generado en output.cpp" << endl;
    }
    return 0;
}