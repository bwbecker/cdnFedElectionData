
\set ON_ERROR_STOP 'on'


/**
The forllowing is for Byron's simulation software.
*/
CREATE OR REPLACE FUNCTION _elections.json_candidates(election_id_p INT
                                                     ) RETURNS JSON
    LANGUAGE SQL
AS $$
SELECT json_build_object('candidates', json_agg(
        json_build_object('ridingId', ed_id,
                          'name', cand_name,
                          'party', party_short_name,
                          'rwElected', elected,
                          'rwVotes', votes)
        ORDER BY election_id, ed_id, cand_name
    )) AS json
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


DROP FUNCTION IF EXISTS _elections.json_elections();
CREATE OR REPLACE FUNCTION _elections.json_elections(
) RETURNS TABLE(election_id INT, design JSON)
    LANGUAGE SQL
AS $$
WITH pRidings AS
         (SELECT DISTINCT ON (election_id, prov_code, ed_id) election_id,
                                                             prov_code,
                                                             ed_id,
                                                             json_build_object(
                                                                     'ridingName', ed_name,
                                                                     'districtMag', 1,
                                                                     'physicalRidings',
                                                                     json_build_array(json_build_array(ed_id, 100, ed_name))) AS riding_json

          FROM _elections.results
         ),

     regions AS (
         SELECT election_id,
                prov_code,
                json_build_object(
                        'regionName', 'R_' || prov_code,
                        'topUpSeats', 0,
                        'virtualRidings', json_agg(riding_json)) AS region_json
         FROM pRidings
         GROUP BY election_id, prov_code
         ORDER BY election_id, prov_code
     ),

     provs AS (SELECT election_id,
                      json_agg(prov_json) AS provinces_json
               FROM (SELECT election_id,
                            prov_code,
                            json_build_object(
                                    'prov', prov_code,
                                    'regions', json_build_array(region_json)
                                ) AS prov_json
                     FROM regions
                     ORDER BY election_id, prov_code
                    ) AS foo
               GROUP BY election_id
     ),

     -- Find all those elections that have the same riding structure.  Group them together as the same
     -- design.  Json doesn't have a native comparison function, so cast to a string to do it.  Yuck.
     sameStructure AS (
         SELECT min(election_id)               AS election_id,
                min(election_date)             AS first_election,
                max(election_date)             AS last_election,
                json_agg(json_build_object('electionId', election_id, 
                                           'electionDate', election_date,
                                           'candidates', 'conf/cand/ca-cand-' || to_char(election_id, 'fm000') || '.conf'
                                           )
                         ORDER BY election_id) AS elections
         FROM provs
                  JOIN _elections.elections USING (election_id)
         GROUP BY provinces_json::TEXT
     )

SELECT election_id,
       json_build_object(
               'country', 'Canada',
               'id', 'ca-sglMbr-' || to_char(election_id, 'fm000'),
               'description', format('<div><p>Single member plurality for Canada''s elections between %s and %s.</p></div>', first_election, last_election),
               'elections', elections,
               'numPhysicalRidings', (SELECT count(DISTINCT ed_id)
                              FROM _elections.results
                              WHERE results.election_id = sameStructure.election_id),
               'provinces', provinces_json) AS json
FROM sameStructure
         JOIN provs USING (election_id)
         JOIN _elections.elections USING (election_id)
ORDER BY election_id
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
                  $a$/Users/bwbecker/byron/activism/pr_recent/cdnFedElectionData/json_work/ca-cand-%s.json$a$,
                  to_char(election_id, 'fm000')) AS cand_fname,
                format(
                  $a$/Users/bwbecker/byron/activism/pr_recent/cdnFedElectionData/json_work/ca-ridings-%s.json$a$,
                  to_char(election_id, 'fm000')) AS riding_fname,
                format(
                  $a$/Users/bwbecker/byron/activism/pr_recent/cdnFedElectionData/json_work/ca-sglMbr-%s.json$a$,
                  to_char(election_id, 'fm000')) AS election_fname
          FROM _elections.elections
          --WHERE election_id IN (1, 2)

    LOOP

        EXECUTE 'COPY (SELECT * FROM _elections.json_candidates(' || rec.election_id || ')) TO ' ||
                quote_literal(rec.cand_fname) || '(FORMAT TEXT)';
        EXECUTE 'COPY (SELECT * FROM _elections.json_ridings(' || rec.election_id || ')) TO ' ||
                quote_literal(rec.riding_fname) || '(FORMAT TEXT)';

    END LOOP;

    FOR rec IN
        SELECT  election_id,
                format(
                  $a$/Users/bwbecker/byron/activism/pr_recent/cdnFedElectionData/json_work/ca-sglMbr-%s.json$a$,
                  to_char(election_id, 'fm000')) AS election_fname,
                design
        FROM _elections.json_elections()

    LOOP
        EXECUTE format('COPY (SELECT design FROM _elections.json_elections() 
                             WHERE election_id = %s) TO %s (FORMAT TEXT)', 
                             rec.election_id, 
                             quote_literal(rec.election_fname));

    END LOOP;

END

$$
;

