# Retina

## Etapa 4 - Intérprete

En este documento se especifican los requerimientos necesarios para la cuarta entrega en el desarrollo de su intérprete. Aquí no estarán presente características del lenguaje, sintaxis o ningún tipo de especificación.

La especificación puede verse en este [documento].

## Requerimientos

- El objetivo principal de esta etapa es finalizar el intérprete para Retina usando el lenguaje que haya elegido, ya sea `Ruby` o `Haskell`, junto a su respectiva herramienta generadora de *parsers*. Definiendo las funciones o métodos para que el intérprete pueda ejecutar los programas. Independientemente del caso, ya debe haber definido una gramática que reconozca al lenguaje, siguiendo el formato de la herramienta.
    - Racc, en el caso de `Ruby`.
    - Happy, en el caso de `Haskell`.
- Un objetivo específico es, dado un programa que ya fue verificado, recorrer nuevamente el árbol y realizar la acción correspondiente a cada objeto del lenguaje en el orden correcto.
- Cuando se ejecuta el intérprete, se debe abrir el archivo que se indica en el primer y único argumento en la línea de comandos, luego de realizar el análisis lexicográfico, sintáctico y de contexto, resulta en un árbol sintáctico abstracto que representa un programa verificado que finalmente se ejecutará. En esencia se usará la misma estructura de árbol pero se le incorporará un nuevo comportamiento para cada componente del lenguaje, es de esperar que el recorrido será similar al que se hizo para la tercera entrega.
- Si existen errores lexicográficos, deberá reportar todos los que encuentre. Si existen errores sintácticos, deberá reportar el primero que encuentre. Si existen errores de contexto, deberá reportar el primero que encuentre. Si existe un error al momento de la ejecución, deberá abortar de inmediato y reportar el error encontrado.
- Para esta entrega no habrá ninguna salida esperada por la salida estandar, a menos que sea un mensaje de error durante el análisis estático previo a la ejecución o alguna impresión que sea producida por las instrucciones de impresión durante la ejecución.
- El programa debe producir una imagen al final de todo programa, aun cuando no se haya realizado ningún movimiento, en ese caso se produciría una imagen "vacía", es decir, el centro sería el único que está encendido. El archivo `pbm` representa una matriz de píxeles donde se indican cuales están encendidos y cuales no, ese archivo debe tener el mismo nombre del programa que lo produjo. Cada paso que se indica en una función de movimiento es un píxel.
- La imagen tendrá un tamaño por defecto de 1001x1001 pero si la tortuga supera la frontera en algún momento, sólo se perderá todo trazo que la misma haga fuera del plano.


[documento]: <https://github.com/dvdalilue/retina/blob/master/lenguaje/especificacion.md>