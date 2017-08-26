# Formato de la documentación #

Todos los programas de la suite PDHelpExtracter asumen que la documentación en
PseudoD posee el siguiente formato:

## Comentarios ##

Solamente el texto dentro de los comentarios de documentación será reconocido
como documentación. Estos comentarios poseen las siguienter restricciones:

* Son su propia sentencia (no se encuentran dentro de ninguna expresión o
construcción del lenguaje).
* Comienzan y terminan con `DOCUMENTA`.
* Las líneas que abren y cierran el comentario deben encontrarse en sus propias
líneas y no contienen texto adicional.

Algunos ejemplos son:

```pseudod
[ Comentarios de documentación válidos: ]

[DOCUMENTA
hola!
DOCUMENTA]

[DOCUMENTA
mundo!
DOCUMENTA]

[ Comentarios de documentación no válidos: ]

[DOCUMENTA hola! DOCUMENTA]

si [DOCUMENTA mundo! DOCUMENTA] son iguales A y B
...
finsi
```

A menos que se especifique lo contrario, cualquier sentencia de código
**declarativa** que le siga al comentario será el código *documentado*, por
ejemplo:

```pseudod
[DOCUMENTA
@brief Documentando la variable A
DOCUMENTA]
adquirir A
```

Las sentencias declarativas son:

* `adquirir`
* `instancia`
* `puntero`
* `funcion`
* `metodo` (cuando está fuera de una declaración de clase)
* `metodo estatico` (cuando está fuera de una declaración de clase)
* `procedimiento`
* `clase`
* `clase abstracta`

## Formato en línea ##

Además de las etiquetas (véase la siguiente sección), pddoc soporta estilos
dentro del texto. Estos están altamente influenciados por Markdown y son
realmente básicos. No existe manera de incluir HTML en la documentación como
garantía de que la documentación siempre será legible en texto plano.

### Negrita, cursiva y ambos ###

```pddoc
*esto está en cursiva*

**esto está en negrita**

***esto está en cursiva y negrita***
```

Como se podrá ver en el ejemplo anterior, para convertir un fragmento de texto
a cursivas basta con rodearlo con un (1) asterisco `*`, similarmente para
negrita se utilizan dos (2) asteriscos `*` y para aplicar ambas tres (3)
asteriscos `*`.

pddoc buscará la sentencia más larga que **no incluya asteriscos literales**,
si desea incluír asteriscos en el texto y que no sean interpretados por
pddoc, es necesario *escaparlos* (véase siguiente subsección).

### Secuencias de escape ###

```pddoc
\*esto no está en cursiva\*

 \* Esto no es parte de una lista

\`esto no es código\`

esto \\ es un *backslash*

esto es \
una única \
línea
```

Las siguientes secuencias de escape son reconocidas y producen los
comportamientos especificados:

* `\\` es reemplazado por `\` e ignorado como token.
* `\*` es reemplazado por `*` e ignorado como token.
* `\`` es reemplazado por ``` e ignorado como token.
* Un `\` que no está seguido por ningún carácter y se encuentra al final de
la línea une la línea actual con la siguiente.

Además, preceder un carácter menor-que `<` o mayor-que `>` con un `\` prevee
que este sea reconocido como inicio o final de un enlace.

### Enlaces ###

```pddoc
<enlace>
<otro\#enlace>
<archivo.pseudo#enlace>
<archivo.pseudo#otro\#enlace>
```

pddoc soporta dos (2) tipos de enlaces: los enlaces *locales* siempre hacen
referencia a algún recurso **documentado** del **archivo** actual. Por el
contrario, los enlaces *globales* pueden hacer referencia a cualquier sección
de cualquier archivo **excepto** el actual.

El enlace más simple es de la forma `<enlace>`, el cual crea un enlace al
símbolo `enlace` del archivo actual: si existe una variable documentada llamada
`enlace` entonces apuntará a ella, si no es una variable sino una función,
apuntará a la función. Por ejemplo:

```pseudod
[DOCUMENTA
@brief Es una variable
DOCUMENTA]
adquirir unaVariable

