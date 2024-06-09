-- Create Enums
CREATE TYPE pposition AS ENUM ('tank', 'dps', 'support');
CREATE TYPE region AS ENUM ('KR', 'JP', 'Pacific', 'NA', 'EMEA');
CREATE TYPE map_type AS ENUM ('Busan', 'Ilios', 'Lijiang_Tower', 'Nepal', 'Oasis', 'Antarctica_Peninsula', 
                              'Circuit_Royal', 'Dorado', 'Havana', 'Junkertown', 'Rialto', 'Route_66', 
                              'Shambali_Monastery', 'Watchpoint_Gibraltar', 'Blizzard_World', 
                              'Eichenwalde', 'Hollywood', 'King_s_Row', 'Midtown', 'Numbani', 
                              'Paraiso', 'Colosseo', 'Esperanca', 'New_Queen_Street');

-- Create Teams Table
CREATE TABLE teams (
    team_uid SERIAL PRIMARY KEY,
    team_name VARCHAR(255) NOT NULL,
    team_logo VARCHAR(255) NOT NULL,
    region region NOT NULL
);

-- Create Players Table
CREATE TABLE players (
    player_uid SERIAL PRIMARY KEY,
    playertag VARCHAR(255) NOT NULL,
    realname VARCHAR(255) NOT NULL,
    current_team_id INT REFERENCES teams(team_uid),
    player_logo VARCHAR(255) NOT NULL,
    position pposition NOT NULL,
    region region NOT NULL,
    is_active BOOLEAN NOT NULL
);

-- Create Broadcasts Table
CREATE TABLE broadcasts (
    broadcast_id SERIAL PRIMARY KEY,
    broadcast_url VARCHAR(255) NOT NULL,
    broadcast_time TIMESTAMP NOT NULL,
    is_live BOOLEAN NOT NULL,
    broadcast_title VARCHAR(255) NOT NULL
);

-- Create Matches Table
CREATE TABLE matches (
    match_id SERIAL PRIMARY KEY,
    map_id map_type NOT NULL,
    team1 INT REFERENCES teams(team_uid),
    team2 INT REFERENCES teams(team_uid),
    match_score1 INT NOT NULL,
    match_score2 INT NOT NULL,
    match_time TIMESTAMP NOT NULL
);

-- Insert Teams
INSERT INTO teams (team_name, team_logo, region) VALUES
('Dragons', 'http://example.com/logos/dragons.png', 'EMEA'),
('Titans', 'http://example.com/logos/titans.png', 'NA'),
('Defiant', 'http://example.com/logos/defiant.png', 'Pacific'),
('Dynasty', 'http://example.com/logos/dynasty.png', 'KR'),
('Excelsior', 'http://example.com/logos/excelsior.png', 'NA'),
('Uprising', 'http://example.com/logos/uprising.png', 'NA'),
('Fuel', 'http://example.com/logos/fuel.png', 'NA'),
('Shock', 'http://example.com/logos/shock.png', 'NA'),
('Mayhem', 'http://example.com/logos/mayhem.png', 'NA'),
('Valiant', 'http://example.com/logos/valiant.png', 'Pacific');

-- Insert Players
INSERT INTO players (playertag, realname, current_team_id, player_logo, position, region, is_active) VALUES
('Player1', 'Real Name 1', 1, 'http://example.com/logos/player1.png', 'tank', 'EMEA', TRUE),
('Player2', 'Real Name 2', 1, 'http://example.com/logos/player2.png', 'dps', 'EMEA', TRUE),
('Player3', 'Real Name 3', 1, 'http://example.com/logos/player3.png', 'support', 'EMEA', TRUE),
('Player4', 'Real Name 4', 1, 'http://example.com/logos/player4.png', 'tank', 'EMEA', TRUE),
('Player5', 'Real Name 5', 1, 'http://example.com/logos/player5.png', 'dps', 'EMEA', TRUE),

