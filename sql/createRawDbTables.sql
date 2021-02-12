\SET ON_ERROR_STOP 'on'

-- Create the DB tables to hold the raw data.


DROP TABLE IF EXISTS _work.recent CASCADE;
CREATE TABLE _work.recent
(
    election_id         INT     NOT NULL,
    ed_id               INT     NOT NULL,
    ed_name             TEXT    NOT NULL,
    ed_name_fr          TEXT    NOT NULL,
    poll_id             TEXT    NOT NULL,
    poll_name           TEXT    NOT NULL,
    poll_void           BOOLEAN NOT NULL,
    poll_not_held       BOOLEAN NOT NULL,
    merge_with          TEXT,
    ballots_rejected    INT     NOT NULL,
    num_electors        INT     NOT NULL,
    cand_last           TEXT    NOT NULL,
    cand_middle         TEXT    NOT NULL,
    cand_first          TEXT    NOT NULL,
    cand_raw_party_name TEXT    NOT NULL,
    cand_party_fr       TEXT    NOT NULL,
    cand_incumbent      BOOLEAN NOT NULL,
    elected             BOOLEAN NOT NULL,
    votes               INT     NOT NULL
);


DROP TABLE IF EXISTS _work.history CASCADE;
CREATE TABLE _work.history
(
    election_date       TEXT    NOT NULL,
    election_type       TEXT    NOT NULL,
    election_id         INT     NOT NULL,
    province            TEXT    NOT NULL,
    ed_name             TEXT    NOT NULL,
    cand_last           TEXT    NOT NULL,
    cand_first          TEXT,
    cand_gender         TEXT,
    cand_occupation     TEXT,
    cand_raw_party_name TEXT    NOT NULL,
    votes_raw           TEXT,
    votes_pct           REAL,
    elected             BOOLEAN NOT NULL
);

DROP TABLE IF EXISTS _work.preliminary CASCADE;
CREATE TABLE _work.preliminary
(
    ed_id               INT  NOT NULL,
    ed_name             TEXT NOT NULL,
    ed_name_fr          TEXT NOT NULL,
    result_type         TEXT NOT NULL,
    result_type_fr      TEXT NOT NULL,
    cand_last           TEXT NOT NULL,
    cand_middle         TEXT,
    cand_first          TEXT NOT NULL,
    cand_raw_party_name TEXT NOT NULL,
    cand_party_name_fr  TEXT NOT NULL,
    votes               INT  NOT NULL,
    votes_pct           REAL NOT NULL,
    ballots_rejected    INT  NOT NULL,
    total_ballots_cast  INT  NOT NULL
);



DROP TABLE IF EXISTS _work.party_name_normalization;
CREATE TABLE _work.party_name_normalization
(
    cand_raw_party_name TEXT NOT NULL,
    party_name          TEXT NOT NULL,
    PRIMARY KEY (cand_raw_party_name)
);

/*
 See the "Name Changes" section of  https://en.wikipedia.org/wiki/List_of_federal_political_parties_in_Canada
 */
