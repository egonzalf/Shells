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
my $INTERVAL= $ENV{COLLECTD_INTERVAL} || 60;
my $SALIR=0;
my $SKIP_DEFAULT = 4;
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
	milog "== $timeward == $deltat == $INTERVAL \n";

	$timeward = ( $timeward - $INTERVAL );

	milog "== $timeward == $deltat == $INTERVAL \n\n";

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
	next if -f "/tmp/.xml-collectd-nvidia-skipquery";


	$epoch = time;

	# Get XML from URL
	if ( shouldQuery() eq "ok" ) {
		$content = `nvidia-smi -q -x` || "<xml></xml>";
	}
	$skipcounter = 0 if ($skipcounter > $interval_skip);
	#$content = `cat /tmp/nvidia.xml`;

	$content =~ s/^\s+|\s+$//g ; # remove white spaces

	# Query time
	$deltat = time - $epoch;

	# trasform into a variable
	my $aux = XMLin($content, KeyAttr => { gpu => 'id' });
	milog Dumper($aux);

	my $gpu_id='0';
	# Parse XML
	if ( $aux->{attached_gpus} > 1 ) {
		foreach my $key ( keys %{$aux->{gpu}} ) {
			milog "$key \n";
			$gpu_id="gpu-".$key;
			my $temperature= substr $aux->{gpu}->{$key}->{'temperature'}->{'gpu_temp'}, 0, -2 ;
			my $memory = $aux->{gpu}->{$key}->{'fb_memory_usage'}; # fb_memory_usage
			my $utilization = $aux->{gpu}->{$key}->{'utilization'}; #
			my $gpuutil = "".(substr($utilization->{'gpu_util'},0,-2) || "0").":".(substr($utilization->{'memory_util'},0,-2) || "0").":".(substr($utilization->{'encoder_util'},0,-2) || "0").":".(substr($utilization->{'decoder_util'},0,-2) || "0");

			milog $memory->{'total'};
			print "PUTVAL \"$HOSTNAME/$gpu_id/temperature\" interval=$INTERVAL N:$temperature\n";
			print "PUTVAL \"$HOSTNAME/$gpu_id/memory-total\" interval=$INTERVAL N:".substr($memory->{'total'},0,-3)."\n";
			print "PUTVAL \"$HOSTNAME/$gpu_id/memory-used\" interval=$INTERVAL N:".substr($memory->{'used'},0,-3)."\n";
			print "PUTVAL \"$HOSTNAME/$gpu_id/memory-free\" interval=$INTERVAL N:".substr($memory->{'free'},0,-3)."\n";
			print "PUTVAL \"$HOSTNAME/$gpu_id/gpu_utilization\" interval=$INTERVAL N:$gpuutil\n";

			if ( $aux->{gpu}->{$key}->{'persistence_mode'} eq "Enabled" ) {
				$interval_skip=0;
			}
			else {
				$interval_skip=$SKIP_DEFAULT;
			}
		}
	}
	else {
		$gpu_id="gpu-".$aux->{gpu}->{'id'};
		my $temperature= substr $aux->{gpu}->{'temperature'}->{'gpu_temp'}, 0, -2 ;
		my $memory = $aux->{gpu}->{'fb_memory_usage'} || $aux->{gpu}->{'memory_usage'}; # fb_memory_usage OR memory_usage
		my $utilization = $aux->{gpu}->{'utilization'}; #
		my $gpuutil = "".(substr($utilization->{'gpu_util'},0,-2) || "0").":".(substr($utilization->{'memory_util'},0,-2) || "0").":".(substr($utilization->{'encoder_util'},0,-2) || "0").":".(substr($utilization->{'decoder_util'},0,-2) || "0");

		milog $memory->{'total'};
		print "PUTVAL \"$HOSTNAME/$gpu_id/temperature\" interval=$INTERVAL N:$temperature\n";
		print "PUTVAL \"$HOSTNAME/$gpu_id/memory-total\" interval=$INTERVAL N:".(substr($memory->{'total'},0,-3) || "0")."\n";
		print "PUTVAL \"$HOSTNAME/$gpu_id/memory-used\" interval=$INTERVAL N:".(substr($memory->{'used'},0,-3) || "0")."\n";
		print "PUTVAL \"$HOSTNAME/$gpu_id/memory-free\" interval=$INTERVAL N:".(substr($memory->{'free'},0,-3) || "0")."\n";
		print "PUTVAL \"$HOSTNAME/$gpu_id/gpu_utilization\" interval=$INTERVAL N:$gpuutil\n";


		if ( $aux->{gpu}->{'persistence_mode'} eq "Enabled" ) {
			$interval_skip=0;
		}
		else {
			$interval_skip=$SKIP_DEFAULT;
		}

	}
	# if parameter "--once", exits
	exit if ( $SALIR );
}


