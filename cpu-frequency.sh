#!/bin/sh

##### This script will change the CPU FREQUENCY GOVERNOR
##### and the TurboBoost setting.
##### acpi-cpufreq driver is expected (not intel_pstate)



NPROCS=`cat /proc/cpuinfo | grep "core id" | wc -l`
NPROCS=$(($NPROCS - 1))

GOVERNOR="performance"
CHANGETURBOBOOST=""
CHANGEGOVERNOR=""

print_usage() {
    echo "usage: $0 [--enable-turbo|--disable-turbo|--performance|--ondemand]"
}

if [ ! -n "$1" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]
then
    print_usage
    exit 0;
fi

GOVERNOR=`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

while [ -n "$1"  ]
do
    case "$1" in
        --enable-turbo)
            CHANGETURBOBOOST="yes"
            TURBOBOOST=1
            shift
            ;;
        --disable-turbo)
            CHANGETURBOBOOST="yes"
            TURBOBOOST=0
            shift
            ;;
        --ondemand)
            CHANGEGOVERNOR="yes"
            GOVERNOR="ondemand"
            shift
            ;;
        --performance)
            CHANGEGOVERNOR="yes"
            GOVERNOR="performance"
            shift
            ;;
        *)
            exit
            ;;
    esac
done

if [ "$CHANGEGOVERNOR" = "yes" ]; then
    echo "Setting Frequency governor : $GOVERNOR"
    for i in `seq 0 1 ${NPROCS}`; do echo "$GOVERNOR" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor; done
fi

if [ "$CHANGETURBOBOOST" = "yes" ]; then
    echo "TurboBoost mode: $TURBOBOOST"
    echo $TURBOBOOST > /sys/devices/system/cpu/cpufreq/boost
fi

cpupower frequency-info
