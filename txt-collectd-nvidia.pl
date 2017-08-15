#!/usr/bin/perl

# COLLECTD_INTERVAL=5 ./xml-collectd-nvidia.pl

#use strict;
use warnings;

use LWP::Simple;
use XML::Simple;
use Data::Dumper;
use Switch;

$| = 1;

my $HOSTNAME= $ENV{COLLECTD_HOSTNAME} || "localhost";
my $INTERVAL= $ENV{COLLECTD_INTERVAL} || 10;
my $SALIR=0;
my $SKIP_DEFAULT = 0;
my $DEBUGLOG=0;

# Read parameters
@lista = @ARGV;
PARAMETROS: while ( defined ($par = shift @lista) ) {
	switch ($par) {
		#case "--host" { @HOSTS = split(/,/,shift @lista) }
		#case "--queue" { @QUEUES = split(/,/,shift @lista) }
		case "--once" { $SALIR = 1; $INTERVAL = 1; }
		case "--debug" { $DEBUGLOG = 1; }
	}
}

sub milog {
	print @_ if ( $DEBUGLOG );
}



milog "-- $HOSTNAME -- $INTERVAL \n";

my $content = '<xml></xml>';
my $skipcounter=0;
my $interval_skip=$SKIP_DEFAULT;

my $epoch=0;
my $deltat=0;
my $timeward=0;


# Function to decide if query or not.
sub shouldQuery {
	# only checks if skip counter is 1, this is a more trivial method.
	if ( (++$skipcounter) != 1 ) { return "no"; }

	# now a more dynamic method based on query duration
	$timeward = $INTERVAL + ( $deltat / 0.4 ) if ( $deltat >= ($INTERVAL * 0.4) );
	milog "[shouldQuery]== $timeward == $deltat == $INTERVAL \n";

	$timeward = ( $timeward - $INTERVAL );

	milog "[shouldQuery]== $timeward == $deltat == $INTERVAL \n\n";

	if ( $timeward < 0 ) {
		$timeward=0;
		return "ok";
	}
	return "no";
}

while (sleep $INTERVAL > 0) {

	# Sometimes there are reasons to avoid invoking nvidia-smi
	# for exmaple, performance profiling
	# and no measurements are sent to collectd
	next if -f "/tmp/.txt-collectd-nvidia-skipquery";


	$epoch = time;

	my $outfile="/tmp/.txt-nvidia.out";

	# Obtiene el XML desde la URL
	if ( shouldQuery() eq "ok" ) {
		$content = `nvidia-smi -q -d MEMORY,TEMPERATURE > $outfile` || "";
	}
	$skipcounter = 0 if ($skipcounter > $interval_skip);
	$content = `cat $outfile`;

	#$content =~ s/^\s+|\s+$//g ; # elimina espacios

	# Query time
	$deltat = time - $epoch;


	open my $fh, $outfile or die "Could not open $outfile: $!";


	my $output="";
	my $gpu_id="";
	while( my $line = <$fh> ) {
		#milog $line;
		chomp $line;
		switch ($line) {
			case /^GPU/ {
				my($aux) = $line =~ / (.*:..:.*)/;
				$gpu_id="gpu-$aux";
				milog ":: $gpu_id \n";
			}
			case /^    (FB )?Memory/ {
				my($memory_total) = <$fh> =~ /(\d+)/;
				$output.="PUTVAL \"$HOSTNAME/$gpu_id/memory-total\" interval=$INTERVAL N:$memory_total\n";
				my($memory_used) = <$fh> =~ /(\d+)/;
				$output.="PUTVAL \"$HOSTNAME/$gpu_id/memory-used\" interval=$INTERVAL N:$memory_used\n";
				my($memory_free) = <$fh> =~ /(\d+)/;
				$output.="PUTVAL \"$HOSTNAME/$gpu_id/memory-free\" interval=$INTERVAL N:$memory_free\n";
				milog "$memory_total - $memory_used - $memory_free\n";
			}
			case /^    Temperature/ {
				my($temperature) = <$fh> =~ /(\d+)/;
				milog "temp: $temperature\n";
				$output.="PUTVAL \"$HOSTNAME/$gpu_id/temperature\" interval=$INTERVAL N:$temperature\n";
			}
			else { next; }
		}
	}
	print "$output";

	# sale si se paso el parametro "--once"
	exit if ( $SALIR );
}
