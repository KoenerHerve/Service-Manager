#!/bin/bash
function countAll {
	i=0

	for f in $(ls $1)
	do
		if [[ -d $1/$f ]]
		then
			i=$(($i+$(countAll $1/$f)))
		else
			if [[ -f $1/$f && $f != *.img ]]
			then
				i=$(($i+$(sed -n '$=' $1/$f)))
			fi
		fi
	done
	echo $i
}

echo $(countAll .)