[DOCUMENTA
@brief Es un puntero
DOCUMENTA]
puntero unPuntero unaVariable

[DOCUMENTA
@brief Es una función
DOCUMENTA]
funcion unaFuncion
	devuelve 5
finfuncion

[DOCUMENTA
@brief Es una clase

Hacemos referencia a <unaVariable>, <unPuntero>, <unaFuncion> e inclusive
esta misma clase: <MiClase>.
DOCUMENTA]
clase MiClase hereda Objeto
finclase
```

En PseudoD el símbolo de la almohadilla o numeral `#` es muy utilizado (como
operador de acceso) y más de una vez será necesario hacer referencia a un
objeto que posee uno de estos en su nombre, sin embargo, pddoc reserva el
numeral dentro de los enlaces para otros propósitos así que es necesario
escaparlo:

```pseudod
[DOCUMENTA
@brief Mi clase.
DOCUMENTA]
clase MiClase hereda Objeto
	metodo algo
finclase

[DOCUMENTA
@brief Mi método.

@argyo

@dev Siempre devuelve `12.5`.
DOCUMENTA]
metodo MiClase#algo con yo
	devolver 12.5
finmetodo

[DOCUMENTA
@brief Mi instancia.

Puedes llamar al método <MiClase\#algo>.
DOCUMENTA]
instancia MiClase MiInstancia
```

De manera similar puedes hacer referencia a nombres más complejos como
`Mi#Nombre#Muy#Largo` utilizando `<Mi\#Nombre\#Muy\#Largo>`.

La última forma de enlace es la más compleja: `<archivo#identificador>`, en
este caso, `archivo` es el nombre de un archivo en relación al
*[baseurl](configuracion.md)* e `identificador` en un nombre válido (tal
como los utilizados anteriormente) con todas las ocurrencias de `#` debidamente
reemplazadas por `\#`. Cabe resaltar que si `archivo` termina con `.pseudo`
(como tiende a ser en bibliotecas escritas en PseudoD) entonces esta extensión
será reemplazada por `.html`.

### Listas ###

```pddoc
* Esto es una lista
 * Esto también

*esto no
```

pddoc posee soporte de listas desordenadas tal como en Markdown, con algunas
diferencias:

* Por ahora las listas no pueden ser anidadas (esto es un bug)
* Las listas pueden poseer un espacio en blanco opcional al inicio, pero
siempre es necesario el espacio en blanco entre el asterisco `*` y el inicio
del texto.
* Por ahora, las listas no pueden ser ordenadas.

## Etiquetas ##

Si una línea comienza con el carácter arroba (`@`) dentro de un comentario de
documentación, se dice que la línea esta *etiquetada*. La etiqueta es la
palabra que le sigue al carácter arroba (`@`) incluyendolo y esta afecta el
significado semántico de la línea.

Note que los requerimientos de las etiquetas hacen imposible su uso dentro de
párrafos de texto (a diferencia de otros generadores de documentación, donde
las etiquetas son utilizadas también para darle estilo al texto).

Las etiquetas válidas y sus usos son:

### `@brief`: Descripción breve ###

```pddoc
@brief ...
```

El resto de la línea representa la descripción breve de la entidad que se esta
documentando. Solamente puede existir una única etiqueta `@brief` por cada
comentario de documentación.

Ejemplo:

```pseudod
[DOCUMENTA
@brief Representa la localización global.
DOCUMENTA]
instancia Localizacion LC_Global
```

### `@file`: Descripción del archivo ###

```pddoc
@file ...
```

El resto de la línea representa el título de la sección de documentación del
archivo actual. Solamente puede existir una única etiqueta `@file`
**por archivo**.

**Nota**: Esta etiqueta está **obsoleta**, su uso no esta recomendado y puede
ser eliminada en futuras versiones de PDHelpExtracter.

**Nota**: Si el comentario posee la etiqueta `@file`, la sentencia que le siga
al comentario no será agregada como código a documentar.

