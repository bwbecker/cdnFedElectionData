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
to ".csv" and save.  But this is tediuos unless all you're after is the
one big file.

## Data Format

### csv_by_cand/results_*.csv
Each CSV file contains one row for each candidate.
There is one file for each election since 1867 plus one file that contains all
of the candidates since 1867.
Each CSV file contains the following columns.

1. **election_id**: A sequence number for the election:  1 for the first one in
   1867, 2 for the second one in 1872, etc.
1. **election_date**: The date the bulk of the election was held.  Some early elections were
   held on different days in different regions of the country.
1. **prov_code**:  A code such as "NB" or "ON" to indicate the candidate's province.
1. **ed_id**: A code for the electoral district (riding).  In recent elections, it's the same
   code that Elections Canada uses; in older elections it's simply a sequence number.
1. **ed_name**: The name of the electoral district (riding).
1. **cand_id**: A unique number assigned to each candidate.  I'd love to have
   the same number assigned to each of the five times Harold Albrecht ran,
   for example.  But the hurdles of merging "Harold Albrecht" with "Harold Glenn Albrecht"
   or the 3 times Julian Ichim ran in Kitchener-Waterloo with the one time he ran in Kitchener-Centre
   are more than I can tackle right now.  So each candidate in each election has an id number.
1. **cand_name**:  The name of the candidate.
1. **cand_raw_party_name**: The candidate's party name as recorded in the raw data.
1. **party_id**: An id number for the for the "cleaned" parties.  Please see the section on
    "cleaning party names", below.  This id can be looked up in `csv_other/party_summary.csv` 
    to find the party name and a flag for whether it is "mainline" or not.
1. **party_name**: The "cleaned" party name.  See below.
1. **party_short_name**: A shortened version of the party name; hopefully suitable for column names.
1. **mainstream**: A boolean value; true if the party ever attained 5% or more of the popular vote
   and false otherwise.
1. **votes**: The number of votes the candidate earned (unless s/he was acclaimed).
1. **acclaimed**: In early elections some candidates did not have opposition and
    were acclaimed.  In those cases, votes were not held and so the votes column
    is blank/null.  This column is true if the candidate was acclaimed and false otherwise.
1. **place**: The rank of this candidate within their electoral district with
   1 being the candidate with the most votes.
   
### csv_by_riding/results_*.csv
Each CSV file contains one row for each riding.  There is one file for each of the
elections since 1867.
Each CSV file contains the following columns.

1. **election_id**: See above.
1. **prov_code**: See above.
1. **ed_id**: See above.
1. **ed_name**: See above.

The above are followed by a variable number of columns, one for each "mainstream"
party in that particular election, which contains the votes cast for that party.
A mainstream party is defined, somewhat arbitrarily,
as a party who has won at least 5% of the vote in any election.  Votes for 
parties that are not mainstream are collected in an additional column labelled
"Other".

For example, the CSV file for the 43rd (2019) election contains columns
for each of "Bloc", "Con", "Grn", "Lib", "NDP", and "Other.  Meanwhile, the
file for the 1867 election contains columns for "AntiConfed", "Con", "Lib", 
"Other", and "PC".

The names used as column headers is the `party_short_name` found in `csv_other/party_summary.csv`.

The columns for each party are followed by three more headed "1st", "2nd", and
"3rd".  The give the party short name of the party with the most votes, the
second most votes, and the third most votes.

### csv_other/party_summary.csv
This CSV provides summary information for each party.  It contains the following
columns:

1. **party_id**: A unique identifier for this party.
1. **party_name**: The "cleaned" party name for this party.  Please see the
    section on "Cleaning Party Names", below.
1. **party_short_name**: A unique shortened version of the party name used as a label
    in other CSV files, etc.
