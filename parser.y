%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>
extern int yylineno;

int yylex(void);
int yyerror(const char *s);
int errores_sintacticos = 0;

FILE *out;
char archivo_exe[300];
%}

%define parse.error verbose

%union {
    char* str;  
    int   num;  
    char ch;
}

%type <num> posicion

%token <num> DIGITO DIGITOPOSITIVO
%token HOLA CHAU INGRESAR MOSTRAR CERRADO ENANALISIS SI SINO SIPARATODO
%token <str> IDENTIFICADOR EVENTO 
%token <ch> SUBEVENTO
%token ASIGNACION COMPARACION
%token PAREN_ABRE PAREN_CIERRA CORCH_ABRE CORCH_CIERRA LLAVE_ABRE LLAVE_CIERRA PUNTO GUION
%token CARACTER_DESCONOCIDO

%start input

%%

input: 
  HOLA PUNTO 
    {
        fprintf(out, "#include <stdio.h>\n#include <string.h>\n#include <ctype.h>\n");
        fprintf(out, "int validar_evento_o_subevento(const char *s) {\n if (s == NULL) return 0;\nsize_t n = strlen(s);\nif (n == 0) return 0;\n\nfor (size_t i = 0; i < n; ++i) {\nunsigned char c = (unsigned char) s[i];\nif (!isupper(c)) return 0;\n}\nreturn 1;\n}\n");
        fprintf(out, "int main(int argc, char **argv) {\nif (argc != 2) {\nfprintf(stderr, \"Uso: ./%s <EVENTO|SUBEVENTO>\");\n puts(\"\");\nreturn 1;\n}\nif (!validar_evento_o_subevento(argv[1])) {\nfprintf(stderr, \"Parametro inválido: Un evento o subevento debe ser solo letras A-Z (ej: E o AA).\");\n puts(\"\");\nreturn 1;\n}\n", archivo_exe);
        fprintf(out, "char* evento;\n");
        fprintf(out, "int esIgual;\n");
    }
  lectura 
  proceso 
  CHAU PUNTO 
    {
        fprintf(out, "    return 0;\n");
        fprintf(out, "}\n"); 
    }
  | error PUNTO { 
        yyerrok; 
        yyclearin; 
    } posiblesCierres proceso CHAU PUNTO
  | error LLAVE_CIERRA { 
        yyerrok; 
        yyclearin; 
    } casoContrario posiblesCierres proceso CHAU PUNTO
  | error CHAU PUNTO { 
        yyerrok; 
        yyclearin; 
    } 
;

/* Para la recuperacion de errores*/
posiblesCierres:
      /* vacío */
    | LLAVE_CIERRA casoContrario posiblesCierres
;

lectura:
  asignar
| asignar lectura
;

asignar:
  IDENTIFICADOR ASIGNACION {fprintf(out, "evento = ");} asignando PUNTO
| subIdentificador ASIGNACION {fprintf(out, " = ");} subAsignando PUNTO
;

asignando:
  EVENTO {fprintf(out, "\"%s\";\n", $1);}
| IDENTIFICADOR {fprintf(out, "evento;\n");}
| INGRESAR {fprintf(out, "(argc < 2) ? \"\" : argv[1];\n");}
;

subAsignando:
  SUBEVENTO {fprintf(out, "\'%c\';\n", $1);}
| subIdentificador 
| INGRESAR {fprintf(out, "(argc < 2) ? "" : argv[1];\n");}
;

subIdentificador:
  IDENTIFICADOR CORCH_ABRE posicion CORCH_CIERRA
  {fprintf(out, "evento[%d]", $3 - 1);}
;

posicion:
  DIGITOPOSITIVO      { $$ = $1; }
| posicion DIGITO     { $$ = $1 * 10 + $2; }
;

proceso:
  evaluacion proceso
| lectura proceso
| devolucion proceso
| /* vacío */
;

evaluacion:
      SIPARATODO PAREN_ABRE
      {
        fprintf(out, "esIgual = 1;\n for(int i = 0; i < strlen(evento); i++) {\n if(");
      } relacionParaTodo PAREN_CIERRA LLAVE_ABRE 
      {
        fprintf(out, "esIgual = 0;\n}\n}\nif(esIgual){\n");
      }proceso LLAVE_CIERRA 
      {
        fprintf(out, "}\n");
      } casoContrario
    | SI PAREN_ABRE 
      {
        fprintf(out, "if(");
      } relacion PAREN_CIERRA LLAVE_ABRE proceso LLAVE_CIERRA
      {
        fprintf(out, "}\n");
      } casoContrario
  

