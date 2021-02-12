/*
 Normalize electoral district names.

 Start by mapping the original name to UPPER(normalize(ed_name)) to ed_lookup -- the name we'll
 use for lookup purposes.  The results were then reviewed manually to come up with the following
 table of additional mappings.
 */


DROP TABLE IF EXISTS _work.ed_lookup CASCADE;
CREATE TABLE _work.ed_lookup
(
    prov_code    TEXT NOT NULL,
    ed_lookup    TEXT NOT NULL,
    pref_ed_name TEXT NOT NULL,

    PRIMARY KEY (prov_code, ed_lookup)
);
INSERT INTO _work.ed_lookup (prov_code, ed_lookup, pref_ed_name)
VALUES ('QC', 'THREE RIVERS', 'Trois-Rivières'),
       ('QC', 'TROIS-RIVIÈRES', 'Trois-Rivières'),
       ('QC', 'TROIS-RIVIÈRES MÉTROPOLITAIN', 'Trois-Rivières'),
       ('QC', 'THREE RIVERS AND ST. MAURICE', 'THREE RIVERS--ST. MAURICE'),
       ('QC', 'VAUDREUIL-SOULANGES', 'Vaudreuil--Soulanges'),
       ('QC', 'VERCHÈRES--LES PATRIOTES', 'Verchères--Les Patriotes'),
       ('QC', 'ABITIBI--TÉMISCAMINGUE', 'Abitibi--Témiscamingue'),
       ('QC', 'BAS-RICHELIEU--NICOLET--BÉCANCOUR', 'Bas-Richelieu--Nicolet--Bécancour'),
       ('QC', 'BERTHIER--MASKINONGÉ', 'Berthier--Maskinongé'),
       ('QC', 'GASPéSIE--LES ÎLES-DE-LA-MADELEINE', 'Gaspésie--Îles-de-la-Madeleine'),
       ('QC', 'GASPÉSIE--ÎLES-DE-LA-MADELEINE', 'Gaspésie--Îles-de-la-Madeleine'),
       ('QC', 'HONORÉ-MERCIER', 'Honoré-Mercier'),
       ('QC', 'JONQUIÈRE', 'Jonquière'),
       ('QC', 'JONQUIÈRE--ALMA', 'Jonquière--Alma'),
       ('QC', 'LOUIS-HÉBERT', 'Louis-Hébert'),
       ('QC', 'LÉVIS--BELLECHASSE', 'Lévis--Bellechasse'),
       ('QC', 'MARC-AURÈLE-FORTIN', 'Marc-Aurèle-Fortin'),
       ('QC', 'MÉGANTIC--L''ÉRABLE', 'Mégantic--L''Érable'),
       ('QC', 'NOTRE-DAME-DE-GRÂCE--LACHINE', 'Notre-Dame-de-Grâce--Lachine'),
       ('QC', 'QUÉBEC EAST', 'QUÉBEC-EST'),
       ('QC', 'QUÉBEC', 'Québec'),
       ('QC', 'RIVIÈRE-DES-MILLE-ÎLES', 'Rivière-des-Mille-Îles'),
       ('QC', 'RIVIÈRE-DU-NORD', 'Rivière-du-Nord'),
       ('QC', 'ROSEMONT--PETITE-PATRIE', 'Rosemont--La Petite-Patrie'),
       ('QC', 'ST. ANTOINE--WESTMOUNT', 'SAINT-ANTOINE--WESTMOUNT'),
       ('QC', 'ST-DENIS', 'SAINT-DENIS'),
       ('QC', 'ST. DENIS', 'SAINT-DENIS'),
       ('QC', 'SAINT MAURICE', 'SAINT-MAURICE'),
       ('QC', 'ST. MARY', 'SAINTE-MARIE'),
       ('QC', 'SHERBROOKE (TOWN OF)', 'Sherbrooke'),
       ('QC', 'ST-HENRI', 'ST. HENRI'),
       ('QC', 'ST. HENRY', 'ST. HENRI'),
       ('QC', 'ST. HYACINTHE--BAGOT', 'Saint-Hyacinthe--Bagot'),
       ('ON', 'BRANTFORD CITY', 'BRANTFORD'),
       ('ON', 'LEEDS-GRENVILLE-THOUSAND ISLANDS AND RIDEAU LAKES',
        'Leeds--Grenville--Thousand Islands and Rideau Lakes'),
       ('ON', 'OTTAWA--ORLÉANS', 'Ottawa--Orléans'),
       ('BC', 'VICTORIA CITY', 'Victoria'),
       ('AB', 'ATHABASKA', 'ATHABASCA'),
       ('AB', 'CALGARY--NOSE HILL', 'Calgary Nose Hill'),
       ('AB', 'EDMONTON--STRATHCONA', 'Edmonton Strathcona'),
       ('SK', 'REGINA CITY', 'REGINA'),
       ('SK', 'SASKATOON CITY', 'SASKATOON'),
       ('MB', 'WINNIPEG TRANSCONA', 'WINNIPEG--TRANSCONA'),
       ('NB', 'BEAUSÉJOUR', 'Beauséjour'),
       ('NB', 'FUNDY', 'Fundy Royal'),
       ('NB', 'FUNDY--ROYAL', 'Fundy Royal'),
       ('NB', 'SOUTH SHORE--ST. MARGARET''S', 'South Shore--St. Margarets'),
       ('NB', 'SOUTH WESTERN NOVA', 'SOUTH WEST NOVA')
