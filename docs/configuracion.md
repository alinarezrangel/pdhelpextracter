# Configuración de pddoc #

La salida de pddoc es en su grán mayoría HTML válido, sin embargo, este posee
algunas características que hacen imposible su uso sin edición en la web.

## Enlaces ##

### Base URL ###

Todos los enlaces excepto los locales (enlaces dentro del mismo archivo) están
precedidos por la secuencia especial `&baseurl;` la cual debe ser reemplazada
al *webroot*, directorio que se utilizará como raíz para todos los enlaces
generados.

pddoc hace énfasis en que la documentación sea legible desde el código fuente,
en general, cuando documentes tu código siempre asume que el BaseURL es el
directorio base de tu proyecto.

Por ejemplo: este es un fragmento de salida generada por pddoc:

```html
<a href="&baseurl;hola.html">hola.html</a>
```

Es importante que cuando se reemplazen las apariciones de `&baseurl;` por el
BaseURL, este termine con un separador de directorio `/` o de lo contrario
el URL resultante podría quedar inválido.

#### Reemplazando el BaseURL de manera automatizada ####

##### En GNU/Linux #####

Puedes utilizar el comando `sed`:

```sh
BASEURL="/documentos/" # Tu BaseURL

pddoc archivo-a-documentar.pseudo | sed "s/&baseurl;/$BASEURL/" > salida.html

# Si tu servidor esta en http://example.com entonces los enlaces apuntarán a
# http://example.com/documentos/
```

##### En macOS #####

El proceso en macOS es el mismo que en GNU/Linux (utilizando los programas
`sed` y `pddoc`):

```sh
BASEURL="/documentos/" # Tu BaseURL

pddoc archivo-a-documentar.pseudo | sed "s/&baseurl;/$BASEURL/" > salida.html

# Si tu servidor esta en http://example.com entonces los enlaces apuntarán a
# http://example.com/documentos/
```

##### En Windows #####

Es necesario PowerShell para realizar esta tarea:

```powershell
cat archivo-a-documentar.pseudo | % { $_ -replace "&baseurl;", "Tu BaseURL"} > salida.html
```
