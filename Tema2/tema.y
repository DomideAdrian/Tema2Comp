%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int yylex();
int yyerror(const char* message);

int EsteCorecta = 1;
char msg[80];

class TNODE
    {
      public:
 	int val;
	char* sir;
	
	TNODE* next;
	
	static TNODE* head;
	static TNODE* tail;

	TNODE(char* n, int v = -1);
	TNODE();
	int exists(char* n);
	void add(char* n, int v = -1);
	int getValue(char* n);
	void setValue(char* n);
	void setValue(char* n, int val);

     };

	TNODE* TNODE::head;
	TNODE* TNODE::tail;

    TNODE::TNODE(char* n, int v)
    {
	this->sir = new char[strlen(n) + 1];
	strcpy(this->sir,n);
	this->val = v;
	this->next = NULL;
    }

    TNODE::TNODE()
    {
	TNODE::tail = NULL;
	TNODE::head = NULL;
    }

    int TNODE::exists(char* n)
    {
	TNODE* tmp = TNODE::head;
	while(tmp != NULL)
	{
	   if(strcmp(tmp->sir,n) == 0)
		return 1;
	   tmp = tmp->next;
	}
	return 0;
    }

    void TNODE::add(char*n, int v)
    {
	TNODE* elem = new TNODE(n,v);
	if(head == NULL)
	{
	   TNODE::head = TNODE::tail = elem;
	}
	else
	{
	   TNODE::tail->next = elem;
	   TNODE::tail = elem;
	}	
     }

     int TNODE::getValue(char* n)
     {
	TNODE* tmp = TNODE::head;
	while(tmp != NULL)
	{
	   if(strcmp(tmp->sir,n) == 0)
		return tmp->val;
	   tmp = tmp->next;
	}
        return -1;
     }
     
     void TNODE::setValue(char* n, int v)
     {
	TNODE* tmp = TNODE::head;
	while(tmp!=NULL)
	{
	    if(strcmp(tmp->sir,n) == 0)
	    {
		tmp->val = v;
	    }
	    tmp = tmp->next;
	}
      }

     TNODE* list = NULL;

%}

%code requires {
typedef struct punct { int x,y,z; } PUNCT;
}

%union{
	int val;
	char* sir;
	PUNCT p;
}

%token TPROGRAM TVAR TBEGIN TEND TSEMICOLON TCOLON TINTEGER
%token TCOMMA TEQUAL TPLUS TMINUS TMUL TDIV TLPAREN TRPAREN 
%token TREAD TWRITE TFOR TDO TTO TIDENTIFIER TINTVAL TERROR

%type <val> TINTVAL term exp factor
%type <sir> TIDENTIFIER id_list 

%left TPLUS TMINUS
%left TMUL TDIV

%start prog

%%
prog: 	     	TPROGRAM prog_name TVAR dec_list TBEGIN stmt_list TEND 
		|		
		error
       		 { EsteCorecta = 0; }
	       	;
 
prog_name:   	TIDENTIFIER	
		{  
		   if(list != NULL)
		   {
			if(list->exists($1) == 1)
			   {
				sprintf(msg,"%d:%d Eroare semantica: Numele este deja folosit %s!",@1.first_line, @1.first_column, $1);
	    			yyerror(msg);
	    			YYERROR;
			   }
			   else 
			   {
			        list->add($1);
			   	//$$ = $1;
		           }
                   }
		   else
		   {
			list = new TNODE();
			list->add($1);
		   }
		}
		;

dec_list:	dec
		|
		dec_list TSEMICOLON dec
		;

dec:		id_list TCOLON type
		{
		  if(list != NULL)
		  {
	            if(list->exists($1) == 0)
	            {
			list->add($1);
		    }
		    else
		    {
			sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!",@1.first_line, @1.first_column, $1);
	    		yyerror(msg);
	    		YYERROR;
		    }
                  }
		  else
		  {
		        list = new TNODE();
		        list->add($1);
		  }
		}
		;

