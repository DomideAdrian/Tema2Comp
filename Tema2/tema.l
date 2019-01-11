%{
#include <string.h>
#include "tema.tab.h"


int lineNo = 1;
int colNo = 1;

%}



%%

"PROGRAM"			{ colNo+=7; return TPROGRAM; }
"VAR"				{ colNo+=3; return TVAR; }
"BEGIN"				{ colNo+=5; return TBEGIN; }
"END"				{ colNo+=3; return TEND; }
";"				{ colNo++;  return TSEMICOLON; }
":"				{ colNo++;  return TCOLON; }
"INTEGER"			{ colNo+=7; return TINTEGER; }
","				{ colNo++;  return TCOMMA; }
":="				{ colNo+=2; return TEQUAL; }
"+"				{ colNo++;  return TPLUS; }
"-"				{ colNo++;  return TMINUS; }
"*"				{ colNo++;  return TMUL; }
"DIV"				{ colNo+=3; return TDIV; }
"("				{ colNo++;  return TLPAREN; }
")"				{ colNo++;  return TRPAREN; }
"READ"				{ colNo+=4; return TREAD; }
"WRITE"				{ colNo+=5; return TWRITE; }
"FOR"				{ colNo+=3; return TFOR; }
"DO"				{ colNo+=2; return TDO; }
"TO"				{ colNo+=2; return TTO; }
[ ]				{ colNo++; }
\r\n				{ lineNo++; colNo=1; }
\n				{ lineNo++; colNo=1; }
[a-zA-Z_][a-zA-Z0-9_]*		{ yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen (yytext); yylval.sir = new char[strlen(yytext)+1]; strcpy(yylval.sir,yytext);return TIDENTIFIER; }
0|[1-9][0-9]*			{ yylloc.first_line = lineNo; yylloc.first_column = colNo; colNo+=strlen (yytext); yylval.val = atoi(yytext); return TINTVAL; }
.				{ colNo++; return TERROR; }

%%

