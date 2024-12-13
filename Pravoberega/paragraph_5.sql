INSERT INTO pravoberega.Player VALUES(95, NULL, 'Аврора Романова', '2000.01.01', NULL, FALSE);
INSERT INTO pravoberega.Player VALUES(96, NULL, 'Мария Иглесиаса', '2001.02.24', NULL, FALSE);
INSERT INTO pravoberega.Player VALUES(97, NULL, 'Каралина Маркарян', '1998.11.13', NULL, FALSE);
INSERT INTO pravoberega.Player VALUES(98, NULL, 'Елена Головач', '1999.03.17', NULL, FALSE);
update pravoberega.Player set Date_of_birth ='2000.10.01' where Name='Аврора Романова';
update pravoberega.Player set Capitan = TRUE where Name='Каралина Маркарян';
update pravoberega.Player set Date_of_birth = '2003.03.17' where Name='Елена Головач';
INSERT INTO pravoberega.Reward VALUES(8, 95, 'Золотой мяч ЧМ');
INSERT INTO pravoberega.Reward VALUES(9, 96, 'Globe Soccer Awards');
INSERT INTO pravoberega.Reward VALUES(10, 98, 'Приз «Вратарь года»');
update pravoberega.Reward set Reward_type = 'Приз «Вратарь года» имени Льва Яшина' where Reward_id=10;
/*Все награды.*/
select * from pravoberega.Reward;
INSERT INTO pravoberega.Reward VALUES(011, 0001, 'Лучший игрок');
INSERT INTO pravoberega.Reward VALUES(012, 0004, 'Лучший игрок');
INSERT INTO pravoberega.Reward VALUES(013, 0023, 'Лучший игрок');
INSERT INTO pravoberega.Reward VALUES(014, 0012, 'Лучший игрок');
INSERT INTO pravoberega.Reward VALUES(015, 0039, 'Лучший бомбардир');
INSERT INTO pravoberega.Reward VALUES(016, 0030, 'Лучший бомбардир');
INSERT INTO pravoberega.Reward VALUES(017, 0017, 'Лучший бомбардир');
INSERT INTO pravoberega.Reward VALUES(018, 009, 'Лучший бомбардир');
/*Имена всех играков, которые являются капитанами и родились в периуд с 2000-01-01 по 2005-12-31.*/
select Player.Name from pravoberega.Player where Player.Capitan is TRUE and Date_of_birth BETWEEN '2000-01-01' AND '2005-12-31';
/*Для каждой награды вывести имя самого "старого" человека, ее получившего.*/
with reward_and_player(reward_type, name, date_of_birth) as
(
   select r.reward_type, p.name, p.date_of_birth from pravoberega.player as p inner join pravoberega.reward as r on r.player_id=p.player_id
) select reward_type, name, date_of_birth
from reward_and_player as a where date_of_birth = (select MIN(date_of_birth) from reward_and_player where reward_type = a.reward_type)
ORDER BY reward_type;
INSERT INTO pravoberega.Reward VALUES(019, 0004, 'Лучший игрок');
INSERT INTO pravoberega.Reward VALUES(020, 0004, 'Лучший игрок');
INSERT INTO pravoberega.Reward VALUES(021, 0004, 'Лучший игрок');
/*Игрок с самым большим числом наград*/
with PlayerRewards as (
    with reward_and_player(reward_type, name) as
    (
        select r.reward_type, p.name from pravoberega.player as p inner join pravoberega.reward as r on r.player_id=p.player_id
    )
    select name, COUNT(reward_type) as quantity
    from reward_and_player
    group by name
)
select name, quantity from PlayerRewards where PlayerRewards.quantity = (select max(quantity) from PlayerRewards);

delete from pravoberega.Reward where Reward_id > 7;
delete from pravoberega.Player where Player_id in(95,96,97,98);

