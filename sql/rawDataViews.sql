-- Clean the raw_data.history table:
-- Remove by-elections.
-- Remove elections covered by the more recent data formats (39 and above)
-- Handle acclaimed candidates.
-- Normalize parties.
CREATE VIEW raw_data.cleaned_history AS (
      WITH cleaned AS (
          SELECT election
               , prov_code
               , ed_name
               , trim(format('%s, %s', cand_last, cand_first)) AS cand_name
               , party_name
               , cand_elected
               , CASE WHEN cand_votes_raw = 'accl.' THEN NULL ELSE cand_votes_raw::INT END AS cand_votes
               , cand_votes_raw = 'accl.' AS acclaimed
            FROM raw_data.history
                 JOIN raw_data.party_names ON (cand_party_name = raw_name)
                 JOIN raw_data.provinces ON (province = raw_code)
           WHERE election_type = 'Gen'
             AND election < 39
          --ORDER BY election, province, ed_name, election_type, cand_last
                      ),
           dual_mbr_ed AS (
               /*
            Identify dual-member electoral districts.  They're the ones with two winners as identified with the
            dual_mbr_flag.  Give each dual electoral district name a suffix of either -1 or -2.  Partition
            so that each has a winner.
            */
               SELECT election
                    , prov_code
                    , CASE dual_mbr_flag WHEN 1 THEN ed_name
                                         WHEN 2 THEN format('%s-%s', ed_name, ed_suffix)
                   END AS ed_name
                    , cand_name
                    , party_name
                    , cand_elected
                    , cand_votes
                    , acclaimed
                 FROM (
                          SELECT *
                               , count(nullif(cand_elected, FALSE))
                                 OVER (PARTITION BY election, prov_code, ed_name) AS dual_mbr_flag
                               , row_number() OVER (PARTITION BY election, prov_code, ed_name, NOT cand_elected) % 2 +
                                 1 AS ed_suffix
                            FROM cleaned
                      ) AS foo
               --ORDER BY election, prov_code, ed_name, cand_elected
                          ),

           -- Generate an electoral district id for each district
           electoral_districts AS (
               SELECT *, row_number() OVER (PARTITION BY election, prov_code ORDER BY ed_name) AS ed_id
                 FROM (
                          SELECT DISTINCT ON (election, prov_code, ed_name) election, prov_code, ed_name
                            FROM dual_mbr_ed
                      ) AS foo
                                  )

    SELECT election,
        prov_code,
        ed_id,
        ed_name, cand_name, party_name, cand_elected, cand_votes, acclaimed

      FROM dual_mbr_ed
           JOIN electoral_districts USING (election, prov_code, ed_name)
                                        )





CREATE VIEW raw_data.cleaned_recent AS (

      WITH filtered AS (
          SELECT election, ed_id, ed_name,
              trim(format('%s, %s %s', cand_last, cand_first, cand_middle)) AS cand_name,
              cand_party_name,
              cand_incumbent -- ???
               ,
              cand_elected,
              cand_votes
            FROM raw_data.recent
           WHERE NOT poll_void     -- all void polls have 0 votes
             AND NOT poll_not_held -- all 0 votes
             AND merge_with IS NULL -- all 0 votes
                       ),
           by_riding AS (
               SELECT election, ed_id, ed_name, cand_name, cand_party_name, cand_incumbent, cand_elected
                    , sum(cand_votes) AS cand_votes
                 FROM filtered
                GROUP BY election, ed_id, ed_name, cand_name, cand_party_name, cand_incumbent, cand_elected
                        )


    SELECT election,
        prov_code,
        ed_id, ed_name, cand_name,
        party_name, cand_elected, cand_votes, FALSE AS acclaimed
      FROM by_riding
           JOIN raw_data.provinces ON (left(ed_id::TEXT, 2) = raw_code)
           JOIN raw_data.party_names ON (cand_party_name = raw_name)
                                       )