1. **ideology_code**: An attempt to collapse similar parties for use in
   `csv_other/by_election.csv`.  **Feedback on these codes and their assignments is very welcome.**  The codes are:
   1. Con = Conservative (e.g. Conservative Party of Canada, Progressive Conservative Party)
   1. Env = Environmental focus (e.g. Green Party)
   1. Labour = A focus on workers (e.g. NDP, Progressive Workers Movement, Marxist-Leninist)
   1. Lib = Liberal
   1. Oth = Other  (A collection of smaller parties for which a better label was not
        immediately evident.  Includes Independents.)
   1. Pop = Populist (e.g. People's Party, Canadian Action Party)
   1. Quebec (Parties, such as the Bloc, that are focused on Quebec nationalism.)
   1. SglIss = Single Issue parties (e.g. Animal protection, anti-conscription, seniors)
1. **mainstream**: True if the party has ever achieved 5% or more of the vote in any 
    election.  
1. **first_election**: The first election this party participated in.
1. **last_election**: The last election this party participated in.
1. **num_candidates**:  The total number of candidates this party has fielded in all elections.
1. **also_known_as**:  The original party names contained in the raw data before cleaning.
    See the section, below, on cleaning party names.

## Raw Data
The raw data is from:

* For elections 39 - 42 (and hopefully 43 and later) there is data to the
  polling station level for 
  [39](https://www.elections.ca/content.aspx?section=res&dir=rep/off/39gedata&document=bypro&lang=e)
  [40](https://www.elections.ca/content.aspx?section=res&dir=rep/off/40gedata&document=bypro&lang=e),
  [41](https://www.elections.ca/content.aspx?section=res&dir=rep/off/41gedata&document=bypro&lang=e),
  and [42](https://www.elections.ca/content.aspx?section=res&dir=rep/off/42gedata&document=bypro&lang=e).
  Use the "Poll results" for all of Canada.
* For elections 1 - 40 there is one large CSV file with data to the riding level
  at the the [Open Data Portal)](https://open.canada.ca/data/en/dataset?q=election&collection=federated&collection=primary&sort=&page=2), 
  retrieved on 2019-10-18.
* For election 43 (just held at the time of writing) there are preliminary
  results from [Elections Canada](https://enr.elections.ca/DownloadResults.aspx).

Quoting was messed up in the CSV for ridings 24047, 35003, 35084, 59029 in election 40.  Fixed them up by hand.

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

As a first step, the following party names were normalized.  

<table>
<tr><th>Normalized Name</th><th>Original Names</th></tr>

<tr><td>Animal Alliance/Environment Voters</td><td>Animal Alliance Environment Voters Party of Canada<br>Animal Alliance/Environment Voters<br>AAEV Party of Canada</td></tr>
<tr><td>Canadian Action Party</td><td>CAP<br>Canadian Action Party<br>Canadian Action</td></tr>
<tr><td>Christian Heritage Party</td><td>CHP Canada<br>Christian Heritage Party<br>Christian Heritage Party of Canada</td></tr>
<tr><td>Communist Party</td><td>Communist<br>Communist Party of Canada</td></tr>
<tr><td>Green Party</td><td>Green Party<br>Green Party of Canada</td></tr>
<tr><td>Independent</td><td>Independent<br>No Affiliation<br>No affiliation to a recognised party</td></tr>
<tr><td>Libertarian Party</td><td>Libertarian<br>Libertarian Party of Canada</td></tr>
<tr><td>Marijuana Party</td><td>Marijuana Party<br>Radical Marijuana</td></tr>
<tr><td>Marxist-Leninist Party</td><td>Marxist-Leninist<br>Marxist-Leninist Party<br>ML</td></tr>
<tr><td>Newfoundland and Labrador First Party</td><td>Newfoundland and Labrador First Party<br>NL First Party</td>),
</td></tr>
<tr><td>New Democratic Party</td><td>N.D.P.<br>NDP-New Democratic Party<br>New Democratic Party</td></tr>
<tr><td>People's Political Power Party of Canada</td><td>People's Political Power Party of Canada<br>PPP</td></tr>
<tr><td>Pirate Party</td><td>Pirate<br>Pirate Party<br>Pirate Party of Canada</td></tr>
<tr><td>Progressive Canadian Party</td><td>Progressive Canadian Party<br>PC Party</td></tr>
<tr><td>Reform Party</td><td>Reform<br>Reform Party of Canada</td></tr>
<tr><td>Republican Party</td><td>Republican<br>Republican Party</td></tr>
<tr><td>Rhinoceros Party</td><td>Rhinoceros<br>Parti Rhinocéros<br>Parti Rhinocéros Party<br>neorhino.ca</td></tr>
<tr><td>United Reform Movement</td><td>United Reform<br>United Reform Movement</td></tr>
<tr><td>Western Block Party</td><td>WBP<br>Western Block Party</td></tr>
</table>

Secondly, [Wikipedia](https://en.wikipedia.org/wiki/List_of_federal_political_parties_in_Canada) lists
a number of parties that went through name changes.  Taking those into account
gives the following list:

<table>
<tr><th>Normalized Name</th><th>Original Names</th></tr>

<tr><td>Animal Alliance/Environment Voters</td><td>Animal Alliance Environment Voters Party of Canada<br>Animal Alliance/Environment Voters</td></tr>
<tr><td>Canadian Action Party</td><td>CAP<br>Canadian Action Party<br>Canadian Action</td></tr>
<tr><td>Christian Heritage Party</td><td>CHP Canada<br>Christian Heritage Party<br>Christian Heritage Party of Canada</td></tr>
<tr><td>Co-operative Commonwealth Federation</td><td>Co-operative Commonwealth Federation<br>New Party</td></tr>
<tr><td>Communist Party</td><td>Communist<br>Communist Party of Canada<br>United Progressive<br>Unity<br>Labour Progressive Party</td></tr>
<tr><td>Green Party</td><td>Green Party<br>Green Party of Canada</td></tr>
<tr><td>Independent</td><td>Independent<br>No Affiliation<br>No affiliation to a recognised party</td></tr>
<tr><td>Labour</td><td>Labour<br>Conservative-Labour<br>Farmer Labour<br>Farmer-United Labour<br>Labour Farmer<br>Liberal Labour<br>Liberal Labour Party<br>National Labour<br>United Farmers of Ontario-Labour<br>United Farmers-Labour</td></tr>
<tr><td>Liberal Labour Progressive</td><td>Liberal Labour Progressive<br>National Liberal Progressive</td></tr>
<tr><td>Libertarian Party</td><td>Libertarian<br>Libertarian Party of Canada</td></tr>
<tr><td>Marijuana Party</td><td>Marijuana Party<br>Radical Marijuana</td></tr>
<tr><td>Marxist-Leninist Party</td><td>Marxist-Leninist<br>Marxist-Leninist Party<br>ML</td></tr>
<tr><td>New Democratic Party</td><td>N.D.P.<br>NDP-New Democratic Party<br>New Democratic Party</td></tr>
<tr><td>Pirate Party</td><td>Pirate<br>Pirate Party<br>Pirate Party of Canada</td></tr>
<tr><td>Progressive Canadian Party</td><td>Progressive Canadian Party<br>PC Party</td></tr>
<tr><td>Progressive Conservative Party</td><td>Progressive Conservative Party<br>Liberal-Conservative<br>National Liberal and Conservative Party<br>National Government</td></tr>
<tr><td>Reform Party</td><td>Reform<br>Reform Party of Canada</td></tr>
<tr><td>Republican Party</td><td>Republican<br>Republican Party</td></tr>
<tr><td>Rhinoceros Party</td><td>Rhinoceros<br>Parti Rhinocéros<br>Parti Rhinocéros Party<br>neorhino.ca</td></tr>
<tr><td>Social Credit Party</td><td>Social Credit Party of Canada<br>New Democracy<br>Ralliement Créditiste<br>Candidats des électeurs</td></tr>
<tr><td>United Farmers</td><td>United Farmers<br>United Farmers of Alberta<br>United Farmers of Ontario<br>Farmer</td></tr>
<tr><td>United Reform Movement</td><td>United Reform<br>United Reform Movement</td></tr>
<tr><td>Western Block Party</td><td>WBP<br>Western Block Party</td></tr>

</table>

The `_work.party_name_normalization` table maps the original names to the normalized names.  
For example, the three varieties of NDP, noted above, are all mapped to
'New Democratic Party'.  This table is then joined to `_work.parties` on the normalized name 
to assign each party an id number as well as other attributes.

 
### Dual-Candidate elections
Some ridings elected two members.   [Wikipedia](https://en.wikipedia.org/wiki/Electoral_district_(Canada)) says:

> While electoral districts at both the federal and provincial levels are now 
> exclusively single-member districts, multiple-member districts have been used 
> in the past. The federal riding of Ottawa elected two members from 1872 to 1933. 
> The federal riding of Halifax elected two members from the 1800s to 1966.
    
These ridings are found in SQL and divided into two ridings, each electing
a single member.  The original riding name is suffixed with "-1" and "-2".  One
winner is assigned to each; similarly for losing candidates.

## Process

If you'd like to clone the project and hack on it yourself...

### Prerequisites
1. Basic *nix command line tools:  Gnu Make, bash, Gnu sed
2. A Postgresql database

### Workflow
The overall process is controlled by the makefile.  It proceeds in
several steps:

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