INSERT INTO _work.party_name_normalization
VALUES ('AACEV Party of Canada', 'AACEV Party of Canada'),
       ('ATN', 'ATN'),
       ('All Canadian Party', 'All Canadian Party'),
       ('Anti-Conscriptionist', 'Anti-Conscriptionist'),

       ('Abolitionist Party of Canada', 'Abolitionist Party of Canada'),

       ('Animal Alliance Environment Voters Party of Canada', 'Animal Alliance/Environment Voters'),
       ('Animal Alliance/Environment Voters', 'Animal Alliance/Environment Voters'),
       ('AAEV Party of Canada', 'Animal Alliance/Environment Voters'),

       ('Animal Protection Party', 'Animal Protection Party'),
       ('Anti-Communist', 'Anti-Communist'),
       ('Anti-Confederate', 'Anti-Confederate'),
       ('Autonomist', 'Autonomist'),
       ('Bloc Québécois', 'Bloc Québécois'),
       ('Bloc populaire canadien', 'Bloc populaire canadien'),

       ('CAP', 'Canadian Action Party'),
       ('Canadian Action Party', 'Canadian Action Party'),
       ('Canadian Action', 'Canadian Action Party'),

       ('CFF - Canada''s Fourth Front', 'CFF - Canada''s Fourth Front'),

       ('CHP Canada', 'Christian Heritage Party'),
       ('Christian Heritage Party', 'Christian Heritage Party'),
       ('Christian Heritage Party of Canada', 'Christian Heritage Party'),

       ('Canada Party', 'Canada Party'),
       ('Canadian Alliance', 'Canadian Alliance'),
       ('Canadian Party', 'Canadian Party'),

       ('Candidat libéral des électeurs', 'Candidat libéral des électeurs'),

       ('Capital  familial', 'Capital  familial'),

       ('Co-operative Commonwealth Federation', 'Co-operative Commonwealth Federation'),
       ('New Party', 'Co-operative Commonwealth Federation'),

       ('Communist', 'Communist Party'),
       ('Communist Party of Canada', 'Communist Party'),
       ('United Progressive', 'Communist Party'),
       ('Unity', 'Communist Party'),
       ('Labour Progressive Party', 'Communist Party'),

       ('Confederation of Regions Western Party', 'Confederation of Regions Western Party'),
       ('Conservative', 'Conservative'),
       ('Conservative Party of Canada', 'Conservative Party of Canada'),
       ('Cooperative Builders of Canada', 'Cooperative Builders of Canada'),
       ('Democrat', 'Democrat'),
       ('Democratic Advancement', 'Democratic Advancement'),
       ('Droit vital personnel', 'Droit vital personnel'),
       ('Equal Rights', 'Equal Rights'),
       ('Esprit social', 'Esprit social'),

       ('FPNP', 'First Peoples National Party'),
       ('First Peoples National Party of Canada', 'First Peoples National Party'),

       ('Forces et Démocratie - Allier les forces de nos régions',
        'Forces et Démocratie - Allier les forces de nos régions'),
       ('Franc Lib', 'Franc Lib'),
       ('Government', 'Government'),

       ('Green Party', 'Green Party'),
       ('Green Party of Canada', 'Green Party'),

       ('Independent', 'Independent'),
       ('No Affiliation', 'Independent'),
       ('No affiliation to a recognised party', 'Independent'),

       ('Independent Co-operative Commonwealth Federation', 'Independent Co-operative Commonwealth Federation'),
       ('Independent Conservative', 'Independent Conservative'),
       ('Independent Labor', 'Independent Labor'),
       ('Independent Liberal', 'Independent Liberal'),
       ('Independent Liberal Progressive', 'Independent Liberal Progressive'),
       ('Independent Nationalist', 'Independent Nationalist'),
       ('Independent Progressive', 'Independent Progressive'),
       ('Independent Progressive Conservative', 'Independent Progressive Conservative'),
       ('Independent Reconstruction Party', 'Independent Reconstruction Party'),
       ('Independent Social Credit', 'Independent Social Credit'),
       ('Canadian Democrat', 'Canadian Democrat'),
       ('Canadian Labour', 'Canadian Labour'),
       ('Christian Liberal', 'Christian Liberal'),

       ('Labour', 'Labour'),
       ('Conservative-Labour', 'Labour'),
       ('Farmer Labour', 'Labour'),
       ('Farmer-United Labour', 'Labour'),
       ('Labour Farmer', 'Labour'),
       ('Liberal Labour', 'Labour'),
       ('Liberal Labour Party', 'Labour'),
       ('National Labour', 'Labour'),
       ('United Farmers of Ontario-Labour', 'Labour'),
       ('United Farmers-Labour', 'Labour'),


       ('Liberal', 'Liberal'),
       ('Liberal Conservative Coalition', 'Liberal Conservative Coalition'),

       ('Liberal Labour Progressive', 'Liberal Labour Progressive'),
       ('National Liberal Progressive', 'Liberal Labour Progressive'),

       ('Liberal Progressive', 'Liberal Progressive'),
       ('Liberal Protectionist', 'Liberal Protectionist'),

       ('Libertarian', 'Libertarian Party'),
       ('Libertarian Party of Canada', 'Libertarian Party'),

       ('Locataire (candidat)', 'Locataire (candidat)'),

       ('Marijuana Party', 'Marijuana Party'),
       ('Radical Marijuana', 'Marijuana Party'),

       ('Marxist-Leninist', 'Marxist-Leninist Party'),
       ('Marxist-Leninist Party', 'Marxist-Leninist Party'),
       ('ML', 'Marxist-Leninist Party'),

       ('McCarthyite', 'McCarthyite'),

       ('N.D.P.', 'New Democratic Party'),
       ('NDP-New Democratic Party', 'New Democratic Party'),
       ('New Democratic Party', 'New Democratic Party'),

       ('National Citizens Alliance', 'National Citizens Alliance'),
       ('National Credit Control', 'National Credit Control'),
       ('National Party of Canada', 'National Party of Canada'),
       ('National Socialist', 'National Socialist'),
       ('National Unity', 'National Unity'),
       ('Nationalist', 'Nationalist'),
       ('Nationalist Conservative', 'Nationalist Conservative'),
       ('Nationalist Liberal', 'Nationalist Liberal'),
       ('Natural Law Party of Canada', 'Natural Law Party of Canada'),
       ('New Canada Party', 'New Canada Party'),
       ('Newfoundland and Labrador First Party', 'Newfoundland and Labrador First Party'),
       ('NL First Party', 'Newfoundland and Labrador First Party'),
       ('Non-Partisan League', 'Non-Partisan League'),
       ('Opposition', 'Opposition'),
       ('Opposition-Labour', 'Opposition-Labour'),
       ('Ouvrier indépendent', 'Ouvrier indépendent'),
       ('PACT', 'Party for Accountability, Competency and Transparency'),

       ('Liberal-Conservative', 'Progressive Conservative Party'),
       ('National Liberal and Conservative Party', 'Progressive Conservative Party'),
       ('National Government', 'Progressive Conservative Party'),

       ('Parti Nationaliste du Québec', 'Parti Nationaliste du Québec'),
       ('Parti de la Démocratisation Économique', 'Parti de la Démocratisation Économique'),
       ('Parti humain familial', 'Parti humain familial'),
       ('Parti ouvrier canadien', 'Parti ouvrier canadien'),
       ('Party for the Commonwealth of Canada', 'Party for the Commonwealth of Canada'),
       ('Patrons of Industry', 'Patrons of Industry'),
       ('People''s Party', 'People''s Party'),
       ('People''s Political Power Party of Canada', 'People''s Political Power Party of Canada'),
       ('PPP', 'People''s Political Power Party of Canada'),

       ('Pirate', 'Pirate Party'),
       ('Pirate Party', 'Pirate Party'),
       ('Pirate Party of Canada', 'Pirate Party'),

       ('Pour l''Indépendance du Québec', 'Pour l''Indépendance du Québec'),
       ('Progressive', 'Progressive'),

       ('Progressive Canadian Party', 'Progressive Canadian Party'),
       ('PC Party', 'Progressive Canadian Party'),

       ('Progressive Conservative', 'Progressive Conservative Party'),

       ('Progressive Workers Movement', 'Progressive Workers Movement'),
       ('Prohibition', 'Prohibition'),
       ('Protectionist', 'Protectionist'),
       ('Protestant Protective Association', 'Protestant Protective Association'),
       ('Radical chrétien', 'Radical chrétien'),
       ('Reconstruction Party', 'Reconstruction Party'),

       ('Reform', 'Reform Party'),
       ('Reform Party of Canada', 'Reform Party'),

       ('Republican', 'Republican Party'),
       ('Republican Party', 'Republican Party'),

       ('Rhinoceros', 'Rhinoceros Party'),
       ('Parti Rhinocéros', 'Rhinoceros Party'),
       ('Parti Rhinocéros Party', 'Rhinoceros Party'),
       ('neorhino.ca', 'Rhinoceros Party'),

       ('Seniors Party', 'Seniors Party'),

       ('Social Credit Party of Canada', 'Social Credit Party'),
       ('New Democracy', 'Social Credit Party'),
       ('Ralliement Créditiste', 'Social Credit Party'),
       ('Candidats des électeurs', 'Social Credit Party'),

       ('Social Credit-National Unity', 'Social Credit-National Unity'),
       ('Socialist', 'Socialist'),
       ('Socialist Labour', 'Socialist Labour'),
       ('Stop Climate Change', 'Stop Climate Change'),
       ('Technocrat', 'Technocrat'),
       ('The Bridge', 'The Bridge'),
       ('Trades Union', 'Trades Union'),
       ('Union Populaire', 'Union Populaire'),
       ('Union of Electors', 'Union of Electors'),

       ('United Farmers', 'United Farmers'),
       ('United Farmers of Alberta', 'United Farmers'),
       ('United Farmers of Ontario', 'United Farmers'),
       ('Farmer', 'United Farmers'),

       ('United Party', 'United Party of Canada'),
       ('United Party of Canada', 'United Party of Canada'),
       ('UPC', 'United Party of Canada'),

       ('United Reform', 'United Reform Movement'),
       ('United Reform Movement', 'United Reform Movement'),

       ('Unité nationale', 'Unité nationale'),
       ('Unknown', 'Unknown'),
       ('VCP', 'Veterans Coalition'),
       ('Verdun', 'Verdun'),
       ('Veterans Party', 'Veterans Party'),
       ('WBP', 'Western Block Party'),
       ('Western Block Party', 'Western Block Party'),
       ('Work Less Party', 'Work Less Party')
