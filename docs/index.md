# Suite de documentación de PseudoD #

Bienvenido a la suite de documentación de PseudoD PDHelpExtracter, que provee
un conjunto de programas diseñados específicamente para extraer y convertir la
documentación en comentarios de programas, archivos o bibliotecas en PseudoD.

Esta suite provee hasta ahora cuatro (4) programas:

* `pddoc` (Antes `docmypd.pl`): Obtiene la documentación de un archivo y genera
un equivalente en HTML.
* `pddoc-tpl` (Antes `docmypd-tpl.sh`): Utiliza un archivo de configuración
para generar documentación de manera más cómoda en proyectos con muchos
archivos.
* `pdayuda` (Antes `pdhelpextracter-autosearch.sh`): Busca documentación en las
bibliotecas de PseudoD actualmente instaladas.
* `pdayuda-archivo` (Antes `pdhelpextracter.pl`): Busca la documentación en un
archivo especificado y la imprime.

A lo largo de esta documentación llamaremos a cada programa por su nuevo nombre
(es decir, pddoc y no docmypd) y a la suite con todos los programas la
llamaremos PDHelpExtracter.

## Formato de la documentación ##

Véase la [referencia de formato](formato.md).

## Utilizando la salida generada ##

Véase la [referencia de configuración](configuracion.md).

## PDDoc - Convierte la documentación de un archivo a HTML ##

La herramienta pddoc convierte la documentación de un archivo en PseudoD a
un archivo HTML, el archivo no es un HTML válido pero igual puede ser
visualizado utilizando la mayoría de los navegadores web.

Para convertir la salida de pddoc en un HTML válido es necesario:

* Reemplazar cada aparición de `&baseurl;` por tu propio BaseURL (véase
la [documentación del BaseURL](configuración.md)).
* Agregar al inicio y al final del archivo un *boilerplate* válido como el que
se muestra más adelante.

El archivo generado se ve como:

```html
<!-- Esto es solo un ejemplo: -->
...
<section>
  <h2>@Contenedor#borrar</h2>
  ...
  <p>Método borrar de un contenedor</p>
  ...
  <code>metodo @Contenedor#borrar con yo</code>
</section>
<hr />
...
```

Es necesario agregar al inicio un código como este:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Tu título</title>
    <!-- Cualquier otro contenido que desees en la etiqueta head -->
  </head>
  <body>
    <!-- Cualquier otro contenido que no dependa de la documentación, como
         barras de navegación o enlaces -->
```

Y al final uno como este:

```html
    <!-- Cualquier otro contenido que no dependa de la documentación, como
         barras de navegación o enlaces -->
  </body>
</html>
```

## PDAyuda - Busca ayuda en los archivos del sistema ##

La herramienta pdayuda busca un término dentro de la documentación del sistema,
solamente pasa un argumento que representa el término a buscar y
automaticamente pdayuda mostrará todo lo que coincida.

Por ejemplo:

```sh
# Muestra la ayuda acerca de todo lo referente a la clase Arreglo
pdayuda 'clase Arreglo'
# Muestra la ayuda de **todo** lo que tenga "Objeto" en su declaración
pdayuda 'Objeto'
```