type: 		TINTEGER
		;

id_list:	TIDENTIFIER { $$ = $1; }
		|
		id_list TCOMMA TIDENTIFIER
		{
		  if(list != NULL)
		  {
	            if(list->exists($3) == 0)
	            {
			list->add($3);
		    }
		    else
		    {
			sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!",@1.first_line, @1.first_column, $3);
	    		yyerror(msg);
	    		YYERROR;
		    }
                  }
		  else
		  {
		        list = new TNODE();
		        list->add($3);
		  }
		}
		;

stmt_list:	stmt	
		|
		stmt_list TSEMICOLON stmt
		;

stmt:		assign
		|
		read
		|
		write
		|
		for
		;

assign:		TIDENTIFIER TEQUAL exp
		{
		  if(list != NULL)
	          {
		    if(list->exists($1) == 1)
	            { 
			list->setValue($1, $3);
		    }
		    else
		    {
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata!",@1.first_line, @1.first_column, $1);
	    		yyerror(msg);
	    		YYERROR;
		    }
                  }
		  else
		  {
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata!",@1.first_line, @1.first_column, $1);
	    		yyerror(msg);
	    		YYERROR;
		  }
		}
		;

exp:		term 
		|
		exp TPLUS term { $$ = $1 + $3; }
		|
		exp TMINUS term { $$ = $1 - $3; }
		;

term:		factor 
		|
		term TMUL factor { $$ = $1 * $3; }
		|
		term TDIV factor 
		{ 
		  if($3 == 0)
		  {
			sprintf(msg,"%d:%d Eroare semantica: Impartire la 0!",@1.first_line, @1.first_column);
	    		yyerror(msg);
	    		YYERROR;
		  }
		}
		;

factor:		TIDENTIFIER
		{
		  if(list != NULL)
		  {	            
		    if(list->exists($1) != 1)
		    {
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$1);
	    		yyerror(msg);
	    		YYERROR;
		    }
		  }
		  else
		  {
		   	sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$1);
	    		yyerror(msg);
	    		YYERROR;
		  }
		}
		|
		TINTVAL	{ $$ = $1; }
		|
		TLPAREN exp TRPAREN { $$ = $2; }
		;

read:		TREAD TLPAREN id_list TRPAREN
		{
		  if(list != NULL)
		  {
		    if(list->exists($3) == 0)
		    {
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$3);
	    		yyerror(msg);
	    		YYERROR;
		    }
		    list->setValue($3,0);
		  }
		  else
		  {
		    	sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$3);
	    		yyerror(msg);
	    		YYERROR;
		  }
                }
		;

write:		TWRITE TLPAREN id_list TRPAREN
		{
		  if(list != NULL)
		  {
		    if(list->exists($3) == 1)
		    {
			if(list->getValue($3) == -1)
			{
				sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fie initializata !",@1.first_line, @1.first_column,$3);
	    		yyerror(msg);
	    		YYERROR;
			}
		    }
		    else
		    {
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$3);
	    		yyerror(msg);
	    		YYERROR;
		    }
		  }
		  else
		  {
		    	sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$3);
	    		yyerror(msg);
	    		YYERROR;
		  }
		}
		;

for:		TFOR index_exp TDO body
		;

index_exp:	TIDENTIFIER TEQUAL exp TTO exp
		{
		   if(list == NULL)
		   {
			sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$1);
			yyerror(msg);
	    		YYERROR; 
		   }
		   else
		   {
			if(list->exists($1) == 0)
			{
				sprintf(msg,"%d:%d Eroare semantica: Variabila %s nu este declarata !",@1.first_line, @1.first_column,$1);
	    			yyerror(msg);
	    			YYERROR; 
			}
	           }
		}
		;

body:		stmt
		|
		TBEGIN stmt_list TEND
		;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s\n", msg);
	return 1;
}

