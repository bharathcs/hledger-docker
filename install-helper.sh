#!/bin/bash

oldIFS=$IFS
IFS=','
array=($2)
IFS=$oldIFS

for element in "${array[@]}"
do
  stack install --resolver=$1 $element
done
