#/bin/bash -e
#FILES=$1
FILEA=$1
FILEB=$2

[ -z $FILEA ] && exit 1
[ -z $FILEB ] && exit 1
[ "a$FILEB" == "a$FILEA" ] && exit 1

rm -f merged.rrd
python ~/simple-rrd-merge.py $FILEA $FILEB  | rrdtool restore /dev/stdin merged.rrd
cp merged.rrd $FILEB
rm -f merged.rrd 
rm -f $FILEA