;


DROP TABLE IF EXISTS _work.parties;
CREATE TABLE _work.parties
(
    party_id         INT  NOT NULL,
    party_name       TEXT NOT NULL,
    party_short_name TEXT NOT NULL,
    ideology_code    TEXT NOT NULL,

    PRIMARY KEY (party_id)
);

CREATE UNIQUE INDEX parties_pk ON _work.parties (party_name);
COMMENT ON TABLE _work.parties IS 'Party names and other info.';

INSERT INTO _work.parties (party_id, party_name, party_short_name, ideology_code)
VALUES (1, 'AACEV Party of Canada', 'AACEV', 'Oth'),
       (2, 'ATN', 'ATN', 'Oth'),
       (3, 'Abolitionist Party of Canada', 'Abolition', 'SglIss'),
       (4, 'All Canadian Party', 'ACP', 'Oth'),
       (5, 'Animal Alliance/Environment Voters', 'AnimalAll', 'SglIss'),
       (7, 'Animal Protection Party', 'AnimalPP', 'SglIss'),
       (8, 'Anti-Communist', 'AntiCom', 'SglIss'),
       (9, 'Anti-Confederate', 'AntiConfed', 'SglIss'),
       (10, 'Anti-Conscriptionist', 'AntiConscript', 'SglIss'),
       (11, 'Autonomist', 'Auton', 'Oth'),
       (12, 'Bloc Québécois', 'Bloc', 'Quebec'),
       (13, 'Bloc populaire canadien', 'BlocPop', 'Pop'),
       (14, 'CFF - Canada''s Fourth Front', 'FourthFront', 'Oth'),
       (15, 'Canada Party', 'CdaParty', 'Oth'),
       (16, 'Canadian Action Party', 'CAP', 'Pop'),
       (19, 'Canadian Alliance', 'CdnAll', 'Con'),
       (20, 'Canadian Democrat', 'CdnDem', 'Oth'),
       (21, 'Canadian Labour', 'CdnLab', 'Labour'),
       --(22, 'Canadian Party', '', ''),
       (23, 'Candidat libéral des électeurs', 'Electeurs', 'Oth'),
       (24, 'Capital  familial', 'CapFam', 'Oth'),
       (25, 'Christian Heritage Party', 'CHP', 'Con'),
       (28, 'Christian Liberal', 'ChristLib', 'Oth'),
       (29, 'Co-operative Commonwealth Federation', 'CCF', 'Labour'),
       (31, 'Communist Party', 'Com', 'Labour'),
       (36, 'Confederation of Regions Western Party', 'RegionsW', 'Con'),
       (37, 'Conservative', 'Con', 'Con'),
       (38, 'Conservative Party of Canada', 'ConParty', 'Con'),
       (39, 'Cooperative Builders of Canada', 'Builder', 'Oth'),
       (40, 'Democrat', 'Demo', 'Oth'),
       (41, 'Democratic Advancement', 'DemoAdv', 'Oth'),
       (42, 'Droit vital personnel', 'Droit', 'Oth'),
       (43, 'Equal Rights', 'EqRights', 'Oth'),
       (44, 'Esprit social', 'Esprit', 'Oth'),
       (46, 'First Peoples National Party', 'FPNP', 'SglIss'),
       (47, 'Forces et Démocratie - Allier les forces de nos régions', 'ForcesDem', 'Oth'),
       (48, 'Franc Lib', 'FrancLib', 'Oth'),
       (49, 'Government', 'Gov', 'Con'),
       (50, 'Green Party', 'Grn', 'Env'),
       (52, 'Independent', 'Ind', 'Oth'),
       (55, 'Independent Co-operative Commonwealth Federation', 'IndCCF', 'Labour'),
       (56, 'Independent Conservative', 'IndCon', 'Con'),
       (57, 'Independent Labor', 'IndLab', 'Labour'),
       (58, 'Independent Liberal', 'IndLib', 'Lib'),
       (59, 'Independent Liberal Progressive', 'IndLibP', 'Lib'),
       (60, 'Independent Nationalist', 'IndNat', 'Pop'),
       (61, 'Independent Progressive', 'IndProg', 'Labour'),
       (62, 'Independent Progressive Conservative', 'IndProgCon', 'Con'),
       (63, 'Independent Reconstruction Party', 'IndRecon', 'Oth'),
       (64, 'Independent Social Credit', 'IndSoCred', 'Pop'),
       (65, 'Labour', 'Labour', 'Labour'),
       (75, 'Liberal', 'Lib', 'Lib'),
       (76, 'Liberal Conservative Coalition', 'LibConCoal', 'Oth'),
       (77, 'Liberal Labour Progressive', 'LibLabProg', 'Oth'),
       (79, 'Liberal Progressive', 'LibProgr', 'Oth'),
       (80, 'Liberal Protectionist', 'LibProtect', 'SglIss'),
       (81, 'Libertarian Party', 'Liber', 'Pop'),
       (83, 'Locataire (candidat)', 'Locataire', 'Oth'),
       (84, 'Marijuana Party', 'Marijuana', 'SglIss'),
       (86, 'Marxist-Leninist Party', 'Marx-Len', 'Labour'),
       (89, 'McCarthyite', 'McCarthy', 'Oth'),
       (90, 'National Citizens Alliance', 'NatCitAlli', 'Pop'),
       (91, 'National Credit Control', 'NatCredControl', 'Labour'),
       (92, 'National Party of Canada', 'NationalPC', 'Oth'),
       (93, 'National Socialist', 'NatSoc', 'Oth'),
       (94, 'National Unity', 'NatUnity', 'Oth'),
       (95, 'Nationalist', 'Nationalist', 'Oth'),
       (96, 'Nationalist Conservative', 'NationalistCon', 'Oth'),
       --(97, 'Nationalist Liberal', '', ''),
       (98, 'Natural Law Party of Canada', 'NatLaw', 'SglIss'),
       (99, 'New Canada Party', 'NewCan', 'Oth'),
       (100, 'New Democratic Party', 'NDP', 'Labour'),
       (103, 'Newfoundland and Labrador First Party', 'NLFP', 'SglIss'),
       (104, 'Non-Partisan League', 'NonPartL', 'Oth'),
       (105, 'Opposition', 'OppConscript', 'Lib'),
       (106, 'Opposition-Labour', 'OppConscriptL', 'Lib'),
       (107, 'Ouvrier indépendent', 'OuvInd', 'Labour'),
       (108, 'Parti Nationaliste du Québec', 'NationalQc', 'Quebec'),
       (109, 'Parti de la Démocratisation Économique', 'DemoEcon', 'Oth'),
       --(110, 'Parti humain familial', '', ''),
       (111, 'Parti ouvrier canadien', 'OuvCan', 'Labour'),
       (112, 'Party for Accountability, Competency and Transparency', 'PACT', 'SglIss'),
       (113, 'Party for the Commonwealth of Canada', 'CWealth', 'Oth'),
       (114, 'Patrons of Industry', 'PatronsInd', 'Oth'),
       (115, 'People''s Party', 'PPC', 'Pop'),
       (116, 'People''s Political Power Party of Canada', 'PPPPC', 'SglIss'),
       (117, 'Pirate Party', 'Pirate', 'Oth'),
       (120, 'Pour l''Indépendance du Québec', 'IndQc', 'Quebec'),
       (121, 'Progressive', 'Progressive', 'Oth'),
       (122, 'Progressive Canadian Party', 'ProgCdnParty', 'Con'),
       (124, 'Progressive Conservative Party', 'PC', 'Con'),
       (128, 'Progressive Workers Movement', 'ProgWorker', 'Labour'),
       (129, 'Prohibition', 'Prohib', 'SglIss'),
       (130, 'Protectionist', 'Protect', 'SglIss'),
       (131, 'Protestant Protective Association', 'ProtestantPA', 'SglIss'),
       (132, 'Radical chrétien', 'RadChret', 'Oth'),
       (133, 'Reconstruction Party', 'Reconstruct', 'Pop'),
       (134, 'Reform Party', 'Reform', 'Pop'),
       (136, 'Republican Party', 'Repub', 'Oth'),
       (138, 'Rhinoceros Party', 'Rhino', 'Oth'),
       (142, 'Seniors Party', 'Seniors', 'SglIss'),
       (143, 'Social Credit Party', 'SoCred', 'Pop'),
       (147, 'Social Credit-National Unity', 'SoCredNat', 'Pop'),
       (148, 'Socialist', 'Social', 'Labour'),
       (149, 'Socialist Labour', 'SocialLab', 'Labour'),
       (150, 'Stop Climate Change', 'StopCliChg', 'Env'),
       (151, 'Technocrat', 'Techno', 'Oth'),
       (152, 'The Bridge', 'Bridge', 'Oth'),
       (153, 'Trades Union', 'Traces', 'Labour'),
       (155, 'Union Populaire', 'UnionPop', 'SglIss'),
       (156, 'Union of Electors', 'UnionElectors', 'Labour'),
       (157, 'United Farmers', 'UnitedFarm', 'Labour'),
       (161, 'United Party', 'UnitedParty', 'Oth'),
       (162, 'United Party of Canada', 'UPC', 'Oth'),
       (163, 'United Reform Movement', 'UnitedReform', 'Labour'),
       (165, 'Unité nationale', 'Unité', 'Oth'),
       (166, 'Unknown', 'Unknown', 'Oth'),
       (167, 'Veterans Coalition', 'VetsCoal', 'SglIss'),
       (168, 'Verdun', 'Verdun', 'Oth'),
       (169, 'Veterans Party', 'Vets', 'SglIss'),
       (170, 'Western Block Party', 'WBP', 'Pop'),
       (172, 'Work Less Party', 'WorkLess', 'Labour')
