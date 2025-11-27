# TPFinal_eventProg

## Explicación

Este lenguaje tiene como objetivo el manejo de eventos compuestos por n subeventos.

Un **evento** es una cadena de letras mayúsculas (A-Z). Cada una de las letras, representa un **subevento** (que también se puede considerar como un evento compuesto por un solo subevento). Por ejemplo, estos son algunos eventos posibles: AZDSFZA, DS, SYSL, ZZZ, W, Z.

El valor de la letra representa el estado en el que se encuentra el evento, iniciandose en **A** y cerrandose en **Z**. Es por eso que para que un evento completo se encuentre en estado **cerrado**, todos sus subeventos deben estar en Z. De no ser así, el evento está en análisis. Por ejemplo, los primeros 3 eventos mencionados antes y W están en análisis, mientras que ZZZ y Z están cerrados.

Más información sobre el lenguaje eventProg: [https://docs.google.com/document/d/1kPvgyt2iFftWm7VkBOJwdbBzu6cqPpEjoG-TiaFVjVU/edit?usp=sharing](https://docs.google.com/document/d/1kPvgyt2iFftWm7VkBOJwdbBzu6cqPpEjoG-TiaFVjVU/edit?usp=sharing)

## Inicio

Para **compilar todo**, el scanner y el parser, y que se creen los archivos necesarios para el funcionamiento del compilador, ejecutar el siguiente comando en el directorio principal:

```
make
```

Dentro de la carpeta **ejemplos** se encuentran algunos archivos con código plano para probar.

## Scanner

Si por algún motivo se requiere ejecutar el scanner solo y ver en detalle el **análisis léxico** del código, ejecutar el siguiente comando en el directorio principal cambiando {rutaArchivo} por la ruta del archivo que contiene el código:

```
./scanner {rutaArchivo}
```

## Parser

Para poder realizar el análisis completo y ver en detalle el **análisis sintáctico** del código con sus errores, ejecutar el siguiente comando en el directorio principal cambiando {rutaArchivo} por la ruta del archivo que contiene el código:

```
./parser {rutaArchivo}
```

Al ejecutarse este comando, se creará un archivo **.c** con el código convertido a lenguaje C y, solo en caso de completarse el análisis exitosamente, se creará además un archivo **.exe** con el ejecutable para poder finalmente usar el programa codeado. Ambos archivos llevarán el mismo nombre que el que contiene el código plano.

## Ejecutable

Una vez creado el archivo ejecutable .exe, se podrá utilizar el programa creado ingresando el siguiente comando en el directorio principal, cambiando {nombreArchivo} por el nombre del ejecutable y {evento} por el único evento que se desee ingresar:

```
./{nombreArchivo}.exe {evento}
```

A continuación, se ejecutará el programa, devolviendo (en caso de haberse programado de esa manera) el estado del evento, o lo que el código creado muestre por consola.