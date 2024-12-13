CREATE SCHEMA pravoberega;
CREATE TABLE pravoberega.Organizer (Organizer_id INT PRIMARY KEY NOT NULL,
    Name text not null,
    Function text not null
);
CREATE TABLE pravoberega.Club (Club_id INT PRIMARY KEY NOT NULL,
    Name text not null
);
CREATE TABLE pravoberega.Tournament (Tournament_id INT PRIMARY KEY NOT NULL,
    Name text not null,
    Format text not null,
    Season text not null
);
CREATE TABLE pravoberega.Stadium (Stadium_id INT PRIMARY KEY NOT NULL,
    Name text not null,
    Address text not null
);
CREATE TABLE pravoberega.Tour (Tour_id INT PRIMARY KEY NOT NULL,
    Number INT NOT NULL CHECK (Number > 0),
    Stadium_id INT NOT NULL,
    Tournament_id INT NOT NULL,
    FOREIGN KEY (Stadium_id) REFERENCES pravoberega.Stadium(Stadium_id),
    FOREIGN KEY (Tournament_id) REFERENCES pravoberega.Tournament(Tournament_id)
);
CREATE TABLE pravoberega.Team (Team_Id INT PRIMARY KEY NOT NULL,
    Club_id INT NOT NULL,
    Name text not null,
    Founding_date date not null,
    FOREIGN KEY (Club_id) REFERENCES pravoberega.Club(Club_id)
);
CREATE TABLE pravoberega.Player (Player_id INT PRIMARY KEY NOT NULL,
	Team_id INT,
	Name text not null, 
	Date_of_birth date not null, 
	Position text CHECK (Position in('GK', 'B', 'LB', 'RB', 'CB', 'M', 'DM', 'CM', 'LM', 'RM',  'CAM', 'F','LF', 'RF', 'ST', NULL )),
	Capitan Boolean,
    	FOREIGN KEY (Team_id) REFERENCES pravoberega.Team(Team_id)
);
CREATE TABLE pravoberega.Reward (Reward_id INT PRIMARY KEY NOT NULL,
    Player_id INT NOT NULL,
    Reward_type text not null,
    FOREIGN KEY (Player_id) REFERENCES pravoberega.Player(Player_id)
);
CREATE TABLE pravoberega.Coach (Coach_id INT PRIMARY KEY NOT NULL,
    Club_id INT NOT NULL,
    Name text not null,
    Date_of_birth date not null, 
    FOREIGN KEY (Club_id) REFERENCES pravoberega.Club(Club_id)
);
CREATE TABLE pravoberega.Sponsor (Sponsor_id INT PRIMARY KEY NOT NULL,
    Name text not null      
);
CREATE TABLE pravoberega.Match (Match_id INT PRIMARY KEY NOT NULL,
    Tour_id INT NOT NULL,
    Date text not null,
    Time time not null, 
    Team_id_1 INT NOT NULL,
    Team_id_2 INT NOT NULL,
    FOREIGN KEY (Tour_id) REFERENCES pravoberega.Tour(Tour_id),
    FOREIGN KEY (Team_id_1) REFERENCES pravoberega.Team(Team_id),
    FOREIGN KEY (Team_id_2) REFERENCES pravoberega.Team(Team_id)
);
CREATE TABLE pravoberega.Match_application (Match_application_id INT PRIMARY KEY NOT NULL,
    Match_id INT NOT NULL,
    Team_id INT NOT NULL,
    FOREIGN KEY (Match_id) REFERENCES pravoberega.Match(Match_id),
    FOREIGN KEY (Team_id) REFERENCES pravoberega.Team(Team_id)
);
CREATE TABLE pravoberega.Tournament_Application (Tournament_Application_id INT PRIMARY KEY NOT NULL,
    Tournament_id INT NOT NULL,
    Team_id INT NOT NULL,
    FOREIGN KEY (Team_id) REFERENCES pravoberega.Team(Team_id),
    FOREIGN KEY (Tournament_id) REFERENCES pravoberega.Tournament(Tournament_id)
);
CREATE TABLE pravoberega.Histori_of_Player (Player_id INT NOT NULL,
	Team_id INT,
	Name text not null, 
	Date_of_birth date not null, 
	Position text CHECK (Position in('GK', 'B', 'LB', 'RB', 'CB', 'M', 'DM', 'CM', 'LM', 'RM',  'CAM', 'F','LF', 'RF', 'ST', NULL )),
	Capitan Boolean,
	ChangeDate date not null,
    	FOREIGN KEY (Team_id) REFERENCES pravoberega.Team(Team_id)
);
CREATE TABLE pravoberega.Events (Event_id INT PRIMARY KEY NOT NULL,
    Match_id INT NOT NULL,
    Player_id_1 INT NOT NULL,
    Player_id_2 INT,
    Minut time not null, 
    Type text not null,
    FOREIGN KEY (Match_id) REFERENCES pravoberega.Match(Match_id),
    FOREIGN KEY (Player_id_1) REFERENCES pravoberega.Player(Player_id),
    FOREIGN KEY (Player_id_2) REFERENCES pravoberega.Player(Player_id)
);
CREATE TABLE pravoberega.Disqualification (Disqualification_id INT PRIMARY KEY NOT NULL,
    Player_id INT NOT NULL,
    Match_id INT,
    Disqualification_type text not null,
    isCurrent Boolean,
    FOREIGN KEY (Player_id) REFERENCES pravoberega.Player(Player_id),
    FOREIGN KEY (Match_id) REFERENCES pravoberega.Match(Match_id)
);
CREATE TABLE pravoberega.Match_X_Organizer(Match_id INT NOT NULL,
    Organizer_id INT NOT NULL,
    FOREIGN KEY (Match_id) REFERENCES pravoberega.Match(Match_id),
    FOREIGN KEY (Organizer_id) REFERENCES pravoberega.Organizer(Organizer_id),
    PRIMARY KEY (Match_id, Organizer_id)
);
/*CREATE TABLE pravoberega.Tournament_X_Tour(Tournament_id INT NOT NULL,
    Tour_id INT NOT NULL,
    FOREIGN KEY (Tournament_id) REFERENCES pravoberega.Tournament(Tournament_id),
    FOREIGN KEY (Tour_id) REFERENCES pravoberega.Tour(Tour_id),
    PRIMARY KEY (Tournament_id, Tour_id)
);*/
CREATE TABLE pravoberega.Tournament_X_Sponsor(Tournament_id INT NOT NULL,
    Sponsor_id INT NOT NULL,
    IsCurrent boolean,
    FOREIGN KEY (Tournament_id) REFERENCES pravoberega.Tournament(Tournament_id),
    FOREIGN KEY (Sponsor_id) REFERENCES pravoberega.Sponsor(Sponsor_id),
    PRIMARY KEY (Tournament_id, Sponsor_id)
);
CREATE TABLE pravoberega.Club_X_Sponsor(Club_id INT NOT NULL,
    Sponsor_id INT NOT NULL,
    IsCurrent boolean,
    FOREIGN KEY (Club_id) REFERENCES pravoberega.Club(Club_id),
    FOREIGN KEY (Sponsor_id) REFERENCES pravoberega.Sponsor(Sponsor_id),
    PRIMARY KEY (Club_id, Sponsor_id)
);
CREATE TABLE pravoberega.Match_application_X_Player(Match_Application_id INT NOT NULL,
    Player_id INT NOT NULL,
    FOREIGN KEY (Player_id) REFERENCES pravoberega.Player(Player_id),
    FOREIGN KEY (Match_Application_id) REFERENCES pravoberega.Match_Application(Match_Application_id),
    PRIMARY KEY (Player_id, Match_Application_id)
);
CREATE TABLE pravoberega.Tournament_Application_X_Player(Tournament_Application_id INT NOT NULL,
    Player_id INT NOT NULL,
    FOREIGN KEY (Player_id) REFERENCES pravoberega.Player(Player_id),
    FOREIGN KEY (Tournament_Application_id) REFERENCES pravoberega.Tournament_Application(Tournament_Application_id),
    PRIMARY KEY (Player_id, Tournament_Application_id)
);