('Player6', 'Real Name 6', 2, 'http://example.com/logos/player6.png', 'support', 'NA', TRUE),
('Player7', 'Real Name 7', 2, 'http://example.com/logos/player7.png', 'tank', 'NA', TRUE),
('Player8', 'Real Name 8', 2, 'http://example.com/logos/player8.png', 'dps', 'NA', TRUE),
('Player9', 'Real Name 9', 2, 'http://example.com/logos/player9.png', 'support', 'NA', TRUE),
('Player10', 'Real Name 10', 2, 'http://example.com/logos/player10.png', 'tank', 'NA', TRUE),

('Player11', 'Real Name 11', 3, 'http://example.com/logos/player11.png', 'dps', 'Pacific', TRUE),
('Player12', 'Real Name 12', 3, 'http://example.com/logos/player12.png', 'support', 'Pacific', TRUE),
('Player13', 'Real Name 13', 3, 'http://example.com/logos/player13.png', 'tank', 'Pacific', TRUE),
('Player14', 'Real Name 14', 3, 'http://example.com/logos/player14.png', 'dps', 'Pacific', TRUE),
('Player15', 'Real Name 15', 3, 'http://example.com/logos/player15.png', 'support', 'Pacific', TRUE),

('Player16', 'Real Name 16', 4, 'http://example.com/logos/player16.png', 'tank', 'KR', TRUE),
('Player17', 'Real Name 17', 4, 'http://example.com/logos/player17.png', 'dps', 'KR', TRUE),
('Player18', 'Real Name 18', 4, 'http://example.com/logos/player18.png', 'support', 'KR', TRUE),
('Player19', 'Real Name 19', 4, 'http://example.com/logos/player19.png', 'tank', 'KR', TRUE),
('Player20', 'Real Name 20', 4, 'http://example.com/logos/player20.png', 'dps', 'KR', TRUE),

('Player21', 'Real Name 21', 5, 'http://example.com/logos/player21.png', 'support', 'NA', TRUE),
('Player22', 'Real Name 22', 5, 'http://example.com/logos/player22.png', 'tank', 'NA', TRUE),
('Player23', 'Real Name 23', 5, 'http://example.com/logos/player23.png', 'dps', 'NA', TRUE),
('Player24', 'Real Name 24', 5, 'http://example.com/logos/player24.png', 'support', 'NA', TRUE),
('Player25', 'Real Name 25', 5, 'http://example.com/logos/player25.png', 'tank', 'NA', TRUE),

('Player26', 'Real Name 26', 6, 'http://example.com/logos/player26.png', 'dps', 'NA', TRUE),
('Player27', 'Real Name 27', 6, 'http://example.com/logos/player27.png', 'support', 'NA', TRUE),
('Player28', 'Real Name 28', 6, 'http://example.com/logos/player28.png', 'tank', 'NA', TRUE),
('Player29', 'Real Name 29', 6, 'http://example.com/logos/player29.png', 'dps', 'NA', TRUE),
('Player30', 'Real Name 30', 6, 'http://example.com/logos/player30.png', 'support', 'NA', TRUE),

('Player31', 'Real Name 31', 7, 'http://example.com/logos/player31.png', 'tank', 'NA', TRUE),
('Player32', 'Real Name 32', 7, 'http://example.com/logos/player32.png', 'dps', 'NA', TRUE),
('Player33', 'Real Name 33', 7, 'http://example.com/logos/player33.png', 'support', 'NA', TRUE),
('Player34', 'Real Name 34', 7, 'http://example.com/logos/player34.png', 'tank', 'NA', TRUE),
('Player35', 'Real Name 35', 7, 'http://example.com/logos/player35.png', 'dps', 'NA', TRUE),

('Player36', 'Real Name 36', 8, 'http://example.com/logos/player36.png', 'support', 'NA', TRUE),
('Player37', 'Real Name 37', 8, 'http://example.com/logos/player37.png', 'tank', 'NA', TRUE),
('Player38', 'Real Name 38', 8, 'http://example.com/logos/player38.png', 'dps', 'NA', TRUE),
('Player39', 'Real Name 39', 8, 'http://example.com/logos/player39.png', 'support', 'NA', TRUE),
('Player40', 'Real Name 40', 8, 'http://example.com/logos/player40.png', 'tank', 'NA', TRUE),

