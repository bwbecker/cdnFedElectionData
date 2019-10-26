
\set ON_ERROR_STOP 'on'


DROP TABLE IF EXISTS _elections.elections CASCADE;
CREATE TABLE _elections.elections (
    election_id   INT NOT NULL,
    election_date DATE,

    PRIMARY KEY (election_id)
);


INSERT INTO _elections.elections
VALUES (1, '1867-08-07'),
       (2, '1872-07-20'),
       (3, '1874-01-22'),
       (4, '1878-09-17'),
       (5, '1882-06-20'),
       (6, '1887-02-22'),
       (7, '1891-03-05'),
       (8, '1896-06-23'),
       (9, '1900-11-07'),
       (10, '1904-11-03'),
       (11, '1908-10-26'),
       (12, '1911-09-21'),
       (13, '1917-12-17'),
       (14, '1921-12-06'),
       (15, '1925-10-29'),
       (16, '1926-09-14'),
       (17, '1930-07-28'),
       (18, '1935-10-14'),
       (19, '1940-03-26'),
       (20, '1945-06-11'),
       (21, '1949-06-27'),
       (22, '1953-08-10'),
       (23, '1957-06-10'),
       (24, '1958-03-31'),
       (25, '1962-06-18'),
       (26, '1963-04-08'),
       (27, '1965-11-08'),
       (28, '1968-06-25'),
       (29, '1972-10-30'),
       (30, '1974-07-08'),
       (31, '1979-05-22'),
       (32, '1980-02-18'),
       (33, '1984-09-04'),
       (34, '1988-11-21'),
       (35, '1993-10-25'),
       (36, '1997-06-02'),
       (37, '2000-11-27'),
       (38, '2004-06-28'),
       (39, '2006-01-23'),
       (40, '2008-10-14'),
       (41, '2011-05-02'),
       (42, '2015-10-19'),
       (43, '2019-10-21');





DROP TABLE IF EXISTS _elections.provinces;
CREATE TABLE _elections.provinces AS (
    SELECT prov_code, raw_prov_code AS prov_name
      FROM _work.prov_lookup
     WHERE raw_prov_code !~ '[0-9]+'
     ORDER BY prov_code
                                     );


CREATE UNIQUE INDEX provinces_pk ON _elections.provinces(
                                                         prov_code
    );

DROP TABLE IF EXISTS _elections.parties;
CREATE TABLE _elections.parties AS (
      WITH ms_parties AS (
          -- This seems like way more work than should be necessary just to calculate whether
          -- a party attained 5% of the vote in some election.
          SELECT DISTINCT ON (party_id) party_id
                                      , pct > 5 AND (party_short_name NOT IN ('Ind', 'Unknown')) AS mainstream
            FROM (
                SELECT *, round(party_votes / election_votes * 100) AS pct
                  FROM (
                           SELECT election_id
                                , party_id
                                , party_short_name
                                , party_votes
                                , sum(party_votes) OVER (PARTITION BY election_id) AS election_votes
                             FROM (
                                      SELECT election_id
                                           , party_id
                                           , party_short_name
                                           , sum(votes) AS party_votes
                                        FROM _work.  combined
                                            WHERE NOT acclaimed
                                            GROUP BY election_id
                                           ,         party_id
                                           ,         party_short_name
                                  ) AS foo
                       ) AS foo
                 ) AS    foo
                ORDER BY party_id
               ,         pct DESC
                         )

    SELECT *
      FROM _work.parties
           JOIN ms_parties USING (party_id)
                                   );
CREATE UNIQUE INDEX parties_pk ON _elections.parties(party_id);



/*
 -- Assign candidate IDs.
 -- Assign place (1st place, 2nd place, etc
 */
DROP TABLE IF EXISTS _elections.results CASCADE;
CREATE TABLE _elections.results AS (
      WITH

          -- Assign each candidate an ID number.
          candidates AS (
              SELECT DISTINCT ON (election_id, prov_code
                  , ed_id, votes, cand_name
                  , cand_raw_party_name) election_id
                                       , prov_code
                                       , ed_id
                                       , row_number()
                                         OVER () AS cand_id
                                       ,
                          rank() OVER (PARTITION BY election_id, prov_code, ed_id ORDER BY votes DESC) AS place
                                       , cand_name
                                       , cand_raw_party_name
                FROM _work.combined
                        )
    SELECT election_id::INT
         , prov_code
         , ed_id::INT
         , ed_name
         , cand_id::INT
         , cand_name
         , cand_raw_party_name
         , party_id::INT
         , elected
         , acclaimed
         , votes::INT
         , place::INT
      FROM _work.combined
           LEFT JOIN candidates USING (election_id, prov_code, ed_id, cand_name, cand_raw_party_name)
                                     )
;


CREATE UNIQUE INDEX results_pk ON _elections.results(
                                                         election_id, prov_code, ed_id, cand_id
    );


