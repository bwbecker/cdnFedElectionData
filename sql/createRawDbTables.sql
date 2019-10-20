
-- Create the DB tables to hold the raw data.


CREATE SCHEMA IF NOT EXISTS raw_data;

DROP TABLE IF EXISTS raw_data.recent;
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
	cand_votes INT NOT NULL
);


DROP TABLE IF EXISTS raw_data.history;
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
