#!/bin/bash
# coding: utf-8

function help {
	echo "docmypd-tpl.sh - Utiliza DocMyPD con plantillas HTML"
	echo
	echo "docmypd-tpl puede utilizar un conjunto de plantillas para personalizar"
	echo "la salida de docmypd, estas se encuentran en el directorio de"
	echo "instalación (\$PDHELPEXTRACTER_INSTALLPATH) o en una variable de"
	echo "entorno (\$DOCMYPDTPL_TEMPLATESPATH)."
	echo
	echo "Su uso es:"
	echo
	echo "  docmypd-tpl.sh [nombre de la plantilla] [nombre del archivo de configuracion] [archivo/s a documentar]..."
	echo
	echo "La salida estará en la carpeta \`./pdout/\`"
	echo
	echo "El archivo de configuracion es un archivo .docmypd.conf de la forma:"
	echo
	echo "  [field]=\"[value]\"\n..."
	echo
	echo "Vease mas con --help-conf"
	echo
	echo "docmypd-tpl.sh Pertenece a la suite de documentación PDHelpExtracter"
	echo "véa más en https://github.com/alinarezrangel/pdhelpextracter"
	exit
}

function help_conf {
	echo <<HELPOT
Ayuda de la configuracion de DocMyPD-TPL

Los archivos de configuracion terminan en .docmypd.conf y contienen
los datos necesarios como para generar los archivos de salida.

Por ejemplo, el siguiente archivo (solo de ejemplo):

  # bepd.docmypd.conf - Archivo de configuracion para la BEPD
  projectname="Biblioteca Estandar de PseudoD - BEPD"
  navigationmode="inline"
  navigation="<somefile.html|Some File> <someotherfile|Some Other File>"
  authors="Véase <CONTRIBUTORS.txt|CONTRIBUTORS>"
  useupdatedate="yes"
  base="/var/www/html/pseudod/"

Los campos validos son:

* projectname: El nombre del proyecto cuya documentacion se esta generando.
* navigationmode ("inline" o "file"): Si es "inline", el campo navigation
contiene un texto de navegacion (vease mas abajo), de ser "file" el campo
navigation contiene el nombre de un archivo de texto que contiene el texto
de navegacion.
* navigation: Vease el campo navigationmode.
* authors: Una referencia al archivo con los contribuidores, o de ser solo uno
contener su nombre.
* useupdatedate: Si es "yes" se agregara la fecha de generacion a todos los
archivos utilizados, en caso de ser "no" no se agregara la fecha.
* base: Una cadena que sera agregada a todos los URLs que se conviertan.

El texto/archivo navigation y el campo authors estan en el siguiente formato:

  <url o archivo|texto a mostrar> - Enlace
  ... - Texto

Si una linea del archivo de configuracion comienza con "#" sera ignorada.
HELPOT
	echo
	echo "docmypd-tpl.sh Pertenece a la suite de documentación PDHelpExtracter"
	echo "véa más en https://github.com/alinarezrangel/pdhelpextracter"
	exit
}

if [ "$1" = "-h" ]; then
	help
fi
if [ "$1" = "--help" ]; then
	help
fi
if [ "$1" = "--help-conf" ]; then
	help_conf
fi
if [ "$#" -lt "2" ]; then
	help
fi

TPLPATH="$DOCMYPDTPL_TEMPLATESPATH"

if [ "$TPLPATH" = "" ]; then
	TPLPATH="$PDHELPEXTRACTER_INSTALLPATH/docmypd-templates"

	if [ "$TPLPATH" = "/docmypd-templates" ]; then
		TPLPATH="./docmypd-templates"
	fi
fi

tpl="$1"
tppth="$TPLPATH/$tpl"

skipfirst=1

if [ ! -d "./pdout/" ]; then
	mkdir ./pdout/
fi

for i in "$@"; do
	if [ "$skipfirst" = "1" ]; then
		skipfirst=0
		continue
	fi

	fname=`basename $i`
	fn=${fname%.*}

	echo "Documentando el archivo $i ($fname) -> $fn.html"

	cat "$tppth/header.html" | sed "s/\\\$filename\\\$/$fname/" > "./pdout/$fn.html"
	./docmypd.pl "$i" >> "./pdout/$fn.html"
	cat "$tppth/footer.html" | sed "s/\\\$filename\\\$/$fname/"  >> "./pdout/$fn.html"

	echo "Hecho"
done

cp "$tppth/styles/" "./pdout/" -R
