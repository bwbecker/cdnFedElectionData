# Canadian Federal Election Data

There are lots of people who want to use Canadian Federal elections data, but no good source for it.  
Sure, Elections Canada and the Open Government Portal have the data, but it's hard to find, and 
harder still to clean and put into a usable state.  This project aims to change that.

It provides a CSV file for each of the 43 Federal elections, all in a standard format.
It also provides a CSV file, in the same format, with all 43 elections.  There's also
a CSV with province codes and another with party codes. 

## Getting the data

That's why you're here, right?  To get the data?  There are a couple of approaches:

1. The easiest, if you're familiar with git and the command line, is to simply clone
the repository.
1. You can download everything as a zip file (look for the "Clone or download" button),
open the zip file, and then find the CSV files in the `csv` directory.
1. You can click on the `csv` link and then on the file you want.  Then right-click
the "Raw" button, and select "Save file as...".  Change the file name extension
to ".csv" and save.  But this is tediuos unless all your're after is the
one big file.

## Data Format
Each of the election CSV files contains one row for each candidate with the following columns:

1. **election_id**: A sequence number for the election:  1 for the first one in
   1867, 2 for the second one in 1872, etc.
1. **prov_code**:  A code such as "NB" or "ON" to indicate the candidate's province.
1. **ed_id**: A code for the electoral district (riding).  In recent elections, it's the same
   code that Elections Canada uses; in older elections it's simply a sequence number.
1. **ed_name**: The name of the electoral district (riding).
1. **cand_id**: A unique number assigned to each candidate.  I'd love to have
   the same number assigned to each of the five times Harold Albrecht ran,
   for example.  But the hurdles of merging "Harold Albrecht" with "Harold Glenn Albrecht"
   or the 3 times Julian Ichim ran in Kitchener-Waterloo iwth the one time he ran in Kitchener-Centre
   are more than I can tackle right now.  So each candidate in each election has an id number.
1. **cand_name**:  The name of the candidate.
1. **cand_raw_party_name**: The candidate's party name as recorded in the raw data.
1. **party_code**: A code for the "cleaned" parties.  Please see the section on
    "cleaning party names", below.  This code can be looked up in the `parties` 
    CSV/table to find the party name and a flag for whether it is "main_line" or not.
1. **elected**: True if the candidate was elected; false otherwise.
1. **acclaimed**: In early elections some candidates did not have opposition and
    were acclaimed.  In those cases, votes were not held and so the votes column
    is blank/nul.  This column is true if the candidate was acclaimed and false otherwise.
1. **votes**: The number of votes the candidate earned (unless s/he was acclaimed).
1. **place**: The rank of this candidate within their electoral district with
   1 being the candidate with the most votes.

## Raw Data
The raw data is from the [Open Data Portal)](https://open.canada.ca/data/en/dataset?q=election&collection=federated&collection=primary&sort=&page=2), 
most of it retrieved on 2019-10-18.  We're using three different formats:

* For elections 39 - 42 (and hopefully 43 and later) there is data to the
  polling station level.  
* For elections 1 - 40 there is one large CSV file with data to the riding level.
* For election 43 (just held at the time of writing) there are preliminary
  results from [Elections Canada](https://enr.elections.ca/DownloadResults.aspx).

To harmonize this, we drop the poll-by-poll data and go to just the riding level.

There is some overlap in the data sets.  We prefer the first data set to
the second in those cases.

The Open Data Portal also includes a link to data for the 38th election.
However, it's in a different format and does not provide the same level of
detail.

### Cleaning Party Names
The party names in the raw data are not uniform.  For example, it contains 
"N.D.P.", "NDP-New Democratic Party", and "New Democratic Party".  It's 
safe to say that these all refer to the same party.

The `_work.party_name_lookup` table maps the raw names to a party code.  For
example, the three varieties of NDP, noted above, are all mapped to
'NDP'.  `_elections.parties` expands that code to a normalized name.

**Independents**

There are 68 parties (after normalizing names) that ran fewer than 10 
candidates -- ever.  These are all mapped to be Independents.

A number of candidates had a party of "No Affiliation" or "No affiliation to a
recognized party".  They were also mapped to Independent.

Finally, [Wikipedia](https://en.wikipedia.org/wiki/Independent_Liberal) says 
that a party such as "Independent Liberal" is essentially a Liberal that is no longer in caucus.
Today we would normally classify such a person as just "Independent"
(which I have done).
 
### Dual-Candidate elections
Some ridings elected two members.  
[Wikipedia](https://en.wikipedia.org/wiki/Electoral_district_(Canada)) says:

> While electoral districts at both the federal and provincial levels are now 
> exclusively single-member districts, multiple-member districts have been used 
> in the past. The federal riding of Ottawa elected two members from 1872 to 1933. 
> The federal riding of Halifax elected two members from the 1800s to 1966.
    
These ridings are found in SQL and divided into two ridings, each electing
a single member.  The original riding is suffixed with "-1" and "-2".  One
winner is assigned to each; similarly for losing candidates.

## Process

If you'd like to clone the project and hack on it yourself...

### Prerequisites
1. Basic *nix command line tools:  Gnu Make, bash, sed
2. A Postgresql database

### Workflow
The overall process is controlled by the makefile.  It proceeds in
several steps:

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