#!/bin/bash

psql="psql service=esim"


sed -e 's/\xe0/à/g' \
		-e 's/\xe1/á/g' \
		-e 's/\xe2/â/g' \
		-e 's/\xe7/ç/g' \
		-e 's/\xe8/è/g' \
		-e 's/\xe9/é/g' \
		-e 's/\xea/ê/g' \
		-e 's/\xeb/ë/g' \
		-e 's/\xee/î/g' \
		-e 's/\xef/ï/g' \
		-e 's/\xc7/Ç/g' \
		-e 's/\xc8/È/g' \
		-e 's/\xc9/É/g' \
		-e 's/\xc2/Â/g' \
		-e 's/\xca/Ê/g' \
		-e 's/\xcb/Ë/g' \
		-e 's/\xce/Î/g' \
		-e 's/\xd4/Ô/g' \
		-e 's/\xf4/ô/g' \
		-e 's/\xfc/ü/g' \
		-e 's/\xcf/-/g' \
		-e 's/\x81/-/g' \
		-e 's/\x92/-/g' \
		-e 's/NULL//g' \
History_Federal_Electoral_Ridings.csv > history.csv

${psql} <<END
	
	DROP TABLE raw_data.history;
	CREATE TABLE raw_data.history (
		election_date TEXT NOT NULL,
		election_type TEXT NOT NULL,
		election INT NOT NULL,
		province TEXT NOT NULL,
		ed_name TEXT NOT NULL,
		cand_last TEXT NOT NULL,
		cand_first TEXT,
		cand_gender TEXT,
		cand_occupation TEXT,
		cand_party_name TEXT NOT NULL,
		cand_votes_raw TEXT,
		cand_votes_pct REAL,
		cand_elected BOOLEAN NOT NULL

	);

	\copy raw_data.history from 'history.csv' \
	(FORMAT csv, HEADER);

	ALTER TABLE raw_data.history
	ADD COLUMN cand_votes INT;

	UPDATE raw_data.history
	SET cand_votes = cand_votes_raw::INT
	WHERE cand_votes_raw <> 'accl.';
END


