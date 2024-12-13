-- Проверка при добавлении/обновлении строки в таблице event.
-- Если добавили красную карточку в то время, как в матче у игрока уже есть 2 желтые,
-- желтые отмечаются другим флагом, чтобы не учитывать их в статистике.
-- На прямые красные карточки это не распрастраняется.

create or replace function tg_new_event_with_red_card()
returns trigger as $$
DECLARE
c int := 0;
BEGIN
    c = count(*) FROM pravoberega.events
    where match_id = new.match_id and
    player_id_1 = new.player_id_1 and type = 'ж';
    if new.type = 'к' and c = 2
    THEN
        update pravoberega.events set type = 'ж2' WHERE
        match_id = new.match_id and player_id_1 = new.player_id_1 and minut = new.minut and type = 'ж';
        update pravoberega.events set type = 'ж1' WHERE
        match_id = new.match_id and player_id_1 = new.player_id_1 and type = 'ж';
    END IF;
    return new;
END;
$$ language plpgsql;

CREATE trigger t1_new_event_with_rc
after insert or update on pravoberega.events
for each row execute function tg_new_event_with_red_card();


-- При изменении таблицы игроков, сохранять запись
-- об изменении в таблице history_of_player с указанием текущей даты

create or replace function tg_new_player()
returns trigger as $$
BEGIN
    if tg_op = 'DELETE'
    THEN
        INSERT INTO pravoberega.histori_of_player VALUES (old.player_id, NULL,
        old.name, old.date_of_birth, old.position, old.capitan, current_date);
    else
        INSERT INTO pravoberega.histori_of_player VALUES (new.player_id, new.team_id,
        new.name, new.date_of_birth, new.position, new.capitan, current_date);
    end if;
    return null;
END;
$$ language plpgsql;

CREATE trigger t1_new_player
after insert or update or delete on pravoberega.player
for each row execute function tg_new_player();