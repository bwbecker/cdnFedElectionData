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


## To Do
I think this should be viewed as a prototype in light of what I've learned with 
the safe seats project, in particular.

Observations to address:
* My `makefile` sucks.  I'd much prefer working in Scala for tasks that need
  more than SQL.  I wonder if it's time to learn and leverage 
  [Mill](https://github.com/com-lihaoyi/mill).
  
* There should be at least one more schema:
  
  * `_work`: For initial construction work.  Not to be used for production.
    
  * `_raw`: Data that is as close to Elections Canada as I can reasonable get.  No 
    introduced identifiers, no merging of entities like candidates or ridings or ....
    
  * `_clean`: The final, fully normalized, schema.  Combine ridings, parties,
    candidates, etc. where possible.  Assign meaningful IDs.
    
* When assigning IDs, the process should be designed so that new data can be added
  without reassigning previous IDs.  I think the best way to do that is to sort
  the potential things to assign by the first election in which they appeared
  and then assign IDs in increasing order.  Thus new entities will appear at the
  end of that list.
  
* It would be good to get another set of eyes on some of the work with parties.
  In particular, assignment of ideology codes and maybe which ones to combine.