# Canadian Federal Election Data

There are lots of people who want to use Canadian Federal elections data, but no good source for it.  
Sure, Elections Canada and the Open Government Portal have the data, but it's hard to find, and 
harder still to clean and put into a usable state.  This project aims to change that.

## Raw Data
The raw data is from the [Open Data Portal)](https://open.canada.ca/data/en/dataset?q=election&collection=federated&collection=primary&sort=&page=2), 
most of it retrieved on 2019-10-18.  We're using two different formats:

* For elections 39 - 42 (and hopefully 43 and later) there is data to the
  polling station level.  
* For elections 1 - 40 there is one large CSV file with data to the riding level.
* For election 43 (just held at the time of writing) there are preliminary
  results from [Elections Canada](https://enr.elections.ca/DownloadResults.aspx).

To harmonize this, we drop the poll-by-poll data and go to just the riding level.

There is some overlap in the data sets.  We prefer the first data set to
the second in those cases.

The Open Data Portal also includes a link to data for the 38th election.
However, it's in a third format and does not provide the same level of
detail.

### Cleaning Party Names
The party names in the raw data are not uniform.  For example, it contains 
"N.D.P.", "NDP-New Democratic Party", and "New Democratic Party".  It's 
safe to say that these all refer to the same party.

The `_elections.party_names` table maps the raw names to a cleaned name.  For
example, the three varieties of NDP, noted above, are all mapped to
'New Democratic Party'.

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

    While electoral districts at both the federal and provincial levels are now 
    exclusively single-member districts, multiple-member districts have been used 
    in the past. The federal riding of Ottawa elected two members from 1872 to 1933. 
    The federal riding of Halifax elected two members from the 1800s to 1966.
    
These ridings are found in SQL and divided into two ridings, each electing
a single member.  The original riding is suffixed with "-1" and "-2".  One
winner is assigned to each; similarly for losing candidates.