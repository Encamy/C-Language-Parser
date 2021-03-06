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

%token <node> STRUCT
%token <value> id TYPE HEADER char_const number enumeration_const PUNC COMPARISON string
%token IF FOR DO WHILE BREAK CONTINUE RETURN OR AND inc_const
%token point_const ELSE

%type <node> external_declaration program_unit main_parse function_definition declaration decl_specs
%type <node> init_declarator_list type_specificator struct_or_union_spec struct_decl_list struct_decl
%type <node> spec_qualifier_list translation_unit declarator direct_declarator exp assignment_operator
%type <node> struct_declarator_list struct_declarator param_list param_decl compound_stat stat jump_statement
%type <node> assignment_exp conditional_exp logical_and_exp inclusive_or_exp exclusive_or_exp and_exp argument_exp_list
%type <node> equality_exp relational_exp additive_exp mult_exp unary_exp logical_or_exp postfix_exp primary_exp
%type <node> decl_list init_declarator body_list decl_or_statement loop_statement exp_stat selection_statement
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
declaration					: decl_specs init_declarator_list ';' 						{$$ = new Node("Declaration"); $$->addChild($1); $$->addChild($2);}				
							| decl_specs ';'											{$$ = $1;}				
							;
decl_list					: declaration												{$$ = $1;}
							| decl_list declaration                                     {$$ = new Node("Declarations"); $$->addChild($1); $$->addChild($2);}
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
							| direct_declarator '(' param_list ')' 			            {$$ = new Node("'" + $1->value + "'"); $$->addChild($3);}
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
stat						: exp_stat 											  		{$$ = $1;}
							| compound_stat 									  	    {$$ = $1;}
							| selection_statement  									    {$$ = $1;}
							| loop_statement                                            {$$ = $1;}
							| jump_statement                                            {$$ = $1;}
							;
exp_stat					: exp ';'													{$$ = $1;}
							| ';'														{$$ = new Node("");}
							;
body_list					: decl_or_statement											{$$ = new Node("Declarations"); $$->addChild($1);}
							| body_list decl_or_statement								{$$ = $1; $$->addChild($2);}
							;
decl_or_statement			: declaration												{$$ = $1;}
							| stat														{$$ = $1;}
							;
compound_stat				: '{' body_list '}'											{$$ = new Node("Body"); $$->addChild($2);}	
							| '{' '}'												    {$$ = new Node("Empty body");}
							;
selection_statement			: IF '(' exp ')' stat 									%prec "then"	{$$ = new Node("If"); $$->addChild($3); $$->addChild($5);}
							| IF '(' exp ')' stat ELSE stat								{$$ = new Node("If", "else"); $$->addChild($3); $$->addChild($5); $$->addChild($7);}
							;
loop_statement				: WHILE '(' exp ')' stat									{$$ = new Node("While loop"); $$->addChild($3); $$->addChild($5);}
							| DO stat WHILE '(' exp ')' ';'                             {$$ = new Node("Loop");}
							| FOR '(' exp ';' exp ';' exp ')' stat                      {$$ = new Node("For loop"); $$->addChild($3); $$->addChild($5); $$->addChild($7); $$->addChild($9); }
							| FOR '(' exp ';' exp ';'	')' stat                        {$$ = new Node("For loop"); $$->addChild($3); $$->addChild($5); $$->addChild($8); }
							| FOR '(' exp ';' ';' exp ')' stat                          {$$ = new Node("For loop"); $$->addChild($3); $$->addChild($6); $$->addChild($8); }
							| FOR '(' exp ';' ';' ')' stat                              {$$ = new Node("For loop"); $$->addChild($3); $$->addChild($7); }
							| FOR '(' ';' exp ';' exp ')' stat                          {$$ = new Node("For loop"); $$->addChild($4); $$->addChild($6); $$->addChild($8); }
							| FOR '(' ';' exp ';' ')' stat                              {$$ = new Node("For loop"); $$->addChild($4); $$->addChild($7); }
							| FOR '(' ';' ';' exp ')' stat                              {$$ = new Node("For loop"); $$->addChild($5); $$->addChild($7); }
							| FOR '(' ';' ';' ')' stat                                  {$$ = new Node("For loop"); $$->addChild($6); }
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
							| unary_exp assignment_operator assignment_exp				{$$ = new Node("Assignment expression"); $$->addChild($1); $$->addChild($2); $$->addChild($3); }
							;
assignment_operator			: PUNC														{$$ = new Node($1);}	
							| '='														{$$ = new Node("=");}
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
							| equality_exp COMPARISON relational_exp                    {$$ = new Node($2); $$->addChild($1); $$->addChild($3);}
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
							| postfix_exp '[' exp ']'                                   {$$ = new Node("Array element access"); $$->addChild($1); $$->addChild($3); }
							| postfix_exp '(' argument_exp_list ')'                     {$$ = new Node("Function call"); $$->addChild($1); $$->addChild($3); }
							| postfix_exp '(' ')'                                       {$$ = new Node("Function call"); $$->addChild($1); }
							| postfix_exp '.' id                                        {$$ = new Node("Struct field access", $3); $$->addChild($1); }
							| postfix_exp point_const id                                {$$ = new Node("Pointer access", "->" + std::string($3)); $$->addChild($1);}
							| postfix_exp inc_const                                     {$$ = new Node("Increment/Decrement"); $$->addChild($1); }
							;
primary_exp					: id 														{$$ = new Node("id", $1);}
							| consts 													{$$ = new Node("Value", $1);}
							| string 													{$$ = new Node("string", $1);}
							| '(' exp ')'												{$$ = new Node("expression"); $$->addChild($2);}
							;
argument_exp_list			: assignment_exp											{$$ = $1;}
							| argument_exp_list ',' assignment_exp						{$$ = $3; $$->addChild($1);}
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

