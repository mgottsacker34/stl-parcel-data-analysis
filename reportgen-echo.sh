#!/bin/bash
echo -e "parcelid\tland use\tzoning\tassessed total\tappraised total" > parcel-report.tsv
find ./html-files -type f -name "index*" |
while read x
do
  # strip out everything except parcelid and put it in first column
  echo -n -e `echo "$x" | sed 's/.*\([0-9]\{11\}\).*/\1/'`
  echo -n -e "\t"

  # get Land Use and append to report
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '<th>Land use:</th><td>[^<]+' | head -n1 | sed 's/<[^>]*>//g' | sed 's/Land use://'`
  echo -n -e "\t"

  # get Zoning
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '<th>Zoning:</th><td>[^<]+' | head -n1 | sed 's/<[^>]*>//g' | sed 's/Zoning:\([A-Z]\).*/\1/'`
  echo -n -e "\t"

  # get Assessed Total
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '>Assessed total:</th><td>[^<]+' | head -n1 | sed 's/<[^>]*>//g' | sed 's/[^\$$]*//'`
  echo -n -e "\t"

  # get Appraised Total value
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '<th>Appraised total:</th><td>[^<]+' | head -n1 | sed 's/<[^>]*>//g' | sed 's/[^\$$]*//'`

  # newline to separate this entry from following one
  echo -n -e "\n"
done