**Nota**: Si el único comentario de documentación del archivo es un comentario
que posee `@file`, ninguna documentación será generada de ese archivo.

Por ejemplo:

```pseudod
[DOCUMENTA
@file Documentación de mi archivo
DOCUMENTA]

...
```

### `@argyo`: Documenta métodos ###

```pddoc
@argyo
```

Si se está documentando un método, esta etiqueta abre la lista de argumentos
(debe ser llamada **justo** antes de cualquier etiqueta `@arg`). Si
no se está documentando un método, esta etiqueta no posee significado.

En la implementación, esta etiqueta simplemente agrega el parametro `yo` a
la lista de argumentos, por ello, nunca debe usarse en métodos estáticos o
no-métodos.

Es posible dejar líneas en blanco entre la etiqueta `@argyo` y la etiqueta
`@arg` adyacente.

Por ejemplo:

```pseudod
[DOCUMENTA
@brief Es una clase.
Más información acerca de la clase aquí.

Aún más información aquí.
DOCUMENTA]
clase MiClase hereda Objeto
	metodo saludarAlMundo
finclase

[DOCUMENTA
@brief Es un método.
Más información acerca de la clase aquí.

Aún más información aquí.

@argyo
@arg otro Otro argumento más.

@dev Siempre devuelve NULO.
DOCUMENTA]
metodo MiClase#saludarAlMundo con yo y otro
	escribir {Hola Mundo!}
	nl

	devolver NULO
finmetodo
```

### `@arg`: Documentación de argumentos ###

```pddoc
@arg <nombre-argumento> ...
```

Documenta el argumento llamado `<nombre-argumento>` de la lista de argumentos
actual. Esta altamente recomendado que el orden de las etiquetas `@arg`
coincida con el orden de los argumentos.

El parametro `<nombre-argumento>` debe ser un identificador válido en PseudoD
y debe corresponder con alguno de los identificadores presentes en la lista
de argumentos de la función, procedimiento o método que se está documentando.
El resto de la línea es la documentación del argumento.

No esta recomendado dejar líneas en blanco entre etiquetas `@arg` adyacentes.

**Nota**: `<nombre-argumento>` no puede ser `yo` debido a que ese nombre esta
reservado por PseudoD para representar a la "instancia actual" en métodos,
sin embargo, el argumento `yo` cuenta como argumento en la lista y por ello
es necesario documentarlo para seguir el orden de la lista en la declaración
como es recomendado anteriormente. Para esto, utilize la etiqueta `@argyo`.

Por ejemplo:

```pseudod
[DOCUMENTA
@brief Es una clase.
Más información acerca de la clase aquí.

Aún más información aquí.
DOCUMENTA]
clase MiClase hereda Objeto
	metodo saludarAlMundo
finclase

[DOCUMENTA
@brief Es un método.
Más información acerca de la clase aquí.

Aún más información aquí.

@argyo
@arg otro Otro argumento más.

@dev Siempre devuelve NULO.
DOCUMENTA]
metodo MiClase#saludarAlMundo con yo y otro
	escribir {Hola Mundo!}
	nl

	devolver NULO
finmetodo
```

### `@dev`: Valor devuelto ###

```pddoc
@dev ...
```

El resto de la línea es la descripción del valor devuelto por la función o
método. Si la función o método no devuelve valor, no especifique etiqueta
`@dev` alguna.

Por ejemplo:

```pseudod
[DOCUMENTA
@brief Devuelve una constante.
Devuelve la constante de la igualdad entre un entero y el número cinco (5).

@arg entero Entero a comparar con cinco (5).

@dev `VERDADERO` si el entero es igual a cinco (5), `FALSO` de lo contrario.
DOCUMENTA]
funcion ObtenerConstante de entero
	devolver si son iguales entero y 5
finfuncion
```

### `@excepciones`: Excepciones lanzadas ###

```pddoc
@excepciones [<exception1> [, <excepcion2>]...]...
```

El resto de la línea representa una o más clases separadas por comas que
representan los errores o excepciones que la función, procedimiento o método
puede lanzar. Es necesario especificar al menos una (1) clase.