('Player41', 'Real Name 41', 9, 'http://example.com/logos/player41.png', 'dps', 'NA', TRUE),
('Player42', 'Real Name 42', 9, 'http://example.com/logos/player42.png', 'support', 'NA', TRUE),
('Player43', 'Real Name 43', 9, 'http://example.com/logos/player43.png', 'tank', 'NA', TRUE),
('Player44', 'Real Name 44', 9, 'http://example.com/logos/player44.png', 'dps', 'NA', TRUE),
('Player45', 'Real Name 45', 9, 'http://example.com/logos/player45.png', 'support', 'NA', TRUE),

('Player46', 'Real Name 46', 10, 'http://example.com/logos/player46.png', 'tank', 'Pacific', TRUE),
('Player47', 'Real Name 47', 10, 'http://example.com/logos/player47.png', 'dps', 'Pacific', TRUE),
('Player48', 'Real Name 48', 10, 'http://example.com/logos/player48.png', 'support', 'Pacific', TRUE),
('Player49', 'Real Name 49', 10, 'http://example.com/logos/player49.png', 'tank', 'Pacific', TRUE),
('Player50', 'Real Name 50', 10, 'http://example.com/logos/player50.png', 'dps', 'Pacific', TRUE);

-- Insert Matches
INSERT INTO matches (map_id, team1, team2, match_score1, match_score2, match_time) VALUES
('Busan', 1, 2, 3, 2, '2024-01-01 15:00:00'),
('Ilios', 3, 4, 2, 2, '2024-01-02 16:00:00'),
('Lijiang_Tower', 5, 6, 1, 3, '2024-01-03 17:00:00'),
('Nepal', 7, 8, 2, 1, '2024-01-04 18:00:00'),
('Oasis', 9, 10, 0, 3, '2024-01-05 19:00:00'),
('Antarctica_Peninsula', 1, 3, 3, 1, '2024-01-06 15:00:00'),
('Circuit_Royal', 2, 4, 2, 2, '2024-01-07 16:00:00'),
('Dorado', 5, 7, 1, 2, '2024-01-08 17:00:00'),
('Havana', 6, 8, 2, 1, '2024-01-09 18:00:00'),
('Junkertown', 9, 1, 0, 2, '2024-01-10 19:00:00'),
('Rialto', 10, 2, 3, 0, '2024-01-11 15:00:00'),
('Route_66', 3, 5, 2, 1, '2024-01-12 16:00:00'),
('Shambali_Monastery', 4, 6, 1, 2, '2024-01-13 17:00:00'),
('Watchpoint_Gibraltar', 7, 9, 3, 2, '2024-01-14 18:00:00'),
('Blizzard_World', 8, 10, 2, 2, '2024-01-15 19:00:00'),
('Eichenwalde', 1, 4, 0, 3, '2024-01-16 15:00:00'),
('Hollywood', 2, 5, 1, 2, '2024-01-17 16:00:00'),
('King_s_Row', 3, 6, 2, 1, '2024-01-18 17:00:00'),
('Midtown', 4, 7, 1, 3, '2024-01-19 18:00:00'),
('Numbani', 5, 8, 2, 0, '2024-01-20 19:00:00'),
('Paraiso', 6, 9, 3, 1, '2024-01-21 15:00:00'),
('Colosseo', 7, 10, 2, 2, '2024-01-22 16:00:00'),
('Esperanca', 8, 1, 0, 3, '2024-01-23 17:00:00'),
('New_Queen_Street', 9, 2, 1, 2, '2024-01-24 18:00:00'),
('Busan', 10, 3, 3, 2, '2024-01-25 19:00:00'),
('Ilios', 1, 5, 2, 1, '2024-01-26 15:00:00'),
('Lijiang_Tower', 2, 6, 1, 2, '2024-01-27 16:00:00'),
('Nepal', 3, 7, 2, 3, '2024-01-28 17:00:00'),
('Oasis', 4, 8, 1, 1, '2024-01-29 18:00:00'),
('Antarctica_Peninsula', 5, 9, 0, 0, '2024-01-30 19:00:00');