;

DROP MATERIALIZED VIEW IF EXISTS _work.ed_names CASCADE;
CREATE MATERIALIZED VIEW _work.ed_names AS
(
WITH records AS (
    SELECT prov_code, UPPER(normalize(ed_name)) AS ed_lookup, ed_name, election_id
    FROM _work.combined
    --WHERE prov_code not in ('MB', 'SK', 'AB', 'BC', 'ON', 'QC')
),
     normalized_pairs AS (
         SELECT DISTINCT ON (prov_code, ed_lookup) prov_code, ed_lookup, ed_name
         FROM (
                  SELECT DISTINCT prov_code, ed_lookup, ed_name
                  FROM records
              ) AS foo
         ORDER BY prov_code, ed_lookup, ed_name DESC
     ),
     appeared_in_elections AS (
         SELECT prov_code,
                ed_lookup,
                ARRAY_AGG(DISTINCT election_id ORDER BY election_id) AS elections
         FROM records
         GROUP BY prov_code, ed_lookup
     ),
     canonical AS (
         SELECT prov_code,
                ed_lookup,
                ed_name,
                elections,
                COALESCE(pref_ed_name, ed_name) AS ed_name_canonical
         FROM normalized_pairs
                  JOIN appeared_in_elections USING (prov_code, ed_lookup)
                  LEFT JOIN _work.ed_lookup USING (prov_code, ed_lookup)
         ORDER BY prov_code, ed_lookup
     )

SELECT *
FROM canonical
    );

REFRESH MATERIALIZED VIEW _work.ed_names;


/*
 Assign the IDs.  We want these to be stable in the face of redistricting, so
 we order them by the first election in which they appear.  That way new ridings
 will appear at the end and existing ridings will keep the number previously assigned.
 */
DROP MATERIALIZED VIEW IF EXISTS _work.ed_ids CASCADE;
CREATE MATERIALIZED VIEW _work.ed_ids AS
(
WITH names AS (
    SELECT DISTINCT ON (prov_code, ed_name_canonical) prov_code,
                                                      ed_name_canonical,
                                                      elections[1] AS first_election
    FROM _work.ed_names
    ORDER BY prov_code, ed_name_canonical, elections[1] ASC
),
     ids AS (
         SELECT ROW_NUMBER() OVER (ORDER BY first_election, prov_code, ed_name_canonical) AS ed_id,
                prov_code,
                ed_name_canonical,
                first_election
         FROM names
     )

SELECT ed_id, prov_code, ed_name_canonical, ed_lookup
FROM ids
         JOIN _work.ed_names USING (prov_code, ed_name_canonical) );

REFRESH MATERIALIZED VIEW _work.ed_ids;