#!/bin/bash

FILES=./kurse/*
for f in $FILES
do
  #echo "Processing $f file..."
  echo $f
  xls2txt $f | tail -n +4 | head -n -1
  # take action on each file. $f store current file name
  #cat $f
  echo "!!newcourse!!"
done
