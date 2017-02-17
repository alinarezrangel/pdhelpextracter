#!/usr/bin/perl -w

if($#ARGV < 1) {
	print "pdhelpextracter - Extrae ayuda de un archivo en PseudoD\n";
	print "Uso:\n";
	print "\n";
	print "  pdhelpextracter.pl [archivo.pseudo] [objeto a buscar]\n";
	print "\n";
	print "Es recomendable utilizar algun paginador en la salida.\n";
	exit(1);
}

sub searchObjectInFile {
	$fname = $_[0];
	$tosearch = $_[1];

	open(FILE, $fname) or die("Unable to open $fname");

	$printall = 0;
	$text = "";
	$result = "";
	$filedoc = 0;
	$filestr = "";

	while(<FILE>) {
		$printall = 1 if($printall == 2);
		$printall = 3 if(/^( \t\r\n)*(clase|estructura|funcion|adquirir|puntero|instancia)/ && $printall == 4);

		$printall = 2 if(/^( \t\r\n)*\[DOCUMENTA( \t\r\n)*$/);
		$printall = 4 if(/^( \t\r\n)*DOCUMENTA\]( \t\r\n)*$/);

		$printall = 3 if(/^( \t\r\n)*DOCUMENTA\]( \t\r\n)*$/ && $filedoc == 1);

		if(/^( \t\r\n)*\@file/) {
			$filedoc = 1;
			$filestr = $_;
		}
		if($printall == 1) {
			$text = "$text  $_";
		}
		if($printall == 3) {
			if($filedoc == 1) {
				if(index($filestr, $tosearch) != -1) {
					$result = "$result\n\n$text";
				}
			} else {
				if(index($_, $tosearch) != -1) {
					$result = "$result\n\n$text\n$_";
				}
			}
			$text = "";
			$printall = 0;
			$filedoc = 0;
		}
	}

	close FILE;

	return $result;
}

$rs = searchObjectInFile($ARGV[0], $ARGV[1]);

print "At $ARGV[0]\n" if($rs ne "");
print $rs;
