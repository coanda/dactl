#!/bin/bash

# XXX: This is meant to be called from this location, it's a simple thing and it's meant to be

sizes=( '16' '24' '32' '48' '256' '512' )

for size in ${sizes[@]}; do
  dir="hicolor/"$size"x"$size"/apps"
  input="org.coanda.Dactl.svg"
  output="org.coanda.Dactl.png"
  echo "Generating file $dir/$output"
  inkscape -z -e $dir/$output -w $size -h $size src/$input
done
