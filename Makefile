

raw39 = $(wildcard rawData/election_39/pollresults*)
raw40 = $(wildcard rawData/election_40/pollresults*)
raw41 = $(wildcard rawData/election_41/pollresults*)
raw42 = $(wildcard rawData/election_42/pollresults*)

recentElections := 39 40 41 42
recentCSVs = $(foreach e,$(recentElections),work/election_$(e).csv)
rawDataCSVs = ${recentCSVs} work/history.csv work/preliminary.csv 

preliminary = rawData/preliminary_43.csv

election_nums := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 \
	21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43
csvs = $(foreach e,${election_nums},csv/election_${e}.csv) \
		csv/elections.csv \
		csv/parties.csv \
		csv/provinces.csv


all:	${csvs}

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


.rawDataLoaded:	${rawDataCSVs} sql/createRawDbTables.sql sql/rawDataViews.sql sql/elections.sql sql/checks.sql
	bin/load_database
	touch .rawDataLoaded


csv/election_%.csv: .rawDataLoaded
	${PSQL} -c "\copy (select * from _elections.csv($*)) to $@ (FORMAT csv, header)"

csv/elections.csv: .rawDataLoaded
	${PSQL} -c "\copy (select * from _elections.csv(0)) to $@ (FORMAT csv, header)"

csv/parties.csv: .rawDataLoaded
	${PSQL} -c "\copy (select * from _elections.parties order by party_name) to $@ (FORMAT csv, header)"

csv/provinces.csv: .rawDataLoaded
	${PSQL} -c "\copy (select * from _elections.provinces order by prov_name) to $@ (FORMAT csv, header)"



clean:
	-rm work/*
	-rm .rawDataLoaded
	-rm csv/*

# $(filter-out clean_combine_polls.sh,$+)