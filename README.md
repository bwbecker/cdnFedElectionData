# Canadian Federal Election Data

There are lots of people who want to use Canadian Federal elections data, but no good source for it.  
Sure, Elections Canada and the Open Government Portal have the data, but it's hard to find, and 
harder still to clean and put into a usable state.  This project aims to change that.

It provides a CSV file for each of the 43 Federal elections, all in a standard format.
It also provides a CSV file, in the same format, with all 43 elections.  There's also
a CSV with province codes and another with party codes. 

Please see the documentation and data files at my 
[Election Modelling](http://election-modelling.ca/rawdata/) web site.

Raw data is in `/rawData`.  Elections 1 - 40 are in in one huge CSV file, `History_Federal_Election_Ridings.csv`
downloaded from the Open Data Portal.  Elections 39 - 43 are in a finer level of detail and
are found in `/rawData/election_XX` where `XX` is the election number.

## Process

If you'd like to clone the project and hack on it yourself...

### Prerequisites
1. Basic *nix command line tools:  Gnu Make, bash, Gnu sed
2. A Postgresql database

### Workflow
The overall process is controlled by the makefile.  The `makefile` is not my finest work,
unfortunately.  It proceeds in several steps:

####
Create a database in postgres.
* `psql service=????`  # log in to an existing database
* `CREATE DATABASE esim;`
* logout
* Log in to the newly created database
* `CREATE SCHEMA _elections;`


1. Create a `_work` schema in the database.  Load the raw downloaded
data into appropriate tables, no modifications to the data.
1. Create a view for each of the above tables that "cleans" the data.  In
general, this includes:
    1. Filtering out unneeded records.
    1. Omitting unneeded columns.
    1. Synthesizing some columns such as ed_id (electoral district id).
    1. Normalizing party information and province codes.
1. Create the final tables in the `_elections` schema.
1. Extracting the CSV files.