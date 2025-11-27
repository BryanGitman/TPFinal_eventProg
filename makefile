# ---------------------------
# Makefile para Flex + Bison
# ---------------------------

# Compilador
CC = gcc

# Flags de compilación
CFLAGS = -Wall
IGNORARWAR = -Wno-unused-function

# Archivos fuente
LEX_SRC = scanner.l
YACC_SRC = parser.y

# Archivos generados
LEX_OUT = lex.yy.c
YACC_OUT = parser.tab.c
YACC_HEADER = parser.tab.h

# Ejecutables finales
SCANNER = scanner
PARSER = parser

# Archivos del programa ejecutable
GENERATED = *.c *.exe

# ---------------------------
# Reglas principales
# ---------------------------

# Compila todo (scanner + parser)
all: $(PARSER) $(SCANNER)

# ---------------------------
# Compilación del parser (usa Bison + Flex)
# ---------------------------

$(PARSER): $(YACC_OUT) $(LEX_OUT)
	$(CC) $(CFLAGS) $(IGNORARWAR) -DPARSER_MODE -o $(PARSER) $(YACC_OUT) $(LEX_OUT) -lfl

$(YACC_OUT): $(YACC_SRC)
	bison -d $(YACC_SRC)

$(LEX_OUT): $(LEX_SRC) $(YACC_HEADER)
	flex $(LEX_SRC)

# ---------------------------
# Compilación del scanner solo (sin parser)
# ---------------------------

$(SCANNER): $(LEX_SRC)
	flex $(LEX_SRC)
	$(CC) $(CFLAGS) $(IGNORARWAR) -o $(SCANNER) lex.yy.c -lfl

# ---------------------------
# Limpieza
# ---------------------------

clean:
	rm -f $(LEX_OUT) $(YACC_OUT) $(YACC_HEADER) $(SCANNER) $(PARSER) $(GENERATED)

# ---------------------------
# Uso rápido
# ---------------------------
# make         -> compila todo
# make scanner -> solo el scanner
# make parser  -> parser completo
# make clean   -> borra todo lo generado
