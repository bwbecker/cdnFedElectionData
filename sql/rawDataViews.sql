-- Clean the _work.history table:
-- Remove by-elections.
-- Remove elections covered by the more recent data formats (39 and above)
-- Handle acclaimed candidates.
-- Normalize parties.
DROP VIEW IF EXISTS _work.cleaned_history;
CREATE VIEW _work.cleaned_history AS (
      WITH cleaned AS (
          SELECT election_id
               , prov_code
               , ed_name
               , trim(format('%s, %s', cand_last, cand_first)) AS cand_name
               , cand_party_name AS cand_raw_party_name
               , party_name AS cand_party_name
               , elected
               , CASE WHEN votes_raw = 'accl.' THEN NULL ELSE votes_raw::INT END AS votes
               , votes_raw = 'accl.' AS acclaimed
            FROM _work.history
                 JOIN _work.party_name_lookup ON (cand_party_name = raw_name)
                 JOIN _work.prov_lookup ON (province = raw_code)
           WHERE election_type = 'Gen'
             AND election_id < 39
          --ORDER BY election_id, province, ed_name, election_type, cand_last
                      ),
           dual_mbr_ed AS (
               /*
            Identify dual-member electoral districts.  They're the ones with two winners as identified with the
            dual_mbr_flag.  Give each dual electoral district name a suffix of either -1 or -2.  Partition
            so that each has a winner.
            */
               SELECT election_id
                    , prov_code
                    , CASE dual_mbr_flag WHEN 1 THEN ed_name
                                         WHEN 2 THEN format('%s-%s', ed_name, ed_suffix)
                   END AS ed_name
                    , cand_name
                    , cand_raw_party_name
                    , cand_party_name
                    , elected
                    , votes
                    , acclaimed
                 FROM (
                          SELECT *
                               , count(nullif(elected, FALSE))
                                 OVER (PARTITION BY election_id, prov_code, ed_name) AS dual_mbr_flag
                               , row_number() OVER (PARTITION BY election_id, prov_code, ed_name, NOT elected) %
                                 2 +
                                 1 AS ed_suffix
                            FROM cleaned
                      ) AS foo
               --ORDER BY election_id, prov_code, ed_name, elected
                          ),

           -- Generate an electoral district id for each district
           electoral_districts AS (
               SELECT *, row_number() OVER (PARTITION BY election_id, prov_code ORDER BY ed_name) AS ed_id
                 FROM (
                          SELECT DISTINCT ON (election_id, prov_code, ed_name) election_id, prov_code, ed_name
                            FROM dual_mbr_ed
                      ) AS foo
                                  )

    SELECT election_id,
        prov_code,
        ed_id,
        ed_name, cand_name, cand_raw_party_name, cand_party_name, elected, votes, acclaimed

      FROM dual_mbr_ed
           JOIN electoral_districts USING (election_id, prov_code, ed_name)
                                        );


DROP VIEW IF EXISTS _work.cleaned_recent;
CREATE VIEW _work.cleaned_recent AS (

      WITH filtered AS (
          SELECT election_id, ed_id, ed_name,
              trim(format('%s, %s %s', cand_last, cand_first, cand_middle)) AS cand_name,
              cand_party_name,
              cand_incumbent -- ???
               ,
              elected,
              votes
            FROM _work.recent
           WHERE NOT poll_void     -- all void polls have 0 votes
             AND NOT poll_not_held -- all 0 votes
             AND merge_with IS NULL -- all 0 votes
                       ),
           by_riding AS (
               SELECT election_id, ed_id, ed_name, cand_name, cand_party_name, cand_incumbent, elected
                    , sum(votes) AS votes
                 FROM filtered
                GROUP BY election_id, ed_id, ed_name, cand_name, cand_party_name, cand_incumbent, elected
                        )


    SELECT election_id,
        prov_code,
        ed_id, ed_name, cand_name
         , cand_party_name AS cand_raw_party_name
         , party_name AS cand_party_name
         , elected, votes, FALSE AS acclaimed
      FROM by_riding
           JOIN _work.prov_lookup ON (left(ed_id::TEXT, 2) = raw_code)
           JOIN _work.party_name_lookup ON (cand_party_name = raw_name)
                                       );


DROP VIEW IF EXISTS _work.cleaned_preliminary;
CREATE VIEW _work.cleaned_preliminary AS (
    SELECT 43 AS election_id
         , prov_code
         , ed_id
         , ed_name
         , trim(format('%s, %s %s', cand_last, cand_first, cand_middle)) AS cand_name
         , cand_party_name AS cand_raw_party_name
         , party_name AS cand_party_name
         , (votes = (max(votes) OVER (PARTITION BY ed_id))) AS elected
         , votes
         , FALSE AS acclaimed
      FROM _work.preliminary
           LEFT JOIN _work.party_name_lookup ON (cand_party_name = raw_name)
           LEFT JOIN _work.prov_lookup ON (left(ed_id::TEXT, 2) = raw_code)
                                            );