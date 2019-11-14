
\set ON_ERROR_STOP 'on'


/*
A function to generate CSVs in a common format and order.
Pass 0 to get all elections.
*/
DROP FUNCTION IF EXISTS _elections.csv_by_candidate(election_id_p INTEGER);
CREATE OR REPLACE FUNCTION _elections.csv_by_candidate(election_id_p INT)
    RETURNS TABLE (
        election_id         INT,
        election_date       DATE,
        prov_code           TEXT,
        ed_id               INT,
        ed_name             TEXT,
        cand_id             INT,
        cand_name           TEXT,
        cand_raw_party_name TEXT,
        party_id            INT,
        party_name          TEXT,
        party_short_name    TEXT,
        mainstream          BOOLEAN,
        votes               INT,
        acclaimed           BOOLEAN,
        place               INT
    )
    LANGUAGE SQL
AS $$
SELECT election_id
     , election_date
     , prov_code
     , ed_id
     , ed_name
     , cand_id
     , cand_name
     , cand_raw_party_name
     , party_id
     , party_name
     , party_short_name
     , mainstream
     , votes
     , acclaimed
     , place
  FROM _elections.results
       JOIN _elections.parties USING (party_id)
       JOIN _elections.elections USING (election_id)
 WHERE election_id = election_id_p
    OR election_id_p = 0
 ORDER BY election_id, prov_code, ed_name, place
$$;




-- **********************************************************************************************
-- **********************************************************************************************

CREATE OR REPLACE FUNCTION _elections.write_csv_by_candidate(
                                                            )
    RETURNS VOID
    LANGUAGE plpgsql
AS
$$
DECLARE
    rec      RECORD;
    filename TEXT;
BEGIN
    FOR rec IN
        SELECT election_id, format(
                $a$/Users/bwbecker/byron/activism/charterChallenge/cdnFedElectionData/csv_by_cand/election_%s.csv$a$,
                date_part('year', election_date)) AS fname
          FROM _elections.elections
         -- WHERE election_id IN (1, 2)
         UNION
        SELECT 0 AS election_id,
            $a$/Users/bwbecker/byron/activism/charterChallenge/cdnFedElectionData/csv_by_cand/election_all.csv$a$
                AS fname

        LOOP

            EXECUTE 'COPY (SELECT * FROM _elections.csv_by_candidate(' || rec.election_id || ')) TO ' ||
                    quote_literal(rec.fname) || '(FORMAT CSV, HEADER)';

        END LOOP;
END

$$
;


-- **********************************************************************************************
-- **********************************************************************************************
DROP FUNCTION IF EXISTS _elections.candidates_by_riding(election_id_p INT);
CREATE OR REPLACE FUNCTION _elections.candidates_by_riding(election_id_p INT
                                                          )
    RETURNS TABLE (
        prov_code TEXT,
        ed_id   INT,
        parties TEXT[],
        votes   INT[],
        winners TEXT[]
    )
    LANGUAGE SQL
AS
$$
  WITH
/*
  A function that makes one row per riding of an election, with the votes for each mainsteam
  party in a column.  Package them up in arrays so we can have a fixed number of columns in
  the function's return type.
*/

      -- The election we're concerned with, mapping non-mainstream parties to "Other"
      election AS (
          SELECT prov_code,
              ed_id,
              CASE WHEN mainstream THEN party_id ELSE 0 END AS party_id,
              CASE WHEN mainstream THEN party_short_name ELSE 'Other' END AS party_short_name,
              votes
            FROM _elections.results
                 LEFT JOIN _elections.parties USING (party_id)
           WHERE election_id = election_id_p
                  ),
      -- A list of every ed with every mainstream party plus other
      all_eds_and_parties AS (
          SELECT *
            FROM (
                SELECT DISTINCT prov_code, ed_id
                  FROM election
                 ) AS foo
               , (
                SELECT DISTINCT party_id, party_short_name
                  FROM election
                 ) AS bar
                             ),
      -- votes for all mainstream parties and Other in each riding
      riding_results AS (

          SELECT prov_code, ed_id, party_id, party_short_name, sum(votes) AS votes
            FROM all_eds_and_parties
                 LEFT JOIN election USING (prov_code, ed_id, party_id, party_short_name)
           GROUP BY prov_code
                  , ed_id
                  , party_id
                  , party_short_name
           ORDER BY ed_id
                  , party_id
                        )

