

raw39 = $(wildcard rawData/election_39/pollresults*)
raw40 = $(wildcard rawData/election_40/pollresults*)
raw41 = $(wildcard rawData/election_41/pollresults*)
raw42 = $(wildcard rawData/election_42/pollresults*)
raw43 = $(wildcard rawData/election_43/pollresults*)

recentElections := 39 40 41 42 43
recentCSVs = $(foreach e,$(recentElections),work/election_$(e).csv)
rawDataCSVs = ${recentCSVs} work/history.csv #work/preliminary.csv

#preliminary = rawData/preliminary_43.csv

election_nums := 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 \
	21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43
csvs = $(foreach e,${election_nums},csv/by_riding_${e}.csv) \
		csv/elections.csv \
		csv/parties.csv \
		csv/provinces.csv

all:	csv_by_cand/election-2019.csv csv_by_riding/election-2019.csv json/ca-cand-042.json \
		csv_other/party_summary.csv csv_other/all_elections.csv

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

# work/preliminary.csv: ${preliminary}
# 	grep -E -e "[0-9]{5}\t.*" $< > $@


.rawDataLoaded:	${rawDataCSVs} sql/createRawDbTables.sql
	${PSQL} -c "CREATE SCHEMA IF NOT EXISTS _work;" \
			-c "CREATE SCHEMA IF NOT EXISTS _elections;"
	echo "\n\nCreating raw DB tables"
	${PSQL} -f sql/createRawDbTables.sql


	# Load historical data
	echo "\n\nLoading raw data from work/history.csv"
	${PSQL} -c "TRUNCATE _work.history" \
			-c "\copy _work.history from work/history.csv (FORMAT csv)"

	# Load recent data
	${PSQL} -c "TRUNCATE _work.recent"
	${PSQL} -c "\copy _work.recent from 'work/election_39.csv' (FORMAT csv)"
	${PSQL} -c "\copy _work.recent from 'work/election_40.csv' (FORMAT csv)"
	${PSQL} -c "\copy _work.recent from 'work/election_41.csv' (FORMAT csv)"
	${PSQL} -c "\copy _work.recent from 'work/election_42.csv' (FORMAT csv)"
	${PSQL} -c "\copy _work.recent from 'work/election_43.csv' (FORMAT csv)"

	echo "Updating _work.recent.merge_with"
	${PSQL} -c "UPDATE _work.recent SET merge_with = NULL WHERE merge_with = ''"


# 	# Load Preliminary data
# 	echo "Loading raw data from work/preliminary.csv"
# 	${PSQL} -c "TRUNCATE _work.preliminary" \
# 			-c "\copy _work.preliminary from work/preliminary.csv"

	touch .rawDataLoaded



.buildElections: .rawDataLoaded sql/rawDataViews.sql sql/elections.sql sql/checks.sql
	echo "Creating raw data views"
	${PSQL} -f sql/rawDataViews.sql
	echo "Creating consolidated elections table"
	${PSQL} -f sql/elections.sql
	echo "Diffs should be zero"
	${PSQL} -f sql/checks.sql	
	touch .buildElections

# Makes all the other by-candidate CSVs, too
csv_by_cand/election-2019.csv: sql/export_csv.sql .buildElections .rawDataLoaded
	- mkdir csv_by_cand
	${PSQL} -f sql/export_csv.sql
	echo "Exporting by candidate CSV files"
	${PSQL} -c "SELECT _elections.write_csv_by_candidate()"

# Makes all the other by-riding CSVs, too
csv_by_riding/election-2019.csv: sql/export_csv.sql .buildElections .rawDataLoaded
	- mkdir csv_by_riding
	${PSQL} -f sql/export_csv.sql
	echo "Exporting by riding CSV files"
	${PSQL} -c "SELECT _elections.write_csv_by_riding()"

csv_other/all_elections.csv:
csv_other/party_summary.csv: sql/export_csv.sql .buildElections .rawDataLoaded
	- mkdir csv_other
	${PSQL} -f sql/export_csv.sql
	echo "Exporting by party summary CSV files"
	${PSQL} -c "\copy (SELECT * FROM _elections.party_summary()) to csv_other/party_summary.csv (FORMAT CSV, HEADER)"
	${PSQL} -c "\copy (SELECT * FROM _elections.csv_by_election()) to csv_other/all_elections.csv (FORMAT TEXT)"

# Use one typical file to trigger all of them
json/ca-cand-042.json: sql/export_json.sql .buildElections .rawDataLoaded
	- mkdir json json_work
	- rm json_work/*
	${PSQL} -f sql/export_json.sql
	echo "Exporting by JSON files"
	${PSQL} -c "SELECT _elections.write_json()"
	echo "Reformatting json"
	bin/reformat_json


# csv/election_%.csv: .rawDataLoaded
# 	${PSQL} -c "\copy (select * from _elections.csv($*)) to $@ (FORMAT csv, header)"

# csv/elections.csv: .rawDataLoaded
# 	${PSQL} -c "\copy (select * from _elections.csv(0)) to $@ (FORMAT csv, header)"

# csv/parties.csv: .rawDataLoaded
# 	${PSQL} -c "\copy (select * from _elections.parties order by party_name) to $@ (FORMAT csv, header)"

# csv/provinces.csv: .rawDataLoaded
# 	${PSQL} -c "\copy (select * from _elections.provinces order by prov_name) to $@ (FORMAT csv, header)"

# json/candidates-%.json:  .rawDataLoaded
# 	${PSQL} -c "\copy (SELECT * FROM _elections.json_candidates($*)) to stdout" | json_reformat > $@

# json/ridings-%.json: .rawDataLoaded
# 	${PSQL} -c "\copy (SELECT * FROM _elections.json_ridings($*)) to stdout" | json_reformat > $@

clean:
	-rm work/*
	-rm .rawDataLoaded
	-rm csv*/*
	-rm json/* json_work/*

# $(filter-out clean_combine_polls.sh,$+)