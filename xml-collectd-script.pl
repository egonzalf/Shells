#!/usr/bin/perl


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

my @HOSTS;
my @QUEUES;

@lista = @ARGV;
PARAMETROS: while ( defined ($par = shift @lista) ) {
        switch ($par) {
                case "--host" { @HOSTS = split(/,/,shift @lista) }
                case "--queue" { @QUEUES = split(/,/,shift @lista) }
                case "--once" { $SALIR = 1; $INTERVAL = 1; }
        }
}

sub checkHost {
        local $thehost;
        foreach $h (@_) {
                $out=`nmap $h -p 8161 2>&1`;
                if ($out =~ /8161.*open/) {
                        $thehost=$h;
                        last;
                }
                $thehost=undef;
        }
        return $thehost;
}

my $iter = 0;

#print "-- $HOSTNAME -- $INTERVAL \n";

while (sleep $INTERVAL > 0) {
        $iter++;
        if ( $iter%50 eq 1 ) {
                $thehost=checkHost( @HOSTS ) || $HOSTS[0] ;
                $url = 'http://admin:admin@'.$thehost.':8161/admin/xml/queues.jsp';
                $iter=0;
        }


        # Obtiene el XML desde la URL
        my $content = get($url) || "<xml></xml>";
    
        $content =~ s/^\s+|\s+$//g ; # elimina espacios

        # transforma a variable
        my $ref = XMLin($content);

        # recorre el XML
        foreach my $key ( keys %{$ref->{'queue'}} ) {
                #print "$key \n";
                foreach my $asd ( keys %{$ref->{'queue'}->{$key}}) {
                        #print "\t\t$asd\n";
                        if ( $asd eq "stats" ) { 
                                # nodo <stats>
                                $pending = $ref->{'queue'}->{$key}->{stats}->{size};
                                $dequeue = $ref->{'queue'}->{$key}->{stats}->{dequeueCount};
                                $enqueue = $ref->{'queue'}->{$key}->{stats}->{enqueueCount};
                        }
                }

                # escribe resultado obtenido
                $queuename = $key;
                if ( !@QUEUES || grep (/$queuename/, @QUEUES) ) {
                    #print "PUTVAL \"$HOSTNAME/JMSQUEUE/queue_length-$queuename\" interval=$INTERVAL N:$pending\n" if (!$Qname || $Qname eq $queuename ) ;
                    #print "PUTVAL \"$HOSTNAME/JMSQUEUE/queue_length-$queuename\" interval=$INTERVAL N:$pending\n" if ( !@QUEUES || grep (/$queuename/, @QUEUES) ) ;
                    #print "PUTVAL \"$HOSTNAME/JMSQUEUE/queue_messages_rate-$queuename\" interval=$INTERVAL N:$enqueue:$dequeue\n" if ( !@QUEUES || grep (/$queuename/, @QUEUES) ) ;
                    print "PUTVAL \"$HOSTNAME/$queuename/queue_length-pending\" interval=$INTERVAL N:$pending\n";
                    #print "PUTVAL \"$HOSTNAME/$queuename/queue_message_rate-enqueue\" interval=$INTERVAL N:$enqueue\n";
                    #print "PUTVAL \"$HOSTNAME/$queuename/queue_message_rate-dequeue\" interval=$INTERVAL N:$dequeue\n";
                    print "PUTVAL \"$HOSTNAME/$queuename/queue_messages_rate-tasa\" interval=$INTERVAL N:$enqueue:$dequeue\n";
                }

        }
        # sale si se paso el parametro "--once"
        exit if ( $SALIR );
}


