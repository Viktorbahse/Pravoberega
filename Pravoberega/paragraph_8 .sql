create view goal_statistics as	 
	with goals(match_id, team_id_1,team_id_2, type) as (
		select m.match_id, team_id_1,team_id_2, type from pravoberega.Match as m inner join pravoberega.Events as e on m.match_id=e.match_id where e.type in ('г1', 'г2', 'а1', 'а2', 'п1', 'п2', 'ш1', 'ш2')
	),
	first_team_goals(match_id, count_goals) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'г1' GROUP BY match_id
	),
	first_team_frees(match_id, count_frees) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'ш1' GROUP BY match_id
	),
	first_team_penalty(match_id, count_penalty) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'п1' GROUP BY match_id
	),
	first_team_auto(match_id, count_auto) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'а2' GROUP BY match_id
	),
	second_team_goals(match_id, count_goals) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'г2' GROUP BY match_id
	),
	second_team_frees(match_id, count_frees) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'ш2' GROUP BY match_id
	),
	second_team_penalty(match_id, count_penalty) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'п2' GROUP BY match_id
	),
	second_team_auto(match_id, count_auto) as(
		SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type = 'а1' GROUP BY match_id
	),
	match_result as (
		select m.match_id, m.tour_id, m.team_id_1, m.team_id_2,
		CASE 
		    WHEN ftg.count_goals IS NULL 
		    	THEN 0
		    ELSE ftg.count_goals
	   	END 
	   	AS first_team_goals,
	   	CASE 
		    WHEN stg.count_goals IS NULL 
		    	THEN 0
		    ELSE stg.count_goals
	   	END 
	   	AS second_team_goals,
	   	CASE 
		    WHEN ftf.count_frees IS NULL 
		    	THEN 0
		    ELSE ftf.count_frees
	   	END 
	   	AS first_team_frees,
	   	CASE 
		    WHEN stf.count_frees IS NULL 
		    	THEN 0
		    ELSE stf.count_frees
	   	END 
	   	AS second_team_frees,
	   	CASE 
		    WHEN ftp.count_penalty IS NULL 
		    	THEN 0
		    ELSE ftp.count_penalty
	   	END 
	   	AS first_team_penalty,
	   	CASE 
		    WHEN stp.count_penalty IS NULL 
		    	THEN 0
		    ELSE stp.count_penalty
	   	END 
	   	AS second_team_penalty,
	   	CASE 
		    WHEN fta.count_auto IS NULL 
		    	THEN 0
		    ELSE fta.count_auto
	   	END 
	   	AS first_team_auto,
	   	CASE 
		    WHEN sta.count_auto IS NULL 
		    	THEN 0
		    ELSE sta.count_auto
	   	END 
	   	AS second_team_auto from pravoberega.match as m 
	   	left join first_team_goals as ftg on m.match_id=ftg.match_id 
	   	left join second_team_goals as stg on m.match_id=stg.match_id 
	   	left join first_team_frees as ftf on m.match_id=ftf.match_id 
	   	left join second_team_frees as stf on m.match_id=stf.match_id
	   	left join first_team_penalty as ftp on m.match_id=ftp.match_id
	   	left join second_team_penalty as stp on m.match_id=stp.match_id
	   	left join first_team_auto as fta on m.match_id=fta.match_id
	   	left join second_team_auto as sta on m.match_id=sta.match_id
	),
	Tournament_tours as(
		select t1.tournament_id, t2.tour_id from pravoberega.tournament as t1 
		inner join pravoberega.tour as t2 on t1.tournament_id=t2.tournament_id where t1.name='Высшая лига. Дивизион Поповой' and t1.season = 'Лето-осень 2024'
	),
	match_result_in_tournament as(
		select m.match_id, m.tour_id, m.team_id_1, m.team_id_2, 
		m.first_team_goals, m.second_team_goals, m.first_team_frees, m.second_team_frees,
		m.first_team_penalty, m.second_team_penalty, m.first_team_auto, m.second_team_auto  from match_result as m 
		inner join Tournament_tours as t on m.tour_id=t.tour_id
	),
	temp0 as(
		SELECT team_id_1 AS team_id FROM match_result_in_tournament UNION SELECT team_id_2 AS team_id FROM match_result_in_tournament
	),
	temp1 as(
	    select team_id_1 as team_id, sum(first_team_goals) from match_result_in_tournament group by team_id_1
	),		
	temp2 as(
	    select team_id_2 as team_id, sum(second_team_goals) from match_result_in_tournament group by team_id_2
	),
	temp3 as(
	    select team_id_1 as team_id, sum(first_team_frees) from match_result_in_tournament group by team_id_1
	),		
	temp4 as(
	    select team_id_2 as team_id, sum(second_team_frees) from match_result_in_tournament group by team_id_2
	),
	temp5 as(
	    select team_id_1 as team_id, sum(first_team_penalty) from match_result_in_tournament group by team_id_1
	),		
	temp6 as(
	    select team_id_2 as team_id, sum(second_team_penalty) from match_result_in_tournament group by team_id_2
	),
	temp7 as(
	    select team_id_1 as team_id, sum(first_team_auto) from match_result_in_tournament group by team_id_1
	),		
	temp8 as(
	    select team_id_2 as team_id, sum(second_team_auto) from match_result_in_tournament group by team_id_2
	),
	temp9 as(
		select t0.team_id,
		CASE
			WHEN t1.sum IS NULL and t2.sum is null THEN 0
			WHEN t1.sum IS NULL then t2.sum
			when t2.sum is null then t1.sum
			ELSE (t1.sum+t2.sum)
	    	END AS G,
	    	CASE
			WHEN t3.sum IS NULL and t4.sum is null THEN 0
			WHEN t3.sum IS NULL then t4.sum
			when t4.sum is null then t3.sum
			ELSE (t3.sum+t4.sum)
	    	END AS F,
	    	CASE
			WHEN t5.sum IS NULL and t6.sum is null THEN 0
			WHEN t5.sum IS NULL then t6.sum
			when t6.sum is null then t5.sum
			ELSE (t5.sum+t6.sum)
	    	END AS P,
	    	CASE
			WHEN t7.sum IS NULL and t8.sum is null THEN 0
			WHEN t7.sum IS NULL then t8.sum
			when t8.sum is null then t7.sum
			ELSE (t7.sum+t8.sum)
	    	END AS A
	    	from temp0 as t0 
	    	left join temp1 as t1 on t0.team_id=t1.team_id
	    	left join temp2 as t2 on t0.team_id=t2.team_id
	    	left join temp3 as t3 on t0.team_id=t3.team_id
	    	left join temp4 as t4 on t0.team_id=t4.team_id
	    	left join temp5 as t5 on t0.team_id=t5.team_id
	    	left join temp6 as t6 on t0.team_id=t6.team_id
	    	left join temp7 as t7 on t0.team_id=t7.team_id
	    	left join temp8 as t8 on t0.team_id=t8.team_id
	) select t.name, t9.g, t9.f, t9.p, t9.a from pravoberega.team as t inner join temp9 as t9 on t.team_id=t9.team_id order by t.name;
	
