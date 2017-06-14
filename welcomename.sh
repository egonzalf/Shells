commentname=$(getent passwd $USER | cut -d : -f 5 | cut -f 1 -d ' ' | cut -f 1 -d ,)
id=$(id -u)
if [ $id -ge 1000 ]; then
	columns=$(stty size | cut -f2 -d' ')
	cols=${columns:-80}
	name=${commentname:-$USER}
	figlet -w $cols "Welcome $name!"
	unset cols columns commentname name
fi
