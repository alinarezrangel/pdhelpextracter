#!/bin/bash

if [ "$#" != "1" ]; then
	echo "pdhelpextracter-autosearch - Extrae ayuda de PseudoD"
	echo
	echo "Busca en $PSEUDODPATH o en /opt/pseudod/bepd/."
	echo
	echo "Uso:"
	echo "  pdhelpextracter-autosearch.sh [objeto a buscar]"
	echo
	echo "Es recomendable utilizar algun paginador en la salida"
	exit 1
fi

PSEUDODPATH=$PSEUDODPATH

if [ "$PSEUDODPATH" = "" ]; then
	PSEUDODPATH="/opt/pseudod/bepd/"
fi

find /opt/pseudod/bepd/ -depth -iname "*.pseudo" -exec pdhelpextracter.pl "{}" "$1" ";"