**Nota**: Esta etiqueta no posee mucha utilidad actualmente debido a que
PseudoD no soporta excepciones. Sin embargo, se planea agregar soporte para
estas en futuras versiones.

Por ejemplo:

```pseudod
[DOCUMENTA
@brief Falla.
Esta función siempre falla.

@excepciones ErrorDeSemantica

Lanza este error utilizando `necesitas FALSO`.

@errores Recursos.Compartidos, Fatal.NoSeguraParaHilos

Esta función accede a varios recursos compartidos, así que su llamada desde
múltiples hilos al mismo tiempo está indefinido.
DOCUMENTA]
funcion Fallar
	fijar AlgunRecursoCompartido a {Algun Valor}
	necesitas FALSO
finfuncion
```

### `@errores`: Condiciones de carrera o error ###

```pddoc
@errores [<condicion>]...
```

El resto de la línea representa una o más condiciones de carrera o error (en
general, cualquier error que no sea controlado mediante una excepción) de la
función, método o procedimiento.

Únicamente debería utilizarse esta etiqueta para reportar errores que no pueden
ser controlados una vez que suceden, tal como una *condición de carrera* o un
error mayor del sistema.

Las condiciones válidas son:

* `Nada` o `Ninguno`: No posee condiciones de carrera o error.
* `Recursos.Compartidos`: Uno o más recursos compartidos entre llamadas a la
misma función o compartidos entre diferentes funciones son accedidos.
* `Recursos.Bloqueo`: Puede ocasionar un *deadlock*.
* `Retorno.Compartido`: El valor de retorno es compartido entre llamadas de la
misma función o entre diferentes funciones.
* `Fatal.NoAtributo`: Puede fallar si no existe un determinado atributo en un
determinado objeto.
* `Fatal.Atributo`: Puede fallar si existe un determinado atributo en un
determinado objeto.
* `Fatal.NoTipo`: Puede fallar si una variable determinada no nombra un tipo
válido.
* `Fatal.NoSeguraParaHilos`: Puede fallar si se llama al mismo tiempo desde dos
puntos de entrada distintos (hilos distintos).
* `Estado.Compartido`: El estado de esta función esta compartido entre llamadas
o con otras funciones, esto implica que la función no es necesariamente
determinista en base a los argumentos dados.
* `Entrada.SinVerificar`: Ni los argumentos ni el estado de la función son
verificados antes de su ejecución por lo cual verse afectado por fallas en
el formato de estos.

Por ejemplo:

```pseudod
[DOCUMENTA
@brief Falla.
Esta función siempre falla.

@excepciones ErrorDeSemantica

Lanza este error utilizando `necesitas FALSO`.

@errores Recursos.Compartidos, Fatal.NoSeguraParaHilos

Esta función accede a varios recursos compartidos, así que su llamada desde
múltiples hilos al mismo tiempo está indefinido.
DOCUMENTA]
funcion Fallar
	fijar AlgunRecursoCompartido a {Algun Valor}
	necesitas FALSO
finfuncion
```

### `@obsoleta`, `@obsoleto`: Obsoleto ###

```pddoc
@obsoleto

@obsoleta
```

Esta etiqueta indica que la función, método, método estático, procedimiento,
clase, variable o puntero se encuentra obsoleto. Opcionalmente, se puede
especificar el motivo o la nueva interfáz recomendada

**Nota**: Las etiquetas `@obsoleto` y `@obsoleta` son sinónimos y pueden
intercambiarse libremente.

Por ejemplo:

```pseudod
[DOCUMENTA
@brief Representa un número.
Es global y posee el valor uno (1) de manera predeterminada.
DOCUMENTA]
adquirir numero
fijar numero a 1

[DOCUMENTA
@brief Representa un número.
Devuelve el número uno (1) de manera predeterminada.

@obsoleto
Use <numero> en cambio.
DOCUMENTA]
funcion NumeroFCN
	devolver 1
finfuncion
```
