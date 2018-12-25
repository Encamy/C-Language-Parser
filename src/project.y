%{
	#include <stdio.h>
	#include <string.h>
	#include <iostream>
	int yylex(void);
	int yyerror(const char *s);
	int success = 1;
%}
%code requires { #include "Node.h" }

%union {
	Node * node;
	char * value;
}

%token <node> string STRUCT
%token <value> id TYPE HEADER char_const number enumeration_const
%token IF FOR DO WHILE BREAK CONTINUE RETURN PUNC OR AND COMPARISON inc_const
%token point_const ELSE

%type <node> external_declaration program_unit main_parse function_definition declaration decl_specs
%type <node> init_declarator_list type_specificator struct_or_union_spec struct_decl_list struct_decl
%type <node> spec_qualifier_list translation_unit declarator direct_declarator statement_list exp
%type <node> struct_declarator_list struct_declarator param_list param_decl compound_stat stat jump_statement
%type <node> assignment_exp conditional_exp logical_and_exp inclusive_or_exp exclusive_or_exp and_exp
%type <node> equality_exp relational_exp additive_exp mult_exp unary_exp logical_or_exp postfix_exp primary_exp
%type <node> decl_list init_declarator
%type <value> consts

%left '+' '-'
%left '*' '/'
%nonassoc "then"
%nonassoc ELSE
%start main_parse 
%%
main_parse: program_unit {
	$$ = $1;
	$$->print();
}
program_unit				: HEADER program_unit          								{$$ = new Node("Header", "'" + std::string($1)+ "'"); $$->addChild($2);}
							| translation_unit											{}		
							;
translation_unit			: external_declaration 										{$$ = $1;}
							| translation_unit external_declaration						{$$->addChild($2);}
							;
external_declaration		: function_definition										{$$ = new Node("Function definition"); $$->addChild($1);}			
							| declaration												{$$ = new Node("Declaration"); $$->addChild($1);}
							;
function_definition			: decl_specs declarator decl_list compound_stat 			{printf("function_definition1\n");}
							| declarator decl_list compound_stat						{printf("function_definition2\n");}
							| decl_specs declarator	compound_stat 						{$$ = new Node("Func"); $$->addChild($1); $$->addChild($2); $$->addChild($3);}	
							| declarator compound_stat                                  {printf("function_definition4\n");}
							;
declaration					: decl_specs init_declarator_list ';' 						{$$ = new Node("declaration"); $$->addChild($1); $$->addChild($2);}				
							| decl_specs ';'											{$$ = $1;}				
							;
decl_list					: declaration												{$$ = $1;}
							| decl_list declaration                                     {$$ = new Node("Declarations"); $$->addChild($2);}
							;
decl_specs					: type_specificator decl_specs								{$$ = new Node("decl_specs"); $$->addChild($1);}				
							| type_specificator 										{$$ = $1;}				
							;
type_specificator			: TYPE														{$$ = new Node("Type", $1);}
							| struct_or_union_spec										{$$ = new Node("Struct definition"); $$->addChild($1);}
							;
struct_or_union_spec		: STRUCT id '{' struct_decl_list '}'						{$$ = new Node("Struct", "'" + std::string($2)+ "'"); $$->addChild($4);}
							| STRUCT '{' struct_decl_list '}'
							| STRUCT id
							;
struct_decl_list			: struct_decl												{$$ = $1;}
							| struct_decl_list struct_decl								{$$ = new Node("Fields"); $$->addChild($1); $$->addChild($2);}
							;
init_declarator_list		: init_declarator											{$$ = $1;}
							| init_declarator_list ',' init_declarator					{$$ = new Node("init_declarator_list"); $$->addChild($1); $$->addChild($3);}	
							;
init_declarator				: declarator
							| declarator '=' initializer
							;
struct_decl					: spec_qualifier_list struct_declarator_list ';'			{$$ = new Node("Field"); $$->addChild($1); $$->addChild($2);}
							;
spec_qualifier_list			: type_specificator spec_qualifier_list						{}
							| type_specificator											{$$ = new Node("Type", $$->value);}
							;
struct_declarator_list		: struct_declarator											{$$ = $1;}
							| struct_declarator_list ',' struct_declarator				{}
							;
struct_declarator			: declarator												{$$ = $1;}	
							| declarator ':' const_exp
							| ':' const_exp
							;
declarator					: pointer direct_declarator									{$$ = $2;}
							| direct_declarator											{$$ = $1;}
							;
direct_declarator			: id 														{$$ = new Node("Id", $1);}
							| '(' declarator ')'										{$$ = new Node("ID1");}
							| direct_declarator '[' const_exp ']'						{$$ = new Node("ID2");}	
							| direct_declarator '['	']'                                 {$$ = new Node("ID3");}
							| direct_declarator '(' param_list ')' 			            {$$ = $3;}
							| direct_declarator '(' id_list ')' 					    {$$ = new Node("ID5");}
							| direct_declarator '('	')' 							    {$$ = new Node("ID6");}
							;
pointer						: '*'
							| '*' pointer
							;
param_list					: param_decl												{$$ = $1;}	
							| param_list ',' param_decl									{$$ = new Node("Arguments"); $$->addChild($1); $$->addChild($3);}	
							;
param_decl					: decl_specs declarator										{$$ = new Node("Argument"); $$->addChild($1); $$->addChild($2);}
							| decl_specs												{$$ = new Node("Argument"); $$->addChild($1);}
							;
id_list						: id
							| id_list ',' id
							;
initializer					: assignment_exp
							| '{' initializer_list '}'
							| '{' initializer_list ',' '}'
							;
initializer_list			: initializer
							| initializer_list ',' initializer
							;
stat						: exp_stat 											  		{$$ = new Node("Stat1");}
							| compound_stat 									  	    {$$ = new Node("Stat2");}
							| selection_statement  									    {$$ = new Node("Stat3");}
							| loop_statement                                            {$$ = new Node("Stat4");}
							| jump_statement                                            {$$ = $1;}
							;
exp_stat					: exp ';'
							| ';'
							;
compound_stat				: '{' decl_list statement_list '}'   						{$$ = new Node("Body"); $$->addChild($2); $$->addChild($3);}
							| '{' statement_list '}'									{$$ = new Node("Body"); $$->addChild($2);}	
							| '{' decl_list	'}'										    {$$ = new Node("Body3");}
							| '{' '}'												    {$$ = new Node("Body4");}
							;
statement_list				: stat     													{$$ = $1;}											
							| statement_list stat  										{$$ = new Node("statement_list"); $$->addChild($2);}
							;
selection_statement			: IF '(' exp ')' stat 									%prec "then"
							| IF '(' exp ')' stat ELSE stat
							;
loop_statement			: WHILE '(' exp ')' stat
							| DO stat WHILE '(' exp ')' ';'
							| FOR '(' exp ';' exp ';' exp ')' stat
							| FOR '(' exp ';' exp ';'	')' stat
							| FOR '(' exp ';' ';' exp ')' stat
							| FOR '(' exp ';' ';' ')' stat
							| FOR '(' ';' exp ';' exp ')' stat
							| FOR '(' ';' exp ';' ')' stat
							| FOR '(' ';' ';' exp ')' stat
							| FOR '(' ';' ';' ')' stat
							;
jump_statement				: CONTINUE ';'												{$$ = new Node("continue");}
							| BREAK ';'                                                 {$$ = new Node("break");}
							| RETURN exp ';'                                            {$$ = new Node("return expression"); $$->addChild($2);}
							| RETURN ';'                                                {$$ = new Node("return");}
							;
exp							: assignment_exp											{$$ = $1;}	
							| exp ',' assignment_exp									{$$ = new Node("Return expression"); $$->addChild($3);}
							;
assignment_exp				: conditional_exp											{$$ = $1;}
							| unary_exp assignment_operator assignment_exp				{$$ = new Node("Assignment expression");}
							;
assignment_operator			: PUNC
							| '='
							;
conditional_exp				: logical_or_exp											{$$ = $1;}
							| logical_or_exp '?' exp ':' conditional_exp				{$$ = new Node("Ternary placeholder");}
							;	
const_exp					: conditional_exp
							;
logical_or_exp				: logical_and_exp											{$$ = $1;}
							| logical_or_exp OR logical_and_exp							{$$ = new Node("OR"); $$->addChild($1); $$->addChild($3);}
							;
logical_and_exp				: inclusive_or_exp											{$$ = $1;}	
							| logical_and_exp AND inclusive_or_exp						{$$ = new Node("AND"); $$->addChild($1); $$->addChild($3);}
							;
inclusive_or_exp			: exclusive_or_exp											{$$ = $1;}	
							| inclusive_or_exp '|' exclusive_or_exp                     {$$ = new Node("|"); $$->addChild($1); $$->addChild($3);}
							;
exclusive_or_exp			: and_exp													{$$ = $1;}	
							| exclusive_or_exp '^' and_exp                              {$$ = new Node("^"); $$->addChild($1); $$->addChild($3);}
							;
and_exp						: equality_exp												{$$ = $1;}	
							| and_exp '&' equality_exp                                  {$$ = new Node("&"); $$->addChild($1); $$->addChild($3);}
							;
equality_exp				: relational_exp											{$$ = $1;}	
							| equality_exp COMPARISON relational_exp                    {$$ = new Node("COMPARISON"); $$->addChild($1); $$->addChild($3);}
							;
relational_exp				: additive_exp												{$$ = $1;}	
							| relational_exp '<' additive_exp                           {$$ = new Node("<"); $$->addChild($1); $$->addChild($3);}
							| relational_exp '>' additive_exp							{$$ = new Node(">"); $$->addChild($1); $$->addChild($3);}	
							;
additive_exp				: mult_exp													{$$ = $1;}	
							| additive_exp '+' mult_exp                                 {$$ = new Node("+"); $$->addChild($1); $$->addChild($3);}
							| additive_exp '-' mult_exp                                 {$$ = new Node("-"); $$->addChild($1); $$->addChild($3);}
							;
mult_exp					: unary_exp													{$$ = $1;}	
							| mult_exp '*' unary_exp                                	{$$ = new Node("+"); $$->addChild($1); $$->addChild($3);}
							| mult_exp '/' unary_exp                                	{$$ = new Node("/"); $$->addChild($1); $$->addChild($3);}
							| mult_exp '%' unary_exp									{$$ = new Node("%"); $$->addChild($1); $$->addChild($3);}
							;
unary_exp					: postfix_exp												{$$ = $1;}	
							| inc_const unary_exp                                       {$$ = new Node("++ or --"); $$->addChild($2);}
							| unary_operator unary_exp                                  {$$ = new Node("unary operator"); $$->addChild($2);}
							;
unary_operator				: '&' | '*' | '+' | '-' | '~' | '!' 				
							;
postfix_exp					: primary_exp 												{$$ = $1;}
							| postfix_exp '[' exp ']'                                   {$$ = new Node("Postfix expression");}
							| postfix_exp '(' argument_exp_list ')'                     {$$ = new Node("Postfix expression");}
							| postfix_exp '(' ')'                                       {$$ = new Node("Postfix expression");}
							| postfix_exp '.' id                                        {$$ = new Node("Postfix expression");}
							| postfix_exp point_const id                                {$$ = new Node("Postfix expression");}
							| postfix_exp inc_const                                     {$$ = new Node("Postfix expression");}
							;
primary_exp					: id 														{$$ = new Node("id", $1);}
							| consts 													{$$ = new Node("Value", $1);}
							| string 													{$$ = new Node("string");}
							| '(' exp ')'												{$$ = new Node("expression"); $$->addChild($2);}
							;
argument_exp_list			: assignment_exp
							| argument_exp_list ',' assignment_exp
							;
consts						: number 													{$$ = $1;}
							| char_const                                                {$$ = $1;}
							| enumeration_const                                         {$$ = $1;}
							;
%%

int main()
{
    yyparse();
    if(success)
    	printf("Parsing Successful\n");
    return 0;
}

int yyerror(const char *msg)
{
	extern int yylineno;
	printf("Parsing Failed\nLine Number: %d %s\n",yylineno,msg);
	success = 0;
	return 0;
}

