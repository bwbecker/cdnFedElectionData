 

  WITH historicals AS (
      SELECT election_id, count(*) AS raw_count
        FROM _work.cleaned_history
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
                      SELECT DISTINCT election_id, ed_id, cand_party_name, cand_last
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

SELECT *, raw_count - final_count as diff
  FROM raw_counts
       JOIN final_counts USING (election_id)
 ORDER BY election_id