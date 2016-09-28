#!/usr/bin/perl -w
use Switch;

## Variables
$DIFFPAR="";
$FILE="";
$SHOWHEAD="false";

sub usage {
    $aux = "Usage: $0 <file> [--no-blankspaces] [--since <rev>]\n";
	$aux .="\t[--no-blankspaces] : ommits blank spaces differences\n";
	$aux .="\t[--since <rev>] : starts from revision <rev> onwards to HEAD\n";
	return $aux;
}


## leer parametros
PARAMETROS: while ( defined ($par = shift @ARGV) ) {
	switch ($par) {
		case "--help" { print usage; exit; }
		case "--no-blankspaces" { $DIFFPAR="-x -b" }
		case "--print-head" { $SHOWHEAD="true" }
		case "--file" { $FILE = shift @ARGV }
		case "--since" { $STARTREV = shift @ARGV } 
		else { $FILE = $par if ( "" eq $FILE ) ; }
	}

}

if ( "" eq $FILE ) {
    die usage ;
}
elsif ( ! -f $FILE ) {
    die "$FILE is not a regular file\n";
}
elsif ( defined $STARTREV && ! ( $STARTREV=~/^\d+$/ ) ) {
	die "$STARTREV is not a valid number\n";
}


open(REVISIONES, "svn log -q $FILE|"); #determina las revisiones del archivo
while ( $line=<REVISIONES>) {
    if ($line =~ /^r(\d+)\s/) { #extrae el numero de revision
	push @revisiones, $1; 
	@revisiones = sort {$a <=> $b} @revisiones;
    }
}
close REVISIONES;

if (defined $STARTREV) {
	# no muestra el 'cat' inicial
	$revisioninicial = $STARTREV;
}
else {
	$revisioninicial = shift @revisiones;
	$out =`svn log -r$revisioninicial $FILE\@HEAD`;
	$out.=`svn cat -r$revisioninicial $FILE\@HEAD`."\n";
}

REVISION: foreach $rev (@revisiones) {
	next REVISION if ( $rev < $revisioninicial );
    $out.="# "x36;$out.="\n"; #separador
    $out.=`svn log -r$rev $FILE\@HEAD`; #detalles del commit
    $out.=`svn diff $DIFFPAR -c$rev $FILE\@HEAD`."\n"; #los cambios en esta revision
}
if ( $SHOWHEAD eq "true" ) {
	$out.="# "x36;$out.="\n"; #separador
	$out.="==== ARCHIVO COMPLETO ACTUAL REV:$revisiones[-1] ====\n";
	$out.=`svn cat -rHEAD $FILE\@HEAD`;
}	
print $out;