;

DROP TABLE IF EXISTS _work.prov_lookup CASCADE;
CREATE TABLE _work.prov_lookup
(
    raw_prov_code TEXT NOT NULL,
    prov_code     TEXT NOT NULL,

    PRIMARY KEY (raw_prov_code)
);

COMMENT ON TABLE _work.prov_lookup IS 'A look-up table to normalize province codes.';

-- For recent data, the province info is embedded in the first two digits electoral district id.
-- For historical data, it's spelled out.
INSERT INTO _work.prov_lookup (raw_prov_code, prov_code)
VALUES ('48', 'AB'),
       ('59', 'BC'),
       ('46', 'MB'),
       ('13', 'NB'),
       ('10', 'NL'),
       ('12', 'NS'),
       ('61', 'NT'),
       ('62', 'NU'),
       ('35', 'ON'),
       ('11', 'PE'),
       ('24', 'QC'),
       ('47', 'SK'),
       ('60', 'YK'),
       ('Saskatchewan', 'SK'),
       ('New Brunswick', 'NB'),
       ('Quebec', 'QC'),
       ('Newfoundland and Labrador', 'NL'),
       ('Manitoba', 'MB'),
       ('Nunavut', 'NU'),
       ('Alberta', 'AB'),
       ('British Columbia', 'BC'),
       ('Yukon', 'YK'),
       ('Northwest Territories', 'NT'),
       ('Prince Edward Island', 'PE'),
       ('Ontario', 'ON'),
       ('Nova Scotia', 'NS')
;

