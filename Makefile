

raw39 = $(wildcard rawData/election_39/pollresults*)
raw40 = $(wildcard rawData/election_40/pollresults*)
raw41 = $(wildcard rawData/election_41/pollresults*)
raw42 = $(wildcard rawData/election_42/pollresults*)

recentElections := 39 40 41 42
recentCSVs = $(foreach e,$(recentElections),work/election_$(e).csv)
rawDataCSVs = ${recentCSVs} work/history.csv work/preliminary.csv 

preliminary = rawData/preliminary_43.csv


all:	.rawDataLoaded
#
# The tool to connect to the Postgresql database.  You'll need to define a service
# with your own credentials in the .pg_service.conf file.
#
PSQL = psql service=esim

test:	${raw39}
	echo ${raw39}

.SECONDEXPANSION:

#
# Generate one CSV file per election where we have the poll data (elections 39 and later).
# Clean up the non-UTF-8 characters.
#
work/election_%.csv: $${raw%}  bin/clean_combine_polls
	bin/clean_combine_polls $* $(filter-out bin/clean_combine_polls,$+) > $@

#
# Clean the non-UTF-8 characters in the history file.
#
work/history.csv: rawData/History_Federal_Electoral_Ridings.csv bin/clean_history
	bin/clean_history $< > $@

work/preliminary.csv: ${preliminary}
	grep -E -e "[0-9]{5}\t.*" $< > $@


.rawDataLoaded:	${rawDataCSVs} sql/createRawDbTables.sql sql/rawDataViews.sql
	bin/load_database



clean:
	-rm work/*
	-rm .rawDbTablesCreated .rawRecentDataLoaded .rawHistoryDataLoaded

# $(filter-out clean_combine_polls.sh,$+)