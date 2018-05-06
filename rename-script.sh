#!/bin/bash
find ./html-files-1 -type f |
while read f
do
  mv "$f" "`echo $f | sed 's/.*\([0-9]\{11\}\).*/\.\/html-files-2\/\1/'`"
done
