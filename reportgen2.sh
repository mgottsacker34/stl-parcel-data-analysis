#!/bin/bash
echo -e "parcelid\tland use\tzoning\tassessed total\tappraised total" > report2.txt
find ./html-files-1 -type f -name "index*" |
while read x
do
  # strip directory path from parcelid
  echo -n -e `echo "$x" | sed 's/.*\([0-9]\{11\}\).*/\1/'` >> report2.txt
  echo -n -e "\t" >> report2.txt

  # get Land Use and append to report
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '<th>Land use:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/Land use://'` >> report2.txt
  echo -n -e "\t" >> report2.txt

  # get Zoning
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '<th>Zoning:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/Zoning:\([A-Z]\).*/\1/'` >> report2.txt
  echo -n -e "\t" >> report2.txt

  # get Assessed Total
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '>Assessed total:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/[^\$$]*//'` >> report2.txt
  echo -n -e "\t" >> report2.txt

  # get Appraised Total value and append it to report
  echo -n -e `cat "$x" | tr -d "\r\n" | egrep -o '<th>Appraised total:</th><td>[^<]*' | head -n1 | sed 's/<[^>]*>//g' | sed 's/[^\$$]*//'` >> report2.txt
  # newline to separate this entry from following one
  echo -n -e "\n" >> report2.txt
done
