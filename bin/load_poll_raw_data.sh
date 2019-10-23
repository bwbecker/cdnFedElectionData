#!/bin/bash

psql="psql service=esim"


for i in 39 40 41 42
do
	echo "Combining $i"
	./bin/combine_files.sh $i pollresults_resultatsbureau_canada_$i/pollresults_resultatsbureau*.csv
done

echo "Loading DB"

${psql} <<END
	
	CREATE SCHEMA raw_data;
	DROP TABLE raw_data.recent;
	CREATE TABLE raw_data.recent (
		election INT NOT NULL,
		ed_id	INT NOT NULL,
		ed_name TEXT NOT NULL,
		ed_name_fr TEXT NOT NULL,
		poll_id TEXT NOT NULL,
		poll_name TEXT NOT NULL,
		poll_void BOOLEAN NOT NULL,
		poll_not_held BOOLEAN NOT NULL,
		merge_with TEXT,
		ballots_rejected INT NOT NULL,
		num_electors INT NOT NULL,
		cand_last TEXT NOT NULL,
		cand_middle TEXT NOT NULL,
		cand_first TEXT NOT NULL,
		cand_party_name TEXT NOT NULL,
		cand_party_fr TEXT NOT NULL,
		cand_incumbent BOOLEAN NOT NULL,
		cand_elected BOOLEAN NOT NULL,
		cand_votes INT NOT NULL,

		PRIMARY KEY (election, ed_id, poll_id, cand_last, cand_party_name)
	);

	\copy raw_data.recent from 'canada_39.csv' (FORMAT csv);
	\copy raw_data.recent from 'canada_40.csv' (FORMAT csv);
	\copy raw_data.recent from 'canada_41.csv' (FORMAT csv);
	\copy raw_data.recent from 'canada_42.csv' (FORMAT csv);
END


