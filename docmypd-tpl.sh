#!/bin/bash
# coding: utf-8

function help() {
	echo "docmypd-tpl.sh - Utiliza DocMyPD con plantillas HTML"
	echo
	echo "docmypd-tpl puede utilizar un conjunto de plantillas para personalizar"
	echo "la salida de docmypd, estas se encuentran en el directorio de"
	echo "instalación (\$PDHELPEXTRACTER_INSTALLPATH) o en una variable de"
	echo "entorno (\$DOCMYPDTPL_TEMPLATESPATH)."
	echo
	echo "Su uso es:"
	echo
	echo "  docmypd-tpl.sh [nombre de la plantilla] [archivo/s a documentar]"
	echo
	echo "La salida estará en la carpeta \`./pdout/\`"
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

	cat "$tppth/header.html" | sed "s/\\\$filename\\\$/$fname/" > "./pdout/$fn.html"
	docmypd.pl "$i" >> "./pdout/$fn.html"
	cat "$tppth/footer.html" >> "./pdout/$fn.html"
done

cp "$tppth/styles/" "./pdout/" -R