-- Insert Broadcasts
INSERT INTO broadcasts (broadcast_url, broadcast_time, is_live, broadcast_title) VALUES
('http://example.com/broadcasts/1', '2024-01-01 15:00:00', TRUE, 'Match 1 Broadcast'),
('http://example.com/broadcasts/2', '2024-01-02 16:00:00', TRUE, 'Match 2 Broadcast'),
('http://example.com/broadcasts/3', '2024-01-03 17:00:00', TRUE, 'Match 3 Broadcast'),
('http://example.com/broadcasts/4', '2024-01-04 18:00:00', TRUE, 'Match 4 Broadcast'),
('http://example.com/broadcasts/5', '2024-01-05 19:00:00', TRUE, 'Match 5 Broadcast'),
('http://example.com/broadcasts/6', '2024-01-06 15:00:00', TRUE, 'Match 6 Broadcast'),
('http://example.com/broadcasts/7', '2024-01-07 16:00:00', TRUE, 'Match 7 Broadcast'),
('http://example.com/broadcasts/8', '2024-01-08 17:00:00', TRUE, 'Match 8 Broadcast'),
('http://example.com/broadcasts/9', '2024-01-09 18:00:00', TRUE, 'Match 9 Broadcast'),
('http://example.com/broadcasts/10', '2024-01-10 19:00:00', TRUE, 'Match 10 Broadcast'),
('http://example.com/broadcasts/11', '2024-01-11 15:00:00', TRUE, 'Match 11 Broadcast'),
('http://example.com/broadcasts/12', '2024-01-12 16:00:00', TRUE, 'Match 12 Broadcast'),
('http://example.com/broadcasts/13', '2024-01-13 17:00:00', TRUE, 'Match 13 Broadcast'),
('http://example.com/broadcasts/14', '2024-01-14 18:00:00', TRUE, 'Match 14 Broadcast'),
('http://example.com/broadcasts/15', '2024-01-15 19:00:00', TRUE, 'Match 15 Broadcast'),
('http://example.com/broadcasts/16', '2024-01-16 15:00:00', TRUE, 'Match 16 Broadcast'),
('http://example.com/broadcasts/17', '2024-01-17 16:00:00', TRUE, 'Match 17 Broadcast'),
('http://example.com/broadcasts/18', '2024-01-18 17:00:00', TRUE, 'Match 18 Broadcast'),
('http://example.com/broadcasts/19', '2024-01-19 18:00:00', TRUE, 'Match 19 Broadcast'),
('http://example.com/broadcasts/20', '2024-01-20 19:00:00', TRUE, 'Match 20 Broadcast'),
('http://example.com/broadcasts/21', '2024-01-21 15:00:00', TRUE, 'Match 21 Broadcast'),
('http://example.com/broadcasts/22', '2024-01-22 16:00:00', TRUE, 'Match 22 Broadcast'),
('http://example.com/broadcasts/23', '2024-01-23 17:00:00', TRUE, 'Match 23 Broadcast'),
('http://example.com/broadcasts/24', '2024-01-24 18:00:00', TRUE, 'Match 24 Broadcast'),
('http://example.com/broadcasts/25', '2024-01-25 19:00:00', TRUE, 'Match 25 Broadcast'),
('http://example.com/broadcasts/26', '2024-01-26 15:00:00', TRUE, 'Match 26 Broadcast'),
('http://example.com/broadcasts/27', '2024-01-27 16:00:00', TRUE, 'Match 27 Broadcast'),
('http://example.com/broadcasts/28', '2024-01-28 17:00:00', TRUE, 'Match 28 Broadcast'),
('http://example.com/broadcasts/29', '2024-01-29 18:00:00', TRUE, 'Match 29 Broadcast'),
('http://example.com/broadcasts/30', '2024-01-30 19:00:00', TRUE, 'Match 30 Broadcast');
