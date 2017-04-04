# Retina

## Etapa 2 - Analizador Sintáctico

En este documento se especifican los requerimientos necesarios para la segunda entrega en el desarrollo de su intérprete. Aquí no estarán presente caracteristicas del lenguaje, sintaxis o ningún tipo de especificación.

La especificación puede verse en este [documento].

## Requerimientos

- El objetivo principal de esta etapa es desarrollar un analizador sintáctico LALR(1) para Retina usando el lenguaje que haya elegido, ya sea `Ruby` o `Haskell`, junto a su respectiva herramienta generadora de *parsers*. Independientemente del caso, deberá definir una gramática para Retina, siguiendo el formato de la herramienta.
    - Racc, en el caso de `Ruby`.
    - Happy, en el caso de `Haskell`.
- Un objetivo específico es que usted defina una gramática sin conflictos *shift/reduce* ni *reduce/reduce*. En ciertos casos las ambigüedades son resueltas definiendo las reglas de precedencia junto a su gramática.
- En `Ruby` es aconsejable definir un jerarquía de clases para representar el comportamiento de cada nodo en el árbol sintáctico abstracto. Por otro lado, en `Haskell`, deberá definir tipos de datos para representar cada nodo del árbol. No se espera que defina un solo tipo o clase para representar todo.
- Debe establecer una correspondencia entre las producción de su gramática y la construcción de un nodo de su árbol sintáctico abstracto.
- Su programa debe ejecutarse con el comando `./retina programa.rtn` desde la linea de comandos. Sólo habrá un argumento en la misma, el cual será la ruta de un archivo.
- Se debe abrir dicho archivo y consumirlo por completo para producir un árbol sintáctico abstracto, si la sintaxis del programa es válida. El analizador sintáctico trabaja a partir de la secuencia de *tokens* generada de su analizador lexicográfico.
- En el caso de que existan errores lexicográficos, debe reportarlos todos; al igual que la primera entrega. En caso de que exista un error sintáctico, deberá reportar el primero que encuentre; indicando la posición y *token* donde ocurrió el error.
- Si toda el archivo de entrada es consumido y reconocido como válido, debe imprimirse cada nodo del árbol, es decir, lo que representa y los subárboles que contenga. El uso de indentación es necesario para identificar la contención de los árboles.
- Los nombres de cada nodo del árbol, la correspondencia de entre los elementos sintácticos y los nodos del árbol sintáctico abstracto, el formato de salida y errores quedan a su desición. Sólo se necesita que se brinde alguna información representativa de lo que significa cada nodo.

## Ejemplos

Aquí se muestra lo que sería una porción de un programa y su representación en árbol.

```
with
    number i;
do
    i = 27;
    writeln i + 13;
end;
```

```
Bloque:
    declaraciones:
        Declaración:
            tipo:
                Tipo:
                    nombre: number
            identificadores:
                Indentificador:
                    nombre: i
    instrucciones:
        Asignación:
            lado izquierdo:
                Indentificador:
                    nombre: i
            lado derecho:
                Literal Numérico:
                    valor: 27
        Salida con salto:
            expresiones:
                Suma:
                    lado izquierdo:
                        Identificador:
                            nombre: i
                    lado derecho:
                        Literal Numérico:
                            valor: 13
```

Aquí se muestra como sería un error sintáctico, con la instrucción `x = while`, donde el *token* `while` comienza en la columna `4` y se ubica en la linea `n`.

```
linea <n>, columna 4: token inesperado: palabra reservada: 'while'
```

[documento]: <https://github.com/dvdalilue/retina/blob/master/lenguaje/especificacion.md>