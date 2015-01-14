#!/bin/bash

# filepath $1
# filename $2,$3,$4,$5

if [ -d "$1" ]; then
	echo "dir exist"
else
	mkdir -p "$1"
fi 

cd "$1"

if [ -f "$2" ]; then
	echo "$2 file exist"
else
	touch "$2"
fi

if [ -f "$3" ]; then
	echo "$3 file exist"
else
	touch "$3"
fi

if [ -f "$4" ]; then
	echo "$4 file exist"
else
	touch "$4"
fi

if [ -f "$5" ]; then
	echo "$5 file exist"
else
	touch "$5"
fi
