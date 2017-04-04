***********************************************************
Interpretador hecho en Ruby para el lenguaje Retina.
+ Hecho por: Adolfo Jeritson. Enero - Marzo 2017
***********************************************************
La especificación del lenguaje se encuentra en retina.md

+ Lexer hecho a la medida para archivos .rtn
+ Parser hecho con la gema Racc para generar gramáticas LALR
+ Análisis de contexto y ejecución para Retina
+ Generación de la imagen en formato .pbm
******************************************************************************************************
# Retina

Lenguaje de programación inspirado en [Logo], junto al concepto *[turtle graphics]*, para la generación de imágenes haciendo uso del formato [pbm]. La extensión de los archivos de Retina son `.rtn`

El objetivo de cada grupo es la implantación de un intérprete, cuyo desarrollo será dividido en 4 fases:

1. Análisis Lexicográfico
2. Análisis Sintáctico
3. Análisis de Contexto
4. Intérprete Final

A continuación se especificaran los elementos del lenguaje, el cuál estará sujeto a leves modificaciones o actualizaciones en el caso de que sea pertinente. 

## Estructura de un programa Retina

A continuación se puede ver como es un programa en Retina que dibuja un cuadrada, donde cada arista mide 50.
```
program
    with
        number x = 4;
    do
        repeat x times
            forward(50); # Traza una línea por 50 puntos
            rotatel(90); # Gira 90 grados contra-reloj
        end;
    end;
end;
```
Salida:
![Imgur](http://i.imgur.com/ncUJ5EB.png)

Un ejemplo adicional:
```
program
    with
    do
        for i from 1 to 100 do
            forward(i * 2); # Traza una línea por 50 puntos
            rotater(90); # Gira 90 grados sentido horario
        end;
    end;
end;
```
Cuya salida es:
![Imgur](http://i.imgur.com/BOoUQ8a.png)

Cabe destacar que el uso del formato [pbm] es más que un requerimiento; es una facilidad.

## Estructura lexicográfica


En Retina, cada lexema esta separado por un espacio en blanco y un espacio en blanco se considera a todo espacio, salto de línea y tabs. Cabe destacar que los espacios en blanco son ignorados.

A partir de un caracter numeral (`#`) hasta el salto de línea, será considerado como un espacio en blanco. A menos que éste se encuentre un literal de cadena de caracteres.

## Literales y tipos de datos


### Boolean
Las expresiones `true` y `false` pertenecen al tipo `boolean`, y son los únicos valores de este tipo.

### Number
Los literales numéricos son construidos por una cadena de al menos un dígito (parte entera). Opcionalmente dicha cadena puede ser seguida por un punto (`.`) y otra cadena de al menos un dígito (parte fraccional). La representación de todo número será en base decimal y será perteneciente al tipo `number`.

### La imagen
En Retina, similar a [Logo], existe una *tortuga* (cursor) al cual se le indica su movimiento en un plano cartesiano. No existe un tipo que represente una imagen, cada programa genera una única imagen.

#### Instrucciones de movimiento
Cada programa en Retina, inicia con el cursor en la posición (0,0) del plano cartesiano, viendo hacia la región positiva del eje de las ordenadas (arriba).

- home(): sitúa el cursor en la posición (0,0).
- openeye(): todo movimiento a partir de esta instrucción será marcado. En un principio, todo programa de Retina irá marcando el movimiento del cursor.
- closeeye(): todo movimiento a partir de esta instrucción no se marcará.
- forward(`number`): avanza el cursor el número *pasos* pasado como parámetro.
- backward(`number`): retrocede el cursor el número *pasos* pasado como parámetro.
- rotatel(`number`): rota el cursor sentido antihorario el número de grados pasado como parámetro.
- rotater(`number`): rota el cursor sentido horario el número de grados pasado como parámetro.
- setposition(`number`,`number`): posiciona el curso en el punto `(x,y)` del plano, donde el primer parámetro corresponde a la componente `x` y segundo parámetro a la componente `y`.
- arc(`number`,`number`): dibuja un arco de `n` grados y radio `r`, quedando el cursor equidistante a todo punto del arco; sin marcar más que el centro y el arco. A continuación, un ejemplo de como se vería un arco de 180 grados y de radio 50; partiendo de la posición inicial.
    - ![Imgur](http://i.imgur.com/zluwdwK.png)

## Identificadores
El identificador de una variable se forma por una cadena de caracteres de longitud arbitraria. Los caracteres permitidos van desde `a` hasta `z`, incluyendo sus respectivas mayúsculas, además de dígitos y el caracter guión bajo (`_`). Los identificadores no pueden comenzar con un dígito, guión bajo o un caracter en mayúscula, cabe acotar que los identificadores son sensibles a minúsculas y mayúsculas.

## Expresiones


Las expresiones están constituidas por variable, valores numéricos, booleanos y operadores. En el caso de una variable, al momento de acceder a su valor, independiente de su tipo, la misma debe haber sido declarada. Partiendo de una expresión `e`, de tipo cualquiera, se puede construir la expresión `(e)` y ambas van a producir el mismo valor, es decir, evaluar `(e)` conlleva a evaluar a `e`.

### Operadores lógicos
A continuación se listan operadores que forman expresiones de tipo `boolean` a partir de operandos de tipo `boolean`. La precedencia de los operadores va desde la más alta a la más baja.

- `not`. Operador prefijo con asociatividad derecha. El valor correspondiente a la expresión formada será el contrario del operando.
- `and`. Operador infijo con asociatividad izquierda. El valor correspondiente a la expresión formada será la conjunción de los valores de cada operando.
- `or`. Operador infijo con asociatividad izquierda. El valor correspondiente a la expresión formada será la disyunción de los valores de cada operando.

#### Operadores de comparación
A continuación se listan operadores que forman expresiones de tipo `boolean` a partir de operandos de tipo `number`. Todos son operadores infijos y la precedencia de los operadores es la misma pero es menor al operador `not`, y mayor al operador `and` y `or`.

- `==`. Si ambos operandos son iguales, el valor de la expresión formada será `true`.
- `/=`. Si ambos operandos son desiguales, el valor de la expresión formada será `true`.
- `>=`. Si el operando izquierdo es mayor o igual al derecho, el valor de la expresión formada será `true`.
- `<=`. Si el operando izquierdo es menor o igual al derecho, el valor de la expresión formada será `true`.
- `>`. Si el operando izquierdo es mayor estricto al derecho, el valor de la expresión formada será `true`.
- `<`. Si el operando izquierdo es menor estricto al derecho, el valor de la expresión formada será `true`.

Para toda expresión formada por cualquiera de estos operadores, ésta será evaluada de izquierda a derecha. Además, los operadores `==` y `/=` también pueden formar expresiones a partir de operandos de tipo `boolean`. 

### Operadores aritméticos
Estos operadores forman expresiones a partir de operandos de tipo `number` y al ser evaluados producen un valor de tipo `number`. Estos operadores tienen mayor precedencia que los operadores de comparación. Se listan desde el operador con mayor precedencia.

- `-`
    - Operador prefijo.
    - Asociativo. Evalúa de derecha a izquierda.
    - Tiene la misma precedencia que el operador `not`.
    - Evaluar la expresión formada por el operador y una expresión numérica `e` corresponderá al aditivo inverso de `e`. 
- `*`,`/`, `%`, `div` y `mod`
    - Operadores binarios.
    - Asociatividad izquierda. Evalúa de izquierda a derecha.
    - `*` corresponde a la producto entre los operandos.
    - `/` y `%` corresponden a la división exacta y resto exacto entre los operandos, respectivamente. En caso de que el operando derecho sea `0`, habrá error.
    - `div` y `mod` corresponden a la división entera y resto entero entre los operandos, respectivamente. En caso de que el operando derecho sea `0`, habrá error.
- `+` y `-`
    - Operadores binarios.
    - Asociatividad izquierda. Evalúa de izquierda a derecha.
    - `+` y `-` corresponden a la suma y resta entre los operandos respectivamente.

## Instrucciones y Control de flujo


Retina hace uso de secuencias de instrucciones para realizar sus operaciones, así como estructuras de control que a su vez pueden contener sencuencias de intrucciones; además es posible que existan bloques anidados.

### Entrada
Teniendo un identificador `i`, asociado a un tipo de dato `t` en Retina, es posible leer una linea desde la entrada estandar del programa usando la instrucción `read i;`. Convirtiendo la linea recibida en un valor del tipo `t` y asociando dicho valor con el identificador `i`. Las conversiones exitosas serán las siguientes.
-  De tipo booleano, si los datos de entrada son exactamente `true` o `false`.
-  De tipo numérico, si los datos de entrada corresponden a un literal numérico de Retina. Ej. `27`, `37.73`

### Salida
La instricción `write x1, x2, ..., xn;`, donde `xi` puede ser una cadena de caracteres encerrada entre comillas dobles o una expresión de cualquier tipo, recorre la secucuencia de elementos de izquierda a derecha e imprimiendo cada elemento en pantalla; esta secuencia no puede ser vacia. Además, existe la instrucción `writeln`, que realiza la imprisión descrita previamente y adicionalmente imprime un salto de linea al final.

La cadena de caracteres, o literal de *string*, es una secuencia de caracteres imprimibles encerrada en comillas dobles (`"`). Además, en dicha secuencia no es posible que exista un salto de linea, comillas dobles o *backslashes* (`\`) a no ser de que estén escapados, es decir, `\n`, `\\` y `\"`.

### Asiganación
Dado un identificador `i` y una expresión `e` de un tipo `t`, se puede formar una instrucción de asignación `i = e;`. El identificador `i` debe haber sido declarado con el mismo tipo `t` de la expresión, en caso contrario debe arrojarse un error.

### Bloque y alcance
Es posible formar una instrucción de bloque `with ds do is end;`, donde `ds` es una secuencia declaraciones, la cual es opcional, y `is` es una secuencia de instrucciones separadas por `;`. Es posible indicar, en una misma linea, varias declaraciones a un mismo tipo; sólo si no se inicializa explicitamente alguna de las variables.

```
with
    number i;
do
    i = 27;
    writeln i + 13;
end;
```

Toda declaración de variable sin inicialización explícita tendrá una inicialización por defecto, si una variable es declarada como `boolean` o `number`, su valor por defecto será `false` o `0` respectivamente. Las inicializaciones explícitas se comportarán similar a una asignación.

La secuencia de declaraciones genera un contexto donde hace disponible cada variable del tipo declarado asociado a un identificador y no estarán disponibles fuera de ese contexto. Dicho contexto es alcanzable para toda instrucción o expresión dentro de la secuencia de instrucciones. En el caso de que haya una instrucción de bloque dentro de la secuencia de instrucciones de otro bloque y exista una declaración con un mismo identificador, la asociación interna va a sustituir a la externa.

```
with
    number i;
do
    i = 27;
    with
        number i = 37;
    do
        write i; # Imprime 37
    end;
    wrtie i; # Imprime 27
end;
```

Es importante resaltar que sería un error tener dos declaraciones para un mismo identificador dentro de un mismo contexto.

### Instrucciones condicionales
Es posible tener una instrucción condicional con una secuencia de instruciones `is` y una expresión `e` de tipo `boolean`. Donde `is` será ejecutada sólo si `e` produce el valor `true`.
```
if e then is end;
```
En un caso completo, teniendo `e`, una expresión de tipo `boolean`, y dos secuencias de instrucciones `is1` y `is2`, puede construirse una instruccion condicional. Dependiendo del valor producido por la expresión `e` se ejecutarán las instrucciones de `is1` o `is2`, si `e` produce `true` o `false` respectivamente.

```
if e then is1 else is2 end;
```

### Iteración

#### Iteración indeterminada
Dada una expresión `e` de tipo `boolean` y una secuencia de instrucciones `is`, se ejecutarás las instrucciones en `is` mientras `e` devuelva el valor `true`.

```
while e do is end;
```

#### Iteración determinada
A partir de un identificador `i`, y dos expresiones `b` y `t` de tipo `number`. Se puede formar una instrucción de iteración determinada `for i from b to t by ii do is end;`. Donde `b <= i <= t` y en el caso de que el intervalo sea vacío, no ocurrirá ninguna iteración. `ii` sería el incremento aplicado a `i` al final de cada iteración.

Es posible formar una instrucción de iteración determinada sin especificar el incremento para cada iteración. En este caso, sólo se incrementará el contador por `1` y se aplicará la función piso sobre cada cota. Puede ver un ejemplo a continuación.

```
program
    with
        number i;
    do
        for j from 1.5 to 4.5 do
            write j, " ";
        end;
    end;
end;
```

El programa imprime `1 2 3 4 ` por la salida estandar.

Es posible traducir una iteración determinada en una iteración indeterminada. Tomando como ejemplo el programa anterior, podría reescribirse de la siguiente manera.

```
program
    with
        number i;
    do
        with
            number j = 1;
        do
            while j <= 4 do
                write j, " ";
                j = j + 1;
            end;
        end;
    end;
end;
```

##### Caso particular `repeat`
Se puede construir una iteración determinada `repeat n times is end;` como un caso particular de `for`, con una expresión `n` de tipo `number` y una secuencia de instrucciones `is`. Dicha instrucción es equivalavente a `for i from 1 to n do end;` pero no existe un contador.

### Funciones
En Retina es posible definir una función con una secuencia de especificaciones de parametro `ps`, un identificador `i` y una secuencia de instrucciones `is`, de la forma `func i(ps) begin is end;`.

```
func circle(number radio)
begin
    arc(360, radio);
end;
```

La secuencia de paramentros puede ser vacía, cada parametro estará separado por una coma `,` y serán de la forma `t p`. Donde `t` es el tipo y `p` es el identificador del parámetro.

Opcionalmente se puede especificar un tipo de valor de retorno usando el lexema `->` y un tipo cualquiera, como se muestra a continuación.

```
func plus(number op1, number op2) -> number
begin
    return op1 + op2;
end;
```

Puntos importantes:

- Es posible tener llamadas anidadas de funciones.
- Se podrá llamar a toda función especificada antes de la llamada.
- Toda función puede tener efecto sobre la imagen generada.
- No es posible que exista co-recursión.

[//]: # (Referencias)

[Logo]: <http://el.media.mit.edu/logo-foundation/what_is_logo/logo_programming.html>
[pbm]: <https://en.wikipedia.org/wiki/Netpbm_format>
[Turtle graphics]: <https://en.wikipedia.org/wiki/Turtle_graphics>
