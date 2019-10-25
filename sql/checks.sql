  WITH historicals AS (
      SELECT election_id, count(*) AS raw_count
        FROM _work.history
       WHERE election_type = 'Gen'
         AND election_id < 39
       GROUP BY election_id
       ORDER BY election_id
                      ),
       preliminarys AS (
           SELECT election_id, count(*) AS raw_count
             FROM _work.cleaned_preliminary
            GROUP BY election_id
            ORDER BY election_id
                       ),
       recents AS (
           SELECT election_id, count(*) AS raw_count
             FROM (
                      SELECT DISTINCT election_id, ed_id, cand_raw_party_name, cand_last
                        FROM _work.recent
                       WHERE NOT poll_void     -- all void polls have 0 votes
                         AND NOT poll_not_held -- all 0 votes
                         AND merge_with IS NULL -- all 0 votes
                  ) AS foo
            GROUP BY election_id
            ORDER BY election_id
                  ),
       raw_counts AS (
           SELECT *
             FROM historicals
            UNION ALL
           SELECT *
             FROM preliminarys
            UNION ALL
           SELECT *
             FROM recents

                     ),
       final_counts AS (
           SELECT election_id, count(*) AS final_count
             FROM _elections.elections
            GROUP BY election_id
                       )

SELECT *
  FROM (
           SELECT *, raw_count - final_count AS diff
             FROM raw_counts
                  JOIN final_counts USING (election_id)
            ORDER BY election_id
       ) AS foo
 WHERE abs(diff) > 0;


/*
Parties properly classified as mainstream.
*/
SELECT *
  FROM (
           SELECT *, round(party_votes / election_votes * 100) AS pct
             FROM (
                      SELECT *
                           , sum(party_votes) OVER (PARTITION BY election_id) AS election_votes
                        FROM (
                                 SELECT election_id
                                      , party_code
                                      , main_stream
                                      , sum(votes) AS party_votes
                                   FROM _elections.elections
                                        JOIN _elections.parties USING (party_code)
                                  GROUP BY election_id, party_code, main_stream
                                  ORDER BY election_id, party_code
                             ) AS foo
                  ) AS foo
       ) AS foo
 WHERE NOT main_stream AND pct >= 5
   AND party_code NOT IN ('Unknown', 'Ind');