/*Данное представление представляет собой статистику команд за турнир: число  "чисто" забитых мячей(g), число мячей забитых со штрафного(f), число мячей забитых с пенальти(p) и число автоголов (a).*/	

create view tournament_table as 
/*Для каждого матча считаем голы забитые первой командой*/
	with first_team_result(match_id, score) as(
		WITH goals(match_id, team_id_1,team_id_2, type) AS(
    			select m.match_id, team_id_1,team_id_2, type from pravoberega.Match as m 
    			inner join pravoberega.Events as e on m.match_id=e.match_id where e.type in ('г1', 'г2', 'а1', 'а2', 'п1', 'п2', 'ш1', 'ш2')
 		) SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type IN ('г1','а1','п1','ш1') GROUP BY match_id
	), 
/*Для каждого матча считаем голы забитые второй командой*/
	second_team_result(match_id, score) as( 
 		WITH goals(match_id, team_id_1,team_id_2, type) AS(
    			select m.match_id, team_id_1,team_id_2, type from pravoberega.Match as m 
    			inner join pravoberega.Events as e on m.match_id=e.match_id where e.type in ('г1', 'г2', 'а1', 'а2', 'п1', 'п2', 'ш1', 'ш2')
 		) SELECT match_id, COUNT(*) AS score FROM goals WHERE goals.type IN ('г2','а2','п2','ш2') GROUP BY match_id
 	), 
/*Объединяем данные из прошлых запросов с табличкой match*/
	match_result as(
		select m.match_id, m.tour_id, m.team_id_1, m.team_id_2, 
		CASE 
		    WHEN s1.score IS NULL 
		    	THEN 0
		    ELSE s1.score
	   	END 
	   	AS first_team_score,
	   	CASE 
		    WHEN s2.score IS NULL 
		    	THEN 0
		    ELSE s2.score
	   	END 
	   	AS second_team_score from pravoberega.match as m 
	   	left join first_team_result as s1 on m.match_id=s1.match_id 
	   	left join second_team_result as s2 on m.match_id=s2.match_id
   	),
/*Получаем id туров из интересующего нас турнира*/
	Tournament_tours as(
		select t1.tournament_id, t2.tour_id from pravoberega.tournament as t1 
		inner join pravoberega.tour as t2 on t1.tournament_id=t2.tournament_id where t1.name='Высшая лига. Дивизион Поповой' and t1.season = 'Лето-осень 2024'
	),
/*Убираем все лишние матчи(матчи из других турниров)*/
	match_result_in_tournament as(
		select m.match_id, m.tour_id, m.team_id_1, m.team_id_2, m.first_team_score, m.second_team_score from match_result as m 
		inner join Tournament_tours as t on m.tour_id=t.tour_id
	),