SELECT prov_code, ed_id,
    array_agg(party_short_name ORDER BY party_short_name) AS parties,
    array_agg(votes::INT ORDER BY party_short_name) AS votes,
    array_agg(party_short_name ORDER BY votes DESC NULLS LAST) AS place
  FROM riding_results
 GROUP BY prov_code, ed_id
 ORDER BY prov_code, ed_id
$$;



-- **********************************************************************************************
-- **********************************************************************************************

CREATE OR REPLACE FUNCTION _elections.csv_by_riding(election_id_p INT
                                                   )
    RETURNS TABLE (
        csv_row TEXT
    )
    LANGUAGE SQL
AS $$
/*
  Doing a pivot table in SQL isn't easy.  We essentially put the pivoted values into arrays
  using candidates_by_riding.  This function then unpacks them into a CSV format.
  It's a pain to use the crosstab function referenced at 
  https://stackoverflow.com/questions/3002499/postgresql-crosstab-query because we need differing
  numbers of columns for different elections -- and SQL function return types need to have a fixed
  number of columns, apparently.
*/
  WITH ridings AS (
      SELECT DISTINCT ON (election_id, prov_code, ed_id) election_id, prov_code, ed_id, ed_name
        FROM _elections.results
            WHERE election_id = election_id_p
                  ),
       info AS (
           SELECT *
             FROM _elections.candidates_by_riding(election_id_p)
               ) (
           SELECT FORMAT('election_id,prov_code,ed_id,ed_name,%s,1st,2nd,3rd', array_to_string(parties, ','))
             FROM info
                 LIMIT 1
                 )
 UNION ALL
(
    SELECT FORMAT('%s,%s,%s,"%s",%s', election_id, prov_code, ed_id, ed_name, array_to_string(votes, ',', '')) ||
           format(',%s,%s,%s', winners[1], winners[2], winners[3])
      FROM info
           LEFT JOIN ridings USING (prov_code, ed_id)
)
$$;


-- **********************************************************************************************
-- **********************************************************************************************
CREATE OR REPLACE FUNCTION _elections.write_csv_by_riding(
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
                $a$/Users/bwbecker/byron/activism/charterChallenge/cdnFedElectionData/csv_by_riding/election_%s.csv$a$,
                date_part('year', election_date)) AS fname
          FROM _elections.elections
             -- WHERE election_id IN (1, 2)

        LOOP

            EXECUTE 'COPY (SELECT * FROM _elections.csv_by_riding(' || rec.election_id || ')) TO ' ||
                    quote_literal(rec.fname) || '(FORMAT TEXT)';

        END LOOP;
END

$$
;





-- **********************************************************************************************
-- **********************************************************************************************

DROP FUNCTION IF EXISTS _elections.election_summary(
                                                   );
CREATE OR REPLACE FUNCTION _elections.election_summary(
                                                      )
    RETURNS TABLE (
        election_id   INT,
        election_date DATE,
        ideologies    TEXT[],
        votes         INT[],
        seats         INT[],
        winners       TEXT[]
    )
    LANGUAGE SQL
AS
$$
  WITH counts AS (
      SELECT election_id
           , ideology_code
           , nullif(sum(votes), 0) AS votes
           , nullif(sum(CASE WHEN place = 1 THEN 1 ELSE 0 END), 0) AS seats
        FROM _elections.results
             JOIN _elections.parties USING (party_id)
       GROUP BY election_id, ideology_code
       ORDER BY election_id, ideology_code
                 ),
       all_elections_and_ideologies AS (
           SELECT *
             FROM (
                 SELECT election_id
                   FROM _elections.elections
                  ) AS foo
                ,
                 (
                     SELECT DISTINCT ideology_code
                       FROM _elections.parties
                 )  AS bar
            ORDER BY election_id, ideology_code
                                       ),
       election_results AS (

           SELECT *
             FROM all_elections_and_ideologies
                  LEFT JOIN counts USING (election_id, ideology_code)
                           )