casoContrario:
      SINO LLAVE_ABRE 
      {
        fprintf(out, "else{\n");
      } proceso LLAVE_CIERRA
      {
        fprintf(out, "}\n");
      }
    | /* vacío */
    ;

relacionParaTodo:
      IDENTIFICADOR CORCH_ABRE GUION CORCH_CIERRA COMPARACION SUBEVENTO {fprintf(out, "evento[i] != \'%c\') {\n", $6);}
    | IDENTIFICADOR CORCH_ABRE GUION CORCH_CIERRA COMPARACION {fprintf(out, "evento[i] != ");} subIdentificador {fprintf(out, ") {\n");}
    | SUBEVENTO COMPARACION IDENTIFICADOR CORCH_ABRE GUION CORCH_CIERRA {fprintf(out, "evento[i] != \'%c\') {\n", $1);}
    | subIdentificador COMPARACION IDENTIFICADOR CORCH_ABRE GUION CORCH_CIERRA {fprintf(out, " != evento[i]) {\n");}
    ;

relacion:
      IDENTIFICADOR COMPARACION IDENTIFICADOR {fprintf(out, "evento == evento) {\n");}
    | IDENTIFICADOR COMPARACION EVENTO {fprintf(out, "evento == \"%s\") {\n", $3);}
    | EVENTO COMPARACION IDENTIFICADOR {fprintf(out, "evento == \"%s\") {\n", $1);}
    | EVENTO COMPARACION EVENTO {fprintf(out, "\"%s == \"%s) {\n", $1, $3);}
    | subIdentificador COMPARACION {fprintf(out, " == ");} subIdentificador {fprintf(out, ") {\n");}
    | subIdentificador COMPARACION SUBEVENTO {fprintf(out, " == '%c') {\n", $3);}
    | SUBEVENTO COMPARACION {fprintf(out, "\'%c\' == ", $1);} subIdentificador {fprintf(out, ") {\n");}
    | SUBEVENTO COMPARACION SUBEVENTO {fprintf(out, "\'%c\' == \'%c\') {\n", $1, $3);}
    ;

devolucion:
      MOSTRAR PAREN_ABRE
      {
        fprintf(out, "printf(");
      } contenido PAREN_CIERRA PUNTO
      {
        fprintf(out, ");\n puts(\"\");\n");
      }
    ;

contenido:
      CERRADO {fprintf(out, "\"Estado: CERRADO\"");}
    | ENANALISIS {fprintf(out, "\"Estado: EN ANALISIS\"");}
    | IDENTIFICADOR {fprintf(out, "\"%%s\", evento");}
    | subIdentificador
    | EVENTO {fprintf(out, "\"%s\"", $1);}
    | SUBEVENTO {fprintf(out, "\'%c\'", $1);}
    ;

%%

int main(int argc, char **argv) {
    extern FILE *yyin;
    extern int modo_parser;

    /* Verificar que se haya pasado un archivo */
    if (argc < 2) {
        fprintf(stderr, "❌ Error: No se especificó ningún archivo.\n");
        fprintf(stderr, "Uso: %s <ruta_del_archivo>\n", argv[0]);
        return 1;
    }

    /* Intentar abrir el archivo */
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror("❌ Error al abrir el archivo");
        return 1;
    }

    modo_parser = 1;

    /* Obtener nombre del archivo */
    char *input = basename(argv[1]);
    char base[256];
    strcpy(base, input);
    char *p = strrchr(base, '.');
    if (p) *p = '\0';
    char archivo_c[300];
    sprintf(archivo_c, "%s.c", base);
    sprintf(archivo_exe, "%s.exe", base);

    out = fopen(archivo_c, "w");
    if (!out) { perror(archivo_c); exit(1); }

    /* Ejecutar análisis sintáctico */
    if (yyparse() == 0 && errores_sintacticos == 0)
    {
      printf("✅ Análisis sintáctico completado sin errores.\n");
      fclose(out);
      char comando[800];
      snprintf(comando, sizeof(comando), "gcc %s -o %s", archivo_c, archivo_exe);
      system(comando);
      int res = system(comando);
      if (res != 0) {
          printf("❌ Error al compilar %s. Revisá el código generado.\n", archivo_c);
      } else {
          printf("✅ Archivo ejecutable listo: ./%s <EVENTO|SUBEVENTO>.\n", archivo_exe);
      }
    }
    else if (errores_sintacticos > 0)
      printf("❌ Análisis sintáctico completado con %d error/es.\n", errores_sintacticos);
    
    fclose(yyin);

    return 0;
}

int yyerror(const char *s) {
    extern char *yytext;
    errores_sintacticos++;  
    fprintf(stderr, "❌ Error sintáctico en línea %d cerca de '%s': %s\n",
            yylineno, yytext, s);
    return 0;
}
