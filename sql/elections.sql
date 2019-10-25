
DROP TABLE IF EXISTS _elections.elections;
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
                   , cand_party_name) election_id
                                    , prov_code, ed_id
                                    ,
                           row_number()
                           OVER () AS cand_id
                                    , rank() OVER (PARTITION BY election_id, ed_id ORDER BY votes DESC) AS place
                                    , cand_name
                                    , cand_party_name
                 FROM combined

                         )
    SELECT election_id, prov_code, ed_id, ed_name, cand_id, cand_name, cand_party_name, cand_raw_party_name
         , elected
         , acclaimed, votes, place
      FROM combined
           LEFT JOIN candidates USING (election_id, prov_code, ed_id, cand_name, cand_party_name)
                                   )
;


CREATE UNIQUE INDEX elections_pk ON _elections.elections(
                                                       election_id, prov_code, ed_id, cand_id
    );



DROP TABLE _elections.provinces;
CREATE TABLE _elections.provinces AS (
    SELECT prov_code, raw_code AS prov_name
      FROM _work.prov_lookup
     WHERE raw_code !~ '[0-9]+'
     ORDER BY prov_code
                                     );


CREATE UNIQUE INDEX provinces_pk ON _elections.provinces(
                                                         prov_code
    );