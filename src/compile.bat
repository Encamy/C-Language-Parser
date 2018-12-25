win_bison -d project.y
win_flex project.l
g++ -o parser.exe lex.yy.c project.tab.c 
pause