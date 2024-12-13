-- функция, которая принимает на вход заявку и статус команды (дома/гости).
-- Проверяет всех игроков заявки на наличие дисквалификаций
-- Проверяет все события матча, на который подана заявка, чтобы никакое из событий
-- не было реализовано игроком не из заявки.

create function check_match_application(int, int)
returns text as $$
DECLARE
player_count int := 0;
invalid_player_count int := 0;
match_num int := 0;

BEGIN

--проверка на наличие дисквалификаций у игроков из заявки
player_count = COUNT(DISTINCT ma.player_id) FROM (pravoberega.match_application_x_player ma
INNER JOIN pravoberega.disqualification d ON ma.player_id = d.player_id)
WHERE d.isCurrent = TRUE AND
ma.match_application_id = $1;
if player_count > 0
THEN
    return ('Attantion! Есть игроки с дисквалификациями.');
end if;

--Проверка, что все голы и голевые передачи реализованы игроками заявленной команды
if $2 = 1
THEN
    invalid_player_count = COUNT(*) FROM pravoberega.events e
    INNER join pravoberega.match_application ma
    on e.match_id = ma.match_id
    where ma.match_application_id = $1
    AND e.type in ('г1', 'а2', 'п1', 'ш1')
    AND (e.player_id_1 NOT IN (SELECT player_id
    FROM pravoberega.match_application_x_player
    where match_application_id = $1)
    or e.player_id_2 NOT IN (SELECT player_id
    FROM pravoberega.match_application_x_player
    where match_application_id = $1));
ELSE
    invalid_player_count = COUNT(*) FROM pravoberega.events e
    INNER join pravoberega.match_application ma
    on e.match_id = ma.match_id
    where ma.match_application_id = $1
    AND e.type in ('г2', 'а1', 'п2', 'ш2')
    AND (e.player_id_1 NOT IN (SELECT player_id
    FROM pravoberega.match_application_x_player
    where match_application_id = $1)
    or e.player_id_2 NOT IN (SELECT player_id
    FROM pravoberega.match_application_x_player
    where match_application_id = $1));
END IF;

if invalid_player_count > 0
THEN
return ('ERROR: какое-то из событий реализовано игроком, которого нет в заявке');
END IF;
return ('ok.');
END;
$$ language plpgsql;

------------------------------------------------------------------------------------

-- Функция, которая принимает на вход id матча.
-- Проверяет, чтобы на этот матч было подано ровно по одной заявке от двух игравших команд.
-- Запускает check_match_application() для каждой из заявок.

create function check_match(int)
returns text as $$

DECLARE
application_count int := 0;
team_num_1 int := 0;
team_num_2 int := 0;
appl_num_1 int := 0;
appl_num_2 int := 0;
output text := '';

BEGIN

-- проверяем, что на каждом матче ровно 2 заявки
application_count = COUNT(*) FROM pravoberega.match_application 
WHERE match_id = $1;
IF application_count != 2 THEN
return 'ERROR: Количество заявок на этот матч не равно двум!';
END IF;

--Проверяем, что заявки только от играющих команд
team_num_1 = (SELECT m.team_id_1
FROM pravoberega.match m WHERE match_id = $1);
team_num_2 = (SELECT m.team_id_2
FROM pravoberega.match m WHERE match_id = $1);
IF EXISTS (SELECT 1 FROM pravoberega.match_application
        WHERE match_id = $1 and team_id NOT IN (team_num_1, team_num_2)
    )
THEN
return 'ERROR: существует заявка на матч от команды, которая не принимает участие в матче.';
END IF;

-- Проверяем, что заявлены разные команды
if team_num_1 = team_num_2
THEN
return 'ERROR: одна команда заявлена дважды.';
END IF;


SELECT match_application_id INTO appl_num_1
FROM pravoberega.match_application WHERE match_id = $1 and team_id = team_num_1;
SELECT match_application_id INTO appl_num_2
FROM pravoberega.match_application WHERE match_id = $1 and team_id = team_num_2;

--проверка каждой из заявки
output = check_match_application(appl_num_1, 1);
if output = 'ok.'
THEN
return check_match_application(appl_num_2, 2);
END IF;
return output;

END;
$$ language plpgsql;