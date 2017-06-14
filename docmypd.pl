#!/usr/bin/perl -w

if($#ARGV < 0) {
	print "docmypd - Exporta la ayuda de un archivo en PseudoD a HTML\n";
	print "Uso:\n";
	print "\n";
	print "  docmypd.pl [archivo.pseudo] > [archivo.html]\n";
	print "\n";
	print "La salida es un HTML plano, sin <body> o <head> y listo para ser editado.\n";
	print "docmypd.pl Pertenece a la suite de documentación PDHelpExtracter\n";
	print "véa más en https://github.com/alinarezrangel/pdhelpextracter\n";
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
	$contline = "";
	$cnt = 0;
	$lslineblk = 0;

	foreach $_(split(/\n/, $pddoc)) {
		$matched = 0;

		s!\&!&amp;!g;
		s!\<!&lt;!g;
		s!\>!&gt;!g;

		if(/^[ \r\n\t]*\`\`\`(.*)$/) {
			if($codeblock == 0) {
				$codeblock = 1;
				$res = "$res\n<code class=\"docmypd-codeblock\" data-language=\"$1\"><pre>";
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

		s!\*\*\*([^\*]+)\*\*\*!<b class="docmypd-bold"><i class="docmypd-italic">$1</i></b>!g;
		s!\*\*([^\*]+)\*\*!<b class="docmypd-bold">$1</b>!g;
		s!\*([^ \r\n\t][^\*]+)\*!<i class="docmypd-italic">$1</i>!g;

		s!\`([^\`]+)\`!<code class="docmypd-code">$1</code>!g;

		s!\&lt\;(.+)\&gt\;!<a class="docmypd-link" href="#$1">$1</a>!g;

		if(/[ \r\n\t]+\\[ \t\n\r]*$/g)
		{
			s/[ \r\t\n]+\\[ \t\n\r]*$/ /g;
			$contline = "$contline$_";
			$cnt = 1;
			next();
		}
		elsif($cnt == 1)
		{
			$_ = "$contline$_";
			$contline = "";
			$cnt = 0;
		}

		if(/^[ \r\n\t]*\*[ \r\n\t]+(.*)$/) {
			if($openlist == 0) {
				$res = "$res\n<ul class=\"docmypd-userlist\">";
			}
			$res = "$res\n</li><li>$1";
			$openlist = 1;
			next();
		} elsif($openlist == 1 && /^[ \r\n\t]*$/) {
			$res = "$res\n</li></ul>";
			$openlist = 0;
		}

		if(/^[ \t\r\n]*\@(brief|file)[ \r\t\n]+(.+)$/) {
			if($1 eq "file") {
				$res = "$res\n<h1 class=\"docmypd-title-file\" id=\"$2\">$2</h1>";
			} else {
				$res = "$res\n<p class=\"docmypd-brief\">$2</p>";
			}
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
			$res = "$res\n<span class=\"docmypd-tag-obsolete\">Obsoleta</span>";
			$matched = 1;
		}
		if($matched == 0)
		{
			if($intext == 0)
			{
				$res = "$res\n<p class=\"docmypd-paragraph\">";
				$lslineblk = 0;
			}
			$intext = 1;
			$res = "$res\n$_";
			$matched = 1;

			if(/^[ \t\r\n]*$/g) {
				$res = "$res\n</p><p class=\"docmypd-paragraph\">";
			}
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
			if($filedoc == 1) {
				$text = "<hr /><div class=\"docmypd-section\">$text";
				$result = "$result\n\n$text</div>";
			} else {
				/^[ \t\r\n]*([a-z]+)[ \t\r\n]+([^ \t\r\n]+)(.|[ \t\r\n])+$/;
				$n = $2;
				$_ = codeify($_);
				$text = "<hr /><div class=\"docmypd-section\"><h2 class=\"docmypd-title-code\" id=\"$n\">$n</h2>\n$text";
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
