/*
 -- Combine the cleaned working tables for the three kinds of input data into a single table.
 -- Assign candidate IDs.
 -- Assign place (1st place, 2nd place, etc)
 */
DROP TABLE IF EXISTS _elections.elections CASCADE;
CREATE TABLE _elections.elections AS (
      WITH combined AS (
          SELECT *
            FROM (
                     SELECT *
                       FROM _work.cleaned_preliminary
                      UNION ALL
                     SELECT *
                       FROM _work.cleaned_history
                      UNION ALL
                     SELECT *
                       FROM _work.cleaned_recent
                 ) AS foo
           ORDER BY election_id, prov_code, ed_id
                       ),

           -- Assign each candidate an ID number.
           candidates AS (
               SELECT DISTINCT ON (election_id, prov_code
                   , ed_id, votes, cand_name
                   , cand_raw_party_name) election_id
                                        , prov_code
                                        , ed_id
                                        , row_number()
                                          OVER () AS cand_id
                                        , rank() OVER (PARTITION BY election_id, prov_code, ed_id ORDER BY votes DESC) AS place
                                        , cand_name
                                        , cand_raw_party_name
                 FROM combined
                         )
    SELECT election_id
         , prov_code
         , ed_id
         , ed_name
         , cand_id
         , cand_name
         , cand_raw_party_name
         , party_code
         , elected
         , acclaimed
         , votes
         , place
      FROM combined
           LEFT JOIN candidates USING (election_id, prov_code, ed_id, cand_name, cand_raw_party_name)
                                     )
;


CREATE UNIQUE INDEX elections_pk ON _elections.elections(
                                                         election_id, prov_code, ed_id, cand_id
    );



DROP TABLE _elections.provinces;
CREATE TABLE _elections.provinces AS (
    SELECT prov_code, raw_prov_code AS prov_name
      FROM _work.prov_lookup
     WHERE raw_prov_code !~ '[0-9]+'
     ORDER BY prov_code
                                     );


CREATE UNIQUE INDEX provinces_pk ON _elections.provinces(
                                                         prov_code
    );



/*
A function to generate CSVs in a common format and order.
Pass 0 to get all elections.
*/
DROP FUNCTION _elections.csv(election_id_p INTEGER
                            );
CREATE OR REPLACE FUNCTION _elections.csv(election_id_p INT
                                         )
    RETURNS SETOF _elections.ELECTIONS
    LANGUAGE SQL
AS $$
SELECT *
  FROM _elections.elections
 WHERE election_id = election_id_p
    OR election_id_p = 0
 ORDER BY election_id, prov_code, ed_name, place
$$;



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
                                 'party', party_code,
                                 'rwIncumbent', FALSE,
                                 'rwElected', elected,
                                 'rwVotes', votes)
               ORDER BY election_id, prov_code, ed_id, cand_name
           ) AS json
  FROM _elections.elections
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
  FROM _elections.elections
 WHERE election_id = election_id_p
$$;
