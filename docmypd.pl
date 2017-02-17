#!/usr/bin/perl -w

if($#ARGV < 0) {
	print "docmypd - Exporta la ayuda de un archivo en PseudoD a HTML\n";
	print "Uso:\n";
	print "\n";
	print "  docmypd.pl [archivo.pseudo] > [archivo.html]\n";
	print "\n";
	print "La salida es un HTML plano, sin <body> o <head> y listo para ser editado.\n";
	exit(1);
}

sub htmlify {
	$pddoc = $_[0];
	$res = "";
	$inargs = 0;
	$matched = 0;
	$intext = 0;
	$codeblock = 0;
	$openlist = 0;

	foreach $_(split(/\n/, $pddoc)) {
		$matched = 0;

		s!\<([^\>]+)\>!<a class="docmypd-link" href="#$1">$1</a>!g;
		s!\*\*\*([^\*]+)\*\*\*!<b class="docmypd-bold"><i class="docmypd-italic">$1</i></b>!g;
		s!\*\*([^\*]+)\*\*!<b class="docmypd-bold">$1</b>!g;
		s!\*[^ \r\n\t]([^\*]+)\*!<i class="docmypd-italic">$1</i>!g;
		s!\`([^\`]+)\`!<code class="docmypd-code">$1</code>!g;

		if(/^[ \r\n\t]*\*[ \r\n\t]+(.*)$/) {
			if($openlist == 0) {
				$res = "$res\n<ul class=\"docmypd-userlist\">";
			}
			$res = "$res\n<li>$1</li>";
			$openlist = 1;
			next();
		} elsif($openlist == 1) {
			$res = "$res\n</ul>";
			$openlist = 0;
		}

		if(/^[ \r\n\t]*\`\`\`.*$/) {
			if($codeblock == 0) {
				$codeblock = 1;
				$res = "$res\n<code class=\"docmypd-codeblock\"><pre>";
			} else {
				$codeblock = 0;
				$res = "$res\n</pre></code>";
			}
			next();
		}

		if($codeblock == 1) {
			$res = "$res\n$_";
			next();
		}

		if(/^[ \t\r\n]*\@(brief|file)[ \r\t\n]+(.+)$/) {
			$res = "$res\n<p class=\"docmypd-$1\">$2</p>";
			$matched = 1;
		}
		if(/^[ \t\r\n]*\@arg[ \r\t\n]+([^ \r\t\n]+)[ \r\n\t]+(.+)$/) {
			if($inargs == 0) {
				$res = "$res\n<h3 class=\"docmypd-arguments-title\">Argumentos</h3>\n<ul class=\"docmypd-arguments\">";
			}
			$res = "$res\n<li class=\"docmypd-argument-def\"><var class=\"docmypd-argument-name\">$1</var>: <span class=\"docmypd-argument-desc\">$2</span></li>";
			$inargs = 1;
			$matched = 1;
		} else {
			if($inargs == 1) {
				$res = "$res\n</ul>";
			}
			$inargs = 0;
		}
		if(/^[ \t\r\n]*\@argyo[ \r\t\n]*$/) {
			if($inargs == 0) {
				$res = "$res\n<h3 class=\"docmypd-arguments-title\">Argumentos</h3>\n<ul class=\"docmypd-arguments\">";
			}
			$res = "$res\n<li class=\"docmypd-argument-def\"><var class=\"docmypd-argument-name\">yo</var></li>";
			$inargs = 1;
			$matched = 1;
		}
		if(/^[ \t\n\r]*\@dev[ \r\n\t]*(.+)$/) {
			$res = "$res\n<h3 class=\"docmypd-returns-title\">Devuelve</h3>\n<p class=\"docmypd-returns\">$1</p>";
			$matched = 1;
		}
		if(/^[ \t\n\r]*\@throws[ \r\n\t]*(.+)$/) {
			$res = "$res\n<h3 class=\"docmypd-throws-title\">Excepciones</h3>\n<p class=\"docmypd-throws\">$1</p>";
			$matched = 1;
		}
		if(/^[ \t\n\r]*\@races[ \r\n\t]*(.+)$/) {
			$res = "$res\n<h3 class=\"docmypd-races-title\">Errores</h3>\n<p class=\"docmypd-races\">$1</p>";
			$matched = 1;
		}
		if(/^[ \r\t\n]*\@abstract[ \r\n\t]*$/) {
			$res = "$res\n<span class=\"docmypd-tag-abstract\">Abstracta</span>";
			$matched = 1;
		}
		if(/^[ \r\t\n]*\@obsolete[ \r\n\t]*$/) {
			$res = "$res\n<span class=\"docmypd-tag-abstract\">Abstracta</span>";
			$matched = 1;
		}
		if($matched == 0)
		{
			if($intext == 0)
			{
				$res = "$res\n<p class=\"docmypd-paragraph\">";
			}
			$intext = 1;
			$res = "$res\n$_";
			$matched = 1;
		} else {
			if($intext == 1) {
				$res = "$res\n</p>";
				$intext = 0;
			}
		}
	}

	if($openlist == 1) {
		$res = "$res\n</ul>";
		$openlist = 0;
	}
	if($intext == 1) {
		$res = "$res\n</p>";
		$intext = 0;
	}

	return $res;
}

sub codeify {
	$pdcode = $_[0];

	$pdcode =~ s!(^|[ \r\t\n]+)[ \r\n\t]*(abstracta|adquirir|clase( abstracta)?|estructura|adquirir|puntero|instancia|funcion|de|con|y|e|hereda(r)?|implementa|extiende)[ \r\n\t]+!<b class="docmypd-keyword">$&</b>!g;
	$pdcode =~ s!(\[[^\]]+\])!<i class="docmypd-identifier">$&</i>!gmi;

	return "<code class=\"docmypd-source\"><pre>$pdcode</pre></code>";
}

sub searchObjectInFile {
	$fname = $_[0];

	open(FILE, $fname) or die("Unable to open $fname");

	$printall = 0;
	$text = "";
	$result = "";
	$filedoc = 0;
	$filestr = "";

	while(<FILE>) {
		$printall = 1 if($printall == 2);
		$printall = 3 if(/^[ \t\r\n]*(clase|estructura|funcion|adquirir|puntero|instancia)/ && $printall == 4);

		$printall = 2 if(/^[ \t\r\n]*\[DOCUMENTA[ \t\r\n]*$/);
		$printall = 4 if(/^[ \t\r\n]*DOCUMENTA\][ \t\r\n]*$/);

		$printall = 3 if(/^[ \t\r\n]*DOCUMENTA\][ \t\r\n]*$/ && $filedoc == 1);

		if(/^( \t\r\n)*\@file/) {
			$filedoc = 1;
			$filestr = $_;
		}
		if($printall == 1) {
			$text = "$text  $_";
		}
		if($printall == 3) {
			$text = htmlify($text);
			$text = "<hr /><div class=\"docmypd-section\">$text";
			if($filedoc == 1) {
				$result = "$result\n\n$text</div>";
			} else {
				$_ = codeify($_);
				$result = "$result\n\n$text\n$_</div>";
			}
			$text = "";
			$printall = 0;
			$filedoc = 0;
		}
	}

	close FILE;

	return $result;
}

$rs = searchObjectInFile($ARGV[0]);

print $rs;
