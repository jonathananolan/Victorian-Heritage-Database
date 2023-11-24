# Heritage Victoria Downloader
The Vicotrian heritage database contains information about properties on the Victorian Heritage Register as well as heritage overlay information for some council areas. 

The heritage register can be very handy to anlayse, but the data is only provided through a cumbersome API. 

This code will download the Heritage Register for you to analyse on your computer. 

## What youy need
This code uses R and Rstudio.

To run the code you need to register for a Victorian Government API key, available [here](https://www.developer.vic.gov.au/). 

## Just get the database

A copy of the database downloaded in late 2023 is available [here](http:/github.com/jonathananolan/Victorian-Heritage-Database/heritage_db.csv.zip).

## How accurate is the Heritage Database? 
There is great variability in Heritage Database quality. The highest level of protection is granted to Heritage Register properties and these are well recorded. Some councils also keep a good database of properties with overlays, stating what level of protection they have. Other councils only list the level of protection through cumbersome PDFs. Some dont' even list individual properties, and have one entry on the database for an entire area. 

![Heritage Database Graph](http:/github.com/jonathananolan/Victorian-Heritage-Database/heritage_database_compliance.png)