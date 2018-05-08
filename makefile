handle-addr-list.csv: stl-parcel-dataset-1.csv
	cat stl-parcel-dataset-1.csv | tr -d '\r' | cut -d ',' -f 1,3,52,55 | tail -n +2 > @a

urls.txt: handle-addr-list.csv
	cat handle-addr-list.csv | sed 's/ /%20/g' | sed 's/\([0-9]\)\([0-9]\{10\}\)/\20/' | sed 's/^/?parcelid=/' | sed 's/,/\&addr=/' | sed 's/,/\&stnum=/' | sed 's/,/\&stname=/' | sed 's/^/https:\/\/www.stlouis-mo.gov\/data\/address-search\/index.cfm/' | sed 's/$$/\&CategoryBy=form.start,form.RealEstatePropertyInfor\&firstview=true/' > @a

html-files: urls.txt
	cat urls.txt | xargs -n 20 -P 8 wget -P ./html-files/

parcel-report.tsv: html-files/* reportgen.sh
	bash reportgen-echo.sh > @a

parcel-report-wo-blanks.tsv: parcel-report.tsv
	cat parcel-report.tsv | egrep -v '\t\t\t\t' | sort > @a
