
\set ON_ERROR_STOP 'on'


/**
The forllowing is for Byron's simulation software.
*/
CREATE OR REPLACE FUNCTION _elections.json_candidates(election_id_p INT
                                                     ) RETURNS JSON
    LANGUAGE SQL
AS $$
SELECT json_agg(
               json_build_object('ridingId', ed_id,
                                 'name', cand_name,
                                 'party', party_short_name,
                                 'rwElected', elected,
                                 'rwVotes', votes)
               ORDER BY election_id, ed_id, cand_name
           ) AS json
  FROM _elections.results
       JOIN _elections.parties USING (party_id)
 WHERE election_id = election_id_p
$$;


CREATE OR REPLACE FUNCTION _elections.json_ridings(election_id_p INT
                                                  ) RETURNS JSON
    LANGUAGE SQL
AS $$
SELECT json_agg(
               json_build_object('ridingId', ed_id,
                                 'prov', prov_code,
                                 'name', ed_name,
                                 'pop', 0,
                                 'area', 0
                   )
               ORDER BY election_id, prov_code, ed_id
           ) AS json
  FROM (
           SELECT DISTINCT election_id, prov_code, ed_id, ed_name
             FROM _elections.results
            WHERE election_id = election_id_p
       ) AS foo
$$;


-- **********************************************************************************************
-- **********************************************************************************************
CREATE OR REPLACE FUNCTION _elections.write_json(
                                                         )
    RETURNS VOID
    LANGUAGE plpgsql
AS
$$
/*
  Write a CSV file formatted one riding per row with the votes for each party in columns.
*/
DECLARE
    rec      RECORD;
    filename TEXT;
BEGIN
    FOR rec IN
        SELECT election_id, format(
                  $a$/Users/bwbecker/byron/activism/pr_recent/cdnFedElectionData/json_work/candidates-%s.json$a$,
                  date_part('year', election_date)) AS cand_fname,
                format(
                  $a$/Users/bwbecker/byron/activism/pr_recent/cdnFedElectionData/json_work/ridings-%s.json$a$,
                  date_part('year', election_date)) AS riding_fname
          FROM _elections.elections
          --WHERE election_id IN (1, 2)

        LOOP

            EXECUTE 'COPY (SELECT * FROM _elections.json_candidates(' || rec.election_id || ')) TO ' ||
                    quote_literal(rec.cand_fname) || '(FORMAT TEXT)';
            EXECUTE 'COPY (SELECT * FROM _elections.json_ridings(' || rec.election_id || ')) TO ' ||
                    quote_literal(rec.riding_fname) || '(FORMAT TEXT)';

        END LOOP;
END

$$
;

