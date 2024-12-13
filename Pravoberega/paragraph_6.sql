-- Вывести лучших бомбардиров турнира (первые 5 мест)
SELECT * FROM
(SELECT name, count(*) as goals,
rank() over (order by count(*) desc)
FROM(pravoberega.player p inner join
pravoberega.events e on p.player_id = e.player_id_1)
where e.type in ('г1', 'г2', 'ш1', 'ш2')
group by name) as player_goals
where rank < 6;

-- Вывести лучших ассистентов турнира (первые 5 мест)
SELECT * FROM
(SELECT name, count(*) as пас,
rank() over (order by count(*) desc)
FROM(pravoberega.player p inner join
pravoberega.events e on p.player_id = e.player_id_2)
where e.type in ('г1', 'г2')
group by name) as player_goals
where rank < 6;

-- Вывести лучших по системе Г+П турнира (первые 5 мест)
SELECT * FROM
(SELECT name, count(*) as гол_пас,
rank() over (order by count(*) desc)
FROM(pravoberega.player p inner join
pravoberega.events e on (p.player_id = e.player_id_1 or p.player_id = e.player_id_2))
where e.type in ('г1', 'г2', 'ш1', 'ш2', 'п1', 'п2')
group by name) as player_goals_and_pass
where rank < 6;

-- Для каждой команды в турнире вывести самого молодого и самого возрастного игроков
SELECT team_name, player_name, date_of_birth, age FROM
(SELECT t.name as team_name, p.name as player_name, p.date_of_birth,
ROUND(('2024-10-21' - p.date_of_birth) / 365.25) as age,
max(p.date_of_birth) over (PARTITION by t.name) as age1,
min(p.date_of_birth) over (PARTITION by t.name) as age2
FROM (pravoberega.team t inner join pravoberega.tournament_application ta
on t.team_id = ta.team_id
left join pravoberega.tournament_application_x_player tap
on ta.tournament_application_id = tap.tournament_application_id
left join pravoberega.player p
on tap.player_id = p.player_id)) as tmp
where tmp.date_of_birth = tmp.age1 or tmp.date_of_birth = tmp.age2
order by team_name desc, age asc;

-- Вывести список игроков, получивших хотя бы 3 ЖК или хотя бы 1 КК
SELECT name, sum(ЖК) as ЖК, sum(КК) as КК FROM
((SELECT name, 1 as ЖК, 0 as КК
FROM(pravoberega.player p inner join
pravoberega.events e on p.player_id = e.player_id_1)
where e.type in ('ж'))
union all
(SELECT name, 0 as ЖК, 1 as КК
FROM(pravoberega.player p inner join
pravoberega.events e on p.player_id = e.player_id_1)
where e.type in ('к'))) as cards
group by name
having sum(ЖК) > 2 or sum(КК) > 0;

-- Вывести результат всех игр команды Феникс
SELECT tour_id, t.name as team_1, счет, t2.name as team_2 FROM
((SELECT tour_id, team_id_1, goal_1 ||':'|| goal_2 as счет, team_id_2 FROM
(SELECT tour_id, team_id_1, team_id_2,
sum(goal_1) over (partition by tour_id) as goal_1,
sum(goal_2) over (partition by tour_id) as goal_2
FROM
((SELECT tour_id, team_id_1, team_id_2, 1 as goal_1, 0 as goal_2 FROM pravoberega.match m
left join pravoberega.events e on
m.match_id = e.match_id
where (m.team_id_1 = 3 or m.team_id_2 = 3) and e.type in ('г1', 'а1', 'ш1', 'п1'))
union ALL
(SELECT tour_id, team_id_1, team_id_2, 0 as goal_1, 1 as goal_2 FROM pravoberega.match m
left join pravoberega.events e on
m.match_id = e.match_id
where (m.team_id_1 = 3 or m.team_id_2 = 3) and e.type in ('г2', 'а2', 'ш2', 'п2'))) as tmp) as t
group by tour_id, team_id_1, team_id_2, goal_1, goal_2) as first_table
left join pravoberega.team t on first_table.team_id_1 = t.team_id
left join pravoberega.team t2 on first_table.team_id_2 = t2.team_id);