SELECT election_id
     , election_date
     , array_agg(ideology_code ORDER BY ideology_code) AS ideologies
     , array_agg(votes::INT ORDER BY ideology_code) AS votes
     , array_agg(seats::INT ORDER BY ideology_code) AS seats
     , array_agg(ideology_code ORDER BY seats DESC NULLS LAST) AS winners
  FROM election_results
       JOIN _elections.elections USING (election_id)
 GROUP BY election_id, election_date
 ORDER BY election_id
$$;




-- **********************************************************************************************
-- **********************************************************************************************

CREATE OR REPLACE FUNCTION _elections.csv_by_election(
                                                     )
    RETURNS TABLE (
        csv_row TEXT
    )
    LANGUAGE SQL
AS $$

(
    SELECT format('election_id,election_date,%s,%s,1st,2nd,3rd'
               , array_to_string(ideologies, '_votes,')
               , array_to_string(ideologies, '_seats,')
               )
      FROM _elections.election_summary()
     LIMIT 1
)
 UNION ALL
(
    SELECT format('%s,%s,%s,%s,%s,%s,%s'
               , election_id
               , election_date
               , array_to_string(votes, ',', '')
               , array_to_string(seats, ',', '')
               , winners[1]
               , winners[2]
               , winners[3]
               )
      FROM _elections.election_summary()
     ORDER BY election_id
)

$$;






-- **********************************************************************************************
-- **********************************************************************************************

CREATE OR REPLACE FUNCTION _elections.party_summary(
                                                   )
    RETURNS TABLE (
        party_id         INT,
        party_name       TEXT,
        party_short_name TEXT,
        ideology_code    TEXT,
        mainstream       BOOLEAN,
        first_election   INT,
        last_election    INT,
        num_candidates   INT,
        also_known_as    TEXT[]
    )
    LANGUAGE SQL
AS $$
/*
  Summary statistics for parties for export to a CSV.
*/
  WITH stats
           AS (
          SELECT party_id
               , MIN(election_id) AS first_election
               , max(election_id) AS last_election
               , count(cand_id)::INT AS num_candidates
               , array_agg(DISTINCT cand_raw_party_name) AS also_known_as
            FROM _elections.results
                 JOIN _elections.parties USING (party_id)
                GROUP BY party_id
              )

SELECT *
  FROM _elections.parties
       JOIN stats USING (party_id)
      ORDER BY party_name
$$;





/*

One row per election.

  WITH counts AS (
      SELECT election_id
           , ideology_code
           , sum(votes) AS votes
           , sum(CASE WHEN place = 1 THEN 1 ELSE 0 END) AS seats
        FROM _elections.results
             JOIN _elections.parties USING (party_id)
       GROUP BY election_id, ideology_code
       ORDER BY election_id, ideology_code
                 ),
       all_elections_and_ideologies AS (
           SELECT *
             FROM (
                 SELECT election_id
                   FROM _elections.elections
                  ) AS foo
                ,
                 (
                     SELECT DISTINCT ideology_code
                       FROM _elections.parties
                 )  AS bar
            ORDER BY election_id, ideology_code
                                       ),
       election_results AS (

           SELECT *
             FROM all_elections_and_ideologies
                  LEFT JOIN counts USING (election_id, ideology_code)
                           )

SELECT election_id
     , election_date
     , array_agg(ideology_code ORDER BY ideology_code)
     , array_agg(votes::INT ORDER BY ideology_code)
     , array_agg(seats::INT ORDER BY ideology_code)
  FROM election_results
       JOIN _elections.elections USING (election_id)
 GROUP BY election_id, election_date
 ORDER BY election_id

*/