# Retina

## Etapa 3 - Analizador de Contexto

En este documento se especifican los requerimientos necesarios para la tercera entrega en el desarrollo de su intérprete. Aquí no estarán presente características del lenguaje, sintaxis o ningún tipo de especificación.

La especificación puede verse en este [documento].

## Requerimientos

- El objetivo principal de esta etapa es desarrollar un analizador de contexto para Retina usando el lenguaje que haya elegido, ya sea `Ruby` o `Haskell`, junto a su respectiva herramienta generadora de *parsers*. Independientemente del caso, deberá definir una gramática para Retina, siguiendo el formato de la herramienta.
    - Racc, en el caso de `Ruby`.
    - Happy, en el caso de `Haskell`.
- Un objetivo específico es que usted debe realizar un análisis estático tomando en consideración el sistema de tipos, reglas de contexto y alcance de Retina, verificando si un programa está bien formado.
- Para analizar un programa, se debe recorrer el árbol sintáctico abstracto construido a partir de un programa y crear en cada alcance una tabla de símbolos cuyo trabajo será indicar cuales son los identificadores asociados a cada variable, así como su tipo correspondiente. En el caso de alcances anidados, es necesario que exista una referencia entre las tablas de símbolos, dado que hay la posibilidad de que un identificador sea opacado por otro más interno o se desee acceder a una variable más externa.
- Es de esperar que la tabla de símbolos será una clase en *Ruby* y un tipo de dato en *Haskell*. Por ende, es necesario definir todos las funciones o métodos necesarios para crear, consultar y manipular dicha estructura.
- Su programa debe ejecutarse con el comando `./retina programa.rtn` desde la linea de comandos. Sólo habrá un argumento en la misma, el cual será la ruta de un archivo.
- Se debe abrir dicho archivo e intentar realizar el análisis de contexto partiendo del árbol sintáctico abstracto construido por el analizador sintáctico. En esencia se usará la misma estructura pero se le incorporará una nueva estructura abstracta y un recorrido que realizará ciertas verificaciones.
- En el caso de que existan errores lexicográficos, debe reportarlos todos; al igual que la primera entrega. En caso de que exista un error sintáctico, deberá reportar el primero que encuentre; indicando la posición y *token* donde ocurrió el error.
- Si toda el archivo de entrada es consumido, reconocido y verificado como válido, deben representarse las tablas de símbolos producidas en el analizador de contexto por la salida estándar. El uso de indentación es necesario para identificar la contención de los alcances.

- Deberá verificar ciertos aspectos del programa que el analizador esté procesando, todo programa debe cumplir al menos con lo siguientes. Estos puntos sólo son una referencia, debe tomar en consideración la especificación del lenguaje para realizar un análisis exhaustivo de cada programa, tomando en consideración el sistema de tipos y alcances.
    - Deben coincidir los tipos de la declaración de un identificador y la expresión que se asignará, ya sea en una declaración de variable que se inicialice o una instrucción de asignación.
    - Solo puede existir un identificador asociado a una variable dentro de un mismo alcance.
    - Toda expresión o instrucción puede usar variables solo si su identificador fue declarado.
    - La condición en una instrucción condicional o instrucción de iteración indeterminada debe ser de tipo booleana.
    - Los identificadores de las funciones deben ser únicos entre si.
    - En la especificación de un función, los identificadores de los parámetros deben ser distintos.
    - Las llamadas a funciones deben coincidir en número y tipo de parámetros a su definición.
    - La expresión de cada instrucción de retorno debe coincidir con el tipo del valor de retorno especificado en la función.
    - La instrucción de retorno sólo existe en funciones donde ocurra un valor de retorno.


## Ejemplos

Aquí se muestra lo que sería una porción de un programa y la representación de los alcances.

```
func min(number x, number y) -> number
begin
    with
        boolean b;
    do
        b = x < y;
        if b then
            return x;
        end;
        return y;
    end;
end;

func incremental_forward(number steps)
begin
    for i from 1 to steps do
        forward(i);
    end;
end;

func circle(number radio)
begin
    arc(360, radio);
end;

program
    print "Insert a number : ";
    with
        number n;
    do
        read n; # I suggest that this number be a multiple of 360
        with
            number angle = n;
        do
            while angle <= 360 do
                rotater(n);
                circle(100);
                angle = angle + n;
            end;
        end;
    end;
end;
```


```
Alcance _min:
    Variables:
        x : number
        y : number
    Sub_alcances:
        Alcance 1:
            b : boolean
        Sub_alcances: None

Alcance _incremental_forward:
    Variables:
        steps : number
    Sub_alcances:
        Alcance _for1:
            Variables:
                i : number
            Sub_alcances: None

Alcance _circle:
    Variables:
        radio : number
    Sub_alcances: None

Alcance _program:
    Variables: None
    Sub_alcances:
        Alcance 1:
            Variables:
                n : number
            Sub_alcances:
                Alcance 2:
                    Variables:
                        angle : number
                    Sub_alcances : None

```

Aquí se muestra un programa con error de variable no declarada.

```
program
    writeln n; 
end;
```

```
Error: variable no declarada: 'n'.
```

Aquí se muestra un error de tipos.

```
program
    with
        boolean p;
    do
        p = 27;
    end; 
end;
```

```
Error: '27' es una expresión de tipo 'number' y se esperaba una de tipo 'boolean'.
```

Estos ejemplos son ilustrativos, debe indicar la mayor cantidad de información posible. Así como es la ubicación cercana al error.

[documento]: <https://github.com/dvdalilue/retina/blob/master/lenguaje/especificacion.md>