/*Для каждой команды считаем голы забитые матчах, в которых команда была под первым номером*/	
temp1 as(
    select team_id_1, sum(first_team_score) from match_result_in_tournament group by team_id_1
),
/*Для каждой команды считаем голы забитые матчах, в которых команда была под вторым номером*/		
temp2 as(
    select team_id_2, sum(second_team_score) from match_result_in_tournament group by team_id_2
), /*Для каждой команды считаем пропущенные голы в матчах, в которых команда была под первым номером*/		
temp3 as(
	select team_id_1, sum(second_team_score) from match_result_in_tournament group by team_id_1	
), /*Для каждой команды считаем пропущенные голы в матчах, в которых команда была под вторым номером*/
temp4 as(
    select team_id_2, sum(first_team_score) from match_result_in_tournament group by team_id_2
),/*Объединяем полученные данные*/
temp5 as(
    select t1.team_id_1, (t1.sum+t2.sum) as sum from temp1 as t1 join temp2 as t2 on t1.team_id_1=t2.team_id_2 
),/*Объединяем полученные данные*/
temp6 as(
    select t1.team_id_1, (t1.sum+t2.sum) as sum from temp3 as t1 join temp4 as t2 on t1.team_id_1=t2.team_id_2 
),/*Объединяем полученные данные*/
temp7 as(
select temp6.team_id_1 as team_id, temp5.sum as scored_goals, temp6.sum as conceded_goals from temp5 join temp6 on temp5.team_id_1=temp6.team_id_1
), /*Для каждой команды считаем количество матчей закончившихся ничьёй, в которых она была под первым номером*/
temp8 as(
	select team_id_1, count(*) as count from match_result_in_tournament where first_team_score=second_team_score group by team_id_1
),/*Для каждой команды считаем количество матчей закончившихся ничьёй, в которых она была под вторым номером*/
temp9 as(
	select team_id_2, count(*) as count from match_result_in_tournament where first_team_score=second_team_score group by team_id_2
), /*Для каждой команды считаем количество матчей закончившихся победой, в которых она была под первым номером*/
temp11 as(
	select team_id_1, count(*) as count from match_result_in_tournament where first_team_score>second_team_score group by team_id_1
),/*Для каждой команды считаем количество матчей закончившихся победой, в которых она была под вторым номером*/
temp12 as(
	select team_id_2, count(*) as count from match_result_in_tournament where first_team_score<second_team_score group by team_id_2
), /*Для каждой команды считаем количество матчей закончившихся поражением, в которых она была под первым номером*/
temp14 as(
	select team_id_1, count(*) as count from match_result_in_tournament where first_team_score<second_team_score group by team_id_1
), /*Для каждой команды считаем количество матчей закончившихся поражением, в которых она была под вторым номером*/
temp15 as(
	select team_id_2, count(*) as count from match_result_in_tournament where first_team_score>second_team_score group by team_id_2
), /*Объединяем полученные данные*/
temp16 as(
	select t7.team_id as team_id, t7.scored_goals, t7.conceded_goals,
	CASE
        	WHEN t11.count IS NULL and t12.count is null THEN 0
        	WHEN t11.count IS NULL then t12.count
        	when t12.count is null then t11.count
        	ELSE (t11.count+t12.count)
    	END AS V,
	CASE
        	WHEN t8.count IS NULL and t9.count is null THEN 0
        	WHEN t8.count IS NULL then t9.count
        	when t9.count is null then t8.count
        	ELSE (t8.count+t9.count)
    	END AS D,
    	CASE
        	WHEN t14.count IS NULL and t15.count is null THEN 0
        	WHEN t14.count IS NULL then t15.count
        	when t15.count is null then t14.count
        	ELSE (t15.count+t14.count)
    	END AS L from temp7 as t7 
    	left join temp8 as t8 on t7.team_id=t8.team_id_1 
    	left join temp9 as t9 on t7.team_id=t9.team_id_2 
    	left join temp11 as t11 on t7.team_id=t11.team_id_1 
    	left join temp12 as t12 on t7.team_id=t12.team_id_2 
    	left join temp14 as t14 on t7.team_id=t14.team_id_1 
    	left join temp15 as t15 on t7.team_id=t15.team_id_2
), /*Добавляем столбец очки*/
temp17 as (
	select t16.team_id, t16.scored_goals, t16.conceded_goals, t16.V, t16.D, t16.L, (3*t16.V+t16.D) as points from temp16 as t16
)select team.name, t17.scored_goals, t17.conceded_goals, t17.V, t17.D, t17.L, t17.points from pravoberega.team as team 
inner join temp17 as t17 on team.team_id=t17.team_id order by t17.points DESC
/*Данное представление является статистикой команд за турнир. Для каждой команды посчитано число забитый мячей, пропущенных мячей, количество победных, ничейных и проигранных матчей, а также число заработанных очков.*/


 
