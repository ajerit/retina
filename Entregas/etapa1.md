# Retina

## Etapa 1 - Analizador Lexicográfico

En este documento se especifican los requerimientos necesarios para la primera entrega en el desarrollo de su intérprete. Aquí no estarán presente caracteristicas del lenguaje, sintaxis o ningún tipo de especificación.

La especificación puede verse en este [documento].

## Requerimientos

- El objetivo principal de esta etapa es desarrollar una analizador lexicográfico usando el lenguaje que haya elegido, ya sea `C`, `Ruby` o `Haskell`, junto a su respectiva herramiento; en caso de que exista.
    - La versión de `Ruby` con la que se corregirá será `2.1.5`.
    - La versión de `Haskell` con la que se corregirá será `7.8.4`.
- Su programa debe ejecutarse con el comando `./retina programa.rtn` desde la linea de comandos. Sólo habrá un argumento en la misma, el cual será la ruta de un archivo.
- Se debe abrir dicho archivo, ir reconociendo lexemas del programa (llamados también *tokens*). Los cuales son elementos pertenecientes al lenguaje, como palabras reservadas, identificadores, símbolos, etc.
- Si toda el archivo de entrada es consumido y reconocido, se deben imprimir, en lista, cada uno de los *tokens* con su respectiva linea y columna donde se encuentre en el archivo.
- En el caso de que un *token* no sea reconocido, se debe seguir leyendo el archivo hasta el final y reportar todo elemento desconcido.
- El contador de linea y columna comienzan a partir de `1`.
- No es debe realizar ningún analisis sintáctico, ni reportar errores semánticos o de contexto.

## Ejemplos

### Entrada 1

```
program
    with
        number x = 4;
    do
        repeat x times
            forward(50);
            rotatel(90);
        end;
    end;
end;
```

### Salida 1

```
linea 1, columna 1: palabra reservada 'program' 
linea 2, columna 5: palabra reservada 'with' 
linea 3, columna 9: tipo de dato 'number'
linea 3, columna 16: identificador 'x'
linea 3, columna 18: signo '='
linea 3, columna 20: literal numérico '4'
linea 3, columna 21: signo ';'
linea 4, columna 5: palabra reservada 'do' 
linea 5, columna 9: palabra reservada 'repeat' 
linea 5, columna 16: identificador 'x'
linea 5, columna 18: palabra reservada 'times' 
linea 6, columna 13: identificador 'forward'
linea 6, columna 20: signo '('
linea 6, columna 21: literal numérico '50'
linea 6, columna 23: signo ')'
linea 6, columna 24: signo ';'
linea 7, columna 13: identificador 'rotatel'
linea 7, columna 20: signo '('
linea 7, columna 21: literal numérico '90'
linea 7, columna 23: signo ')'
linea 7, columna 24: signo ';'
linea 8, columna 9: palabra reservada 'end' 
linea 8, columna 12: signo ';'
linea 9, columna 5: palabra reservada 'end' 
linea 9, columna 8: signo ';'
linea 10, columna 1: palabra reservada 'end' 
linea 10, columna 4: signo ';'
```

### Entrada 2

```
program
    repeat 2 times {
        forward(50);
    }    
end;
```

### Salida 2

```
linea 2, columna 20: caracter inesperado '{'
linea 4, columna 5: caracter inesperado '}'
```

### Entrada 3

```
program
repeat
forward
i
j
k  
end
;;;

```

### Salida 3

```
linea 1, columna 1: palabra reservada 'program'
linea 2, columna 1: palabra reservada 'repeat'
linea 3, columna 1: identificador 'forward'
linea 4, columna 1: identificador 'i'
linea 5, columna 1: identificador 'j'
linea 6, columna 1: identificador 'k'
linea 7, columna 1: palabra reservada 'end'
linea 8, columna 1: signo ';'
linea 8, columna 2: signo ';'
linea 8, columna 3: signo ';'
```

[documento]: <https://github.com/dvdalilue/retina/blob/master/lenguaje/especificacion.md>