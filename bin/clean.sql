


/*
Clean the 39-42nd elections
*/

SELECT election
     , ed_id
     , ed_name
     , poll_id
     , poll_name
     , ballots_rejected
     , num_electors
     , trim(format('%s, %s %s', cand_last, cand_first, cand_middle)) AS cand_name
     , party_code
     , party_name
     , cand_incumbent
     , cand_elected
     , cand_votes
  FROM raw_data.recent
       JOIN raw_data.parties ON (cand_party_name = raw_name)
       JOIN raw_data.party USING (party_code)

 WHERE merge_with = ''   -- All instances of non-blank merge_with have 0 votes
   AND NOT poll_void     -- All instances where poll_void is true have 0 votes
   AND NOT poll_not_held -- All instances where poll_not_held is true have 0 votes
 ORDER BY election, ed_id