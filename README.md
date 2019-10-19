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

To harmonize this, this data goes to the riding level with one record per 
candidate.

There is some overlap in the data sets.  We prefer the first data set to
the second in those cases.

The Open Data Portal also includes a link to data for the 38th election.
However, it's in a third format and does not provide the same level of
detail.
