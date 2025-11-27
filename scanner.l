%{
#include <stdio.h>
#include "parser.tab.h" 

int modo_parser = 0;
int error = 0;
%}

%option noyywrap yylineno

%%

[1-9]           { 
    #ifdef PARSER_MODE 
        yylval.num = atoi(yytext); 
    #endif 
        return DIGITOPOSITIVO; 
    }
[0-9]           { 
    #ifdef PARSER_MODE 
        yylval.num = atoi(yytext); 
    #endif 
        return DIGITO; 
    }

hola        { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return HOLA; }
chau        { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return CHAU; }
ingresar    { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return INGRESAR; }
mostrar     { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return MOSTRAR; }
cerrado     { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return CERRADO; }
enAnalisis  { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return ENANALISIS; }
si          { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return SI; }
siNo        { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return SINO; }
siParaTodo  { if(!modo_parser) printf( "PALABRA_RESERVADA: %s\n", yytext ); return SIPARATODO; }

[a-z][a-z0-9]{0,15}     { 
        if(!modo_parser) printf("IDENTIFICADOR: %s\n", yytext); 
    #ifdef PARSER_MODE 
        yylval.str = strdup(yytext); 
    #endif 
        return IDENTIFICADOR; 
    }

[A-Z][A-Z]+              { 
        if(!modo_parser) printf("EVENTO: %s\n", yytext); 
    #ifdef PARSER_MODE 
        yylval.str = strdup(yytext); 
    #endif 
        return EVENTO; 
    }

[A-Z]                   { 
        if(!modo_parser) printf("SUBEVENTO: %s\n", yytext); 
    #ifdef PARSER_MODE 
        yylval.ch = yytext[0]; 
    #endif 
        return SUBEVENTO; 
    }

"("                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return PAREN_ABRE; }
")"                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return PAREN_CIERRA; }
"{"                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return LLAVE_ABRE; }
"}"                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return LLAVE_CIERRA; }
"["                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return CORCH_ABRE; }
"]"                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return CORCH_CIERRA; }
"."                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return PUNTO; }
"-"                     { if(!modo_parser) printf("CARACTER_PUNTUACION: %s\n", yytext); return GUION; }

"<"                 { if(!modo_parser) printf("ASIGNACION: <\n"); return ASIGNACION; }

"?"                { if(!modo_parser) printf("COMPARACION: ?\n"); return COMPARACION; }

[ \t\r\n]+            { }

.                   { if(!modo_parser) { printf("❌ ERROR LÉXICO: Caracter no reconocido: %s\n", yytext); error++; } return CARACTER_DESCONOCIDO; }


%%

#ifndef PARSER_MODE
int main(int argc, char **argv)
{
    FILE *archivo = NULL;

    /* Verificar que se haya pasado un argumento */
    if (argc < 2) {
        fprintf(stderr, "❌ Error: No se especificó ningún archivo.\n");
        fprintf(stderr, "Uso: %s <ruta_del_archivo>\n", argv[0]);
        return 1;
    }

    /* Intentar abrir el archivo */
    archivo = fopen(argv[1], "r");
    if (!archivo) {
        perror("❌ Error al abrir el archivo");
        return 1;
    }

    yyin = archivo;

    modo_parser = 0;
    error = 0;

    /* Ejecutar análisis léxico completo */
    while (yylex())
        ;

    if (error >= 1)
        printf("❌ Análisis léxico completado con %d error/es.\n", error);
    else
        printf("✅ Análisis léxico completado sin errores.\n");

    fclose(archivo);
    return 0;
}
#endif
