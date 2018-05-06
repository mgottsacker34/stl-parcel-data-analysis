#!/bin/bash
echo -e "parcelid\tland use\tzoning\tassessed total\tappraised total\n" > report.txt
find ./html-files-0 -type f |
while read x
do
  # strip directory path from parcelid
  echo -n -e `echo "$x" | sed 's/\.\/.*\///' | tr -d "\r\n"` >> report.txt
  echo -n -e "\t" >> report.txt

  # get Land Use and append to report
  echo -n -e `cat $x | tr -d "\r\n" | egrep -o '<th>Land use:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/Land use://'` >> report.txt
  echo -n -e "\t" >> report.txt

  # get Zoning
  echo -n -e `cat $x | tr -d "\r\n" | egrep -o '<th>Zoning:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/Zoning:\([A-Z]\).*/\1/'` >> report.txt
  echo -n -e "\t" >> report.txt

  # get Assessed Total
  echo -n -e `cat $x | tr -d "\r\n" | egrep -o '>Assessed total:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/[^\$$]*//'` >> report.txt
  echo -n -e "\t" >> report.txt

  # get Appraised Total value and append it to report
  echo -n -e `cat $x | tr -d "\r\n" | egrep -o '<th>Appraised total:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/[^\$$]*//'` >> report.txt
  # newline to separate this entry from following one
  echo -n -e "\n" >> report.txt
done
