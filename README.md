# St. Louis Parcel Data Aggregation

## Project overview

This project scrapes webpages served by the [St. Louis Government's Open Data project](https://www.stlouis-mo.gov/data/). While the Open Data project makes many datasets publicly available, they are not comprehensive compared to the information exposed through the [Address and Property Search portal](https://www.stlouis-mo.gov/data/address-search/).

The result produced here, found in [parcel-report-wo-blanks.tsv](./parcel-report-wo-blanks.tsv), is a tab-separated value file with four fields (Parcel ID, Land Use, Zoning, Assessed Total, Appraised Total). My friend and sociology researcher, Andrew Smith, requested these fields for help in his own research. He intends to use this information to produce map(s) of the city of St. Louis based on their total value. Andrew can use the parcel ID of an entity and map it to a latitude and longitude, and then apply more overlays based on how the parcel is used and its value. He intends to use ESRI shapefiles and the Arc Suite to create these meaningful figures.

## Development

I started looking through the Open Data provided by STL and found a database file that I turned into a .csv file, [stl-parcel-dataset-1.csv](./stl-parcel-dataset-1.csv). This file contains over 127,000 entries for land parcels, keyed on a field called HANDLE. I first filtered the dataset to the necessary fields. The command below does the following: trims the carriage return because the database file came from a Microsoft format; filters the set into the HANDLE and address fields; takes only the entries themselves and discards the header line; outputs into a file.

`cat stl-parcel-dataset-1.csv | tr -d '\r' | cut -d ',' -f 1,3,52,55 | tail -n +2 > handle-addr-list.csv`

With that list, I could start constructing a URL. The web app hosted by STL has a URL pattern that was straightforward to model. In the pipeline below, I replace all spaces (which only appeared in the address long form) with %20, as is typical for representing spaces. The next step of of the pipeline transforms the HANDLE. I realized the Parcel ID of a given parcel could be constructed from the HANDLE by taking only the last 10 digits of the HANDLE and appending a zero. Following that transformation, the rest of the pipeline places the necessary URL query parameters in their proper places, inserts the base URL, and appends a string of additional search parameters.

`cat handle-addr-list.csv | sed 's/ /%20/g' | sed 's/[0-9]\([0-9]\{10\}\)/\10/' | sed 's/^/?parcelid=/' | sed 's/,/\&addr=/' | sed 's/,/\&stnum=/' | sed 's/,/\&stname=/' | sed 's/^/https:\/\/www.stlouis-mo.gov\/data\/address-search\/index.cfm/' | sed 's/$/\&CategoryBy=form.start,form.RealEstatePropertyInfor\&firstview=true/' > urls.txt`

After generating the list of urls, I tried a couple different approaches for getting the content found at each of the URLs. I thought of using `curl` to get a stream of HTML, and then filtering and reducing it in a pipeline. Since I needed to process it four different times for each field Andrew required, I realized that solution would not be sustainable (one `curl` for every `egrep`). I decided to do a `wget` on each of the URLs. I first generated a bash script called [wgetter.sh](./unused/wgetter.sh) using the URL list and some `sed` calls. After downloading about 3,000 HTML pages, I thought that process was too slow, so I parallelized the task with the command below. With the help of the stackoverflow community, I decided on 8 threads (`-P 8`) so as to not put too much strain on the web server. I also used `-n 20` in an attempt to use the same TCP connection across `wget` calls and speed things up that way. Stackoverflow help found [here](https://stackoverflow.com/questions/7577615/parallel-wget-in-bash).

`cat urls.txt | xargs -n 20 -P 8 wget -P ./html-files/`

I had over 127,000 HTML files after the above process finished. It took several hours. At first, I started renaming all those files to the parcel ID of each respective webpage, but that was clearly taking too long, so I decided to handle that in the processing script. The script I ended up with is [reportgen-echo.sh](./reportgen-echo.sh). That script echoes to STDOUT. (Note: a previous version creates the file outright; see the [unused folder](./unused/)). For each file downloaded, it strips all newline characters, pattern matches for Andrew's fields, and strips out unnecessary characters. In some cases, I noticed files had multiple entries for each of the fields if they had data spanning multiple years. This is the reason for the `head -n1` call in each of the field pipelines. This script took a couple hours to run over all the HTML files. At the end, it produced the [parcel-report.tsv file](./parcel-report.tsv). I sorted that list, removed the blank entries, and produced [parcel-report-wo-blanks.tsv](./parcel-report-wo-blanks.tsv) file. I used the following command for that final filtering:

`cat parcel-report.tsv | egrep -v '\t\t\t\t' | sort > parcel-report-wo-blanks.tsv`

3% of the entries in the parcel-report file were blank. After further investigation, these files seemed to be produced when the web searcher returned multiple results for the given URL or when the parcel simply had no data for those fields. In the first case, it is necessary to search only on the address instead of the parcel ID. The web app will return links to the multiple parcel IDs. An extension of this project will devise a way to deal with those cases. While that will take more creativity, it should be noted that with the large number of successful entries, Andrew will be able to produce meaningful maps with the .tsv file as is because the maps will depend on averages.

I made a [makefile](./makefile) which can be used to build each step described here.

### Quick data facts
The first dataset ([stl-parcel-dataset-1.csv](./stl-parcel-dataset-1.csv)) is 48.5 MB. All of the downloaded HTML files came to 6.06 GB. The resultant .tsv file is 6.73 MB.

#### Note
The process described here is a condensed version of the development process. I kept track of more intricate details of my progress in the file [thoughts.txt](./thoughts.txt). In addition, all of the files I wrote or generated but did not end up using ended up in the [unused folder](./unused/).



