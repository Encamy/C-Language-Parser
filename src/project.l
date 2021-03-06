%option yylineno
%option noyywrap
%{
	#include <stdio.h>
	#include "project.tab.h"
%}
%%
"#include"([ ]+)?((<(\\.|[^>])+>)|(\"(\\.|[^"])+\"))					                                    {	yylval.value = strdup(yytext); 	return HEADER;	}
"void"|"char"|"short"|"int"|"long"|"float"|"double"|"signed"|"unsigned"|"bool"								{ 	yylval.value = strdup(yytext);	return TYPE;	}	
"if"																										{return IF;}
"else"																										{return ELSE;}
"for"																										{return FOR;}
"do"																										{return DO;}
"while"																										{return WHILE;}
"continue"																									{return CONTINUE;}
"break"																										{return BREAK;}
"struct"																									{return STRUCT;}
"return"																									{return RETURN;}
"||" 																										{return OR;}
"&&"																										{return AND;}
"=="|"!="|"<="|">="																							{yylval.value = strdup(yytext); return COMPARISON;}
"++"|"--"																									{return inc_const;}
"->"																										{return point_const;}
";"|"="|","|"{"|"}"|"("|")"|"["|"]"|"*"|"+"|"-"|"/"|"?"|":"|"&"|"|"|"^"|"!"|"~"|"%"|"<"|">"					{return yytext[0];}
"*="|"/="|"+="|"%="|">>="|"-="|"<<="|"&="|"^="|"|="															{yylval.value = strdup(yytext); return PUNC;}
[0-9]+																										{yylval.value = strdup(yytext); return number;}
[0-9]+"."[0-9]+																								{yylval.value = strdup(yytext); return number;}	
"'"."'"																										{yylval.value = strdup(yytext); return char_const;}
[a-zA-z_][a-zA-z_0-9]*			 																			{yylval.value = strdup(yytext); return id;}
\"(\\.|[^\"])*\"																							{yylval.value = strdup(yytext); return string;}
"//"(\\.|[^\n])*[\n]																						;
[/][*]([^*]|[*]*[^*/])*[*]+[/]                                                                              ;
[ \t\n]																										;
%%
