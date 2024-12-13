CREATE SCHEMA views;
CREATE OR REPLACE FUNCTION mask_name(name text)
RETURNS text AS $$
DECLARE
    words text[];
    masked_name text;
BEGIN
    words := regexp_split_to_array(name, '\s+');
    IF array_length(words, 1) >= 2 THEN
        words[2] := repeat('*', length(words[2]));
    END IF;
    masked_name := array_to_string(words, ' ');
    RETURN masked_name;
END;
$$ LANGUAGE plpgsql;
CREATE OR REPLACE FUNCTION mask_date(input_date DATE)
RETURNS TEXT AS $$
DECLARE
    masked_date TEXT;
BEGIN
    masked_date := to_char(input_date, 'YYYY-MM-DD');
    masked_date := regexp_replace(masked_date, '([0-9]{2})$', '**', 'g'); 
    masked_date := regexp_replace(masked_date, '-([0-9]{2})-', '-**-', 'g');
    RETURN masked_date;
END;
$$ LANGUAGE plpgsql;

CREATE VIEW views.Organizer_view as select mask_name(name) as name, function from pravoberega.Organizer;
CREATE VIEW views.Club_view as select name from pravoberega.Club;
CREATE VIEW views.Tournament_view as select Name, Format, Season  from pravoberega.Tournament;
CREATE VIEW views.Stadium_view as select Name, Address from pravoberega.Stadium;
CREATE VIEW views.Tour_view as select Number from pravoberega.Tour; /*Не представляю зачем нужно такое представление*/
CREATE VIEW views.Team_view as select name, Founding_date from pravoberega.Team; 
CREATE VIEW views.Player_view as select mask_name(name) as name, mask_date(Date_of_birth) as Date_of_birth, Position from pravoberega.Player; 
CREATE VIEW views.Reward_view1 as select Reward_type from pravoberega.Reward; /*Странное представление, возможно стоит заменить поле player_id  на имя?*/
create view views.Reward_view2 as select reward_type, mask_name(name) from pravoberega.Reward as r join pravoberega.Player as p on r.player_id=p.player_id;
CREATE VIEW views.Coach_view as select mask_name(name) as name, mask_date(Date_of_birth) as Date_of_birth from pravoberega.Coach; 
CREATE VIEW views.Sponsor_view as select name as name from pravoberega.Sponsor; 
CREATE VIEW views.Match_view1 as select date, time from pravoberega.Match; /*Странное представление, возможно стоит заменить поле team_id  на имя и tour_id на номер тура? Возможно стоит объединить поля date и time:*/
create view views.Match_view2 as WITH temp(date, time, name, team_id_2) AS
(
    select m.date, m.time, t1.name as name, m.team_id_2 from pravoberega.Match as m join pravoberega.team as t1 on m.team_id_1=t1.team_id
)select temp.date, temp.time, temp.name as first_team, t2.name as second_team from temp join pravoberega.team as t2 on temp.team_id_2=t2.team_id;
/*CREATE VIEW views.Match_application_view ??? from pravoberega.Match_application;*/
/*CREATE VIEW views.Tournament_Application_view ??? from pravoberega.Tournament_Application;*/
CREATE VIEW views.Histori_of_Player_view as select mask_name(name) as name, mask_date(Date_of_birth) as Date_of_birth, Position , ChangeDate from pravoberega.Histori_of_Player; /*Возможно это представление не нужно...*/
create view views.Events_view as select Minut, Type from pravoberega.Events;/*Возможно стоит немного добавить данных*/
create view views.Disqualification_view as select Disqualification_type from pravoberega.Disqualification; /*Возможно стоит изменить*/
/*CREATE VIEW views.Match_X_Organizer_view ??? from pravoberega.Match_X_Organizer;*/
/*CREATE VIEW views.Tournament_X_Tour_view ??? from pravoberega.Tournament_X_Tour;*/
/*CREATE VIEW views.Tournament_X_Sponsor_view ??? from pravoberega.Tournament_X_Sponsor;*/
/*CREATE VIEW views.Club_X_Sponsor_view ??? from pravoberega.Club_X_Sponsor;*/
/*CREATE VIEW views.Match_application_X_Player_view ??? from pravoberega.Match_application_X_Player;*/
/*CREATE VIEW views.Tournament_Application_X_Player ??? from pravoberega.Tournament_Application_X_Player;*/
