%{
#include "parser.tab.hh"
#include <string>
#include <cstdlib>
using namespace std;
extern YYSTYPE yylval;
%}

DIGIT   [0-9]
ID      [a-zA-Z_][a-zA-Z0-9_]*
NUM     {DIGIT}+
FLOAT   {DIGIT}+"."{DIGIT}+

%%

"chain"         { return STRING; }
"integer"       { return INT; }
"floating"      { return FLOAT; }

"if"            { return IF; }
"otherwise"     { return ELSE; }
"while"         { return WHILE; }
"for"           { return FOR; }


"print"         { return PRINT; }
"write"         { return WRITE; }

"=="            { return EQ; }
"!="            { return NEQ; }
"<="            { return LEQ; }
">="            { return GEQ; }
"<"             { return LT; }
">"             { return GT; }

"+"             { return '+'; }
"-"             { return '-'; }
"*"             { return '*'; }
"/"             { return '/'; }
"="             { return '='; }

{FLOAT}         { yylval.fval = atof(yytext); return FLOATNUM; }
{NUM}           { yylval.ival = atoi(yytext); return NUMBER; }
{ID}            { yylval.id = strdup(yytext); return ID; }

\"[^\"]*\"      { yylval.id = strdup(yytext); return STRING_LITERAL; }

[ \t\r\n]+      { /* ignorar espacios */ }

.               { return *yytext; }

%%