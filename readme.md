# Heritage Victoria Downloader
The Victorian heritage database contains information about properties on the Victorian Heritage Register as well as heritage overlay information for some council areas. 

The heritage database can be useful to analyse, but the data is only provided through a cumbersome API. 

This code will download the Heritage database for you to analyse locally. 

## What you need
This code uses R and Rstudio.

To run the code you need to register for a Victorian Government API key, available [here](https://www.developer.vic.gov.au/). 

## Just get the database

A copy of the database downloaded in late 2023 is available [here](https://github.com/jonathananolan/Victorian-Heritage-Database/blob/a8c9930efed2bffda6fed97c8b7bd4df3b49b163/heritage_db.csv.zip).

## How accurate is the Heritage Database? 
There is great variability in Heritage Database quality. 

The highest level of protection is granted to Heritage Register properties and these are well recorded. 

Some councils such as Yarra also keep a good database of properties with overlays, stating what level of protection they have. 

Other councils like Merri-Bek tend to only list the level of protection through cumbersome PDFs. 

Some councils like Maribyrnong don't even list individual properties and have one entry on the database for an entire area. 

Finally some councils like Port Phillip don't bother to contribute at all. 

![Heritage Database Graph](https://github.com/jonathananolan/Victorian-Heritage-Database/blob/a8c9930efed2bffda6fed97c8b7bd4df3b49b163/heritage_database_compliance.png)