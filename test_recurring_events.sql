delete from event_recurrences;
delete from event_cancellations;
delete from events;

/*NEW WEEKLY EVENT */
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation) values (100,'2019-08-12', '2019-08-12', 'weekly', 'UTC', 1);

insert into event_recurrences (event_id, day) values (100, 1);
insert into event_recurrences (event_id, day) values (100, 2);
insert into event_recurrences (event_id, day) values (100, 3);
insert into event_recurrences (event_id, day) values (100, 4);
insert into event_recurrences (event_id, day) values (100, 5);
END;

select * from recurring_events_for('2019-08-12 08:00am', '2019-08-31 12:00pm', 'UTC', NULL) WHERE id = 100 ORDER BY starts_on
/*RESULTS
100;"2019-08-12";"2019-08-12";"";"";"weekly";1;;"";"UTC"
100;"2019-08-13";"2019-08-13";"";"";"weekly";1;;"";"UTC"
100;"2019-08-14";"2019-08-14";"";"";"weekly";1;;"";"UTC"
100;"2019-08-15";"2019-08-15";"";"";"weekly";1;;"";"UTC"
100;"2019-08-16";"2019-08-16";"";"";"weekly";1;;"";"UTC"
100;"2019-08-19";"2019-08-19";"";"";"weekly";1;;"";"UTC"
100;"2019-08-20";"2019-08-20";"";"";"weekly";1;;"";"UTC"
100;"2019-08-21";"2019-08-21";"";"";"weekly";1;;"";"UTC"
100;"2019-08-22";"2019-08-22";"";"";"weekly";1;;"";"UTC"
100;"2019-08-23";"2019-08-23";"";"";"weekly";1;;"";"UTC"
100;"2019-08-26";"2019-08-26";"";"";"weekly";1;;"";"UTC"
100;"2019-08-27";"2019-08-27";"";"";"weekly";1;;"";"UTC"
100;"2019-08-28";"2019-08-28";"";"";"weekly";1;;"";"UTC"
100;"2019-08-29";"2019-08-29";"";"";"weekly";1;;"";"UTC"
100;"2019-08-30";"2019-08-30";"";"";"weekly";1;;"";"UTC"
*/

/*INSERIMENTO EVENTO SETTIMANALE CON RICORRENZA OGNI SETTIMANA SOLO IL MARTEDI E GIOVEDI*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation) values (111,'2019-08-12', '2019-08-12', 'weekly', 'UTC', 1);

insert into event_recurrences (event_id, day) values (111, 2);
insert into event_recurrences (event_id, day) values (111, 4);
END;

select * from recurring_events_for('2019-08-12 08:00am', '2019-08-31 12:00pm', 'UTC', NULL) WHERE id = 111 ORDER BY starts_on
/*RESULTS:
111;"2019-08-12";"2019-08-12";"";"";"weekly";1;;"";"UTC"
111;"2019-08-13";"2019-08-13";"";"";"weekly";1;;"";"UTC"
111;"2019-08-15";"2019-08-15";"";"";"weekly";1;;"";"UTC"
111;"2019-08-20";"2019-08-20";"";"";"weekly";1;;"";"UTC"
111;"2019-08-22";"2019-08-22";"";"";"weekly";1;;"";"UTC"
111;"2019-08-27";"2019-08-27";"";"";"weekly";1;;"";"UTC"
111;"2019-08-29";"2019-08-29";"";"";"weekly";1;;"";"UTC"
*/

/*WEEKLY EVENT */
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation) values (112,'2019-08-12', '2019-08-12', 'weekly', 'UTC', 1);

insert into event_recurrences (event_id, day) values (112, 3);
insert into event_recurrences (event_id, day) values (112, 4);
insert into event_recurrences (event_id, day) values (112, 5);
END;
select * from recurring_events_for('2019-08-12 08:00am', '2019-08-31 12:00pm', 'UTC', NULL) WHERE id = 112 ORDER BY starts_on

/*WEEKLY EVENT WITH RECURRING EVERY TWO WEEKS*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation) values (101,'2019-08-12', '2019-08-12', 'weekly', 'UTC', 2);

insert into event_recurrences (event_id, day) values (101, 1);
insert into event_recurrences (event_id, day) values (101, 2);
insert into event_recurrences (event_id, day) values (101, 3);
insert into event_recurrences (event_id, day) values (101, 4);
insert into event_recurrences (event_id, day) values (101, 5);
END;

select * from recurring_events_for('2019-08-12 08:00am', '2019-10-01 12:00am', 'UTC', NULL) WHERE id = 101 ORDER BY starts_on
/*
IT RETURNS WRONG RESULTS BEFORE CORRECTION

101;"2019-08-12";"2019-08-12";"";"";"weekly";2;;"";"UTC"
101;"2019-08-15";"2019-08-15";"";"";"weekly";2;;"";"UTC"
101;"2019-08-16";"2019-08-16";"";"";"weekly";2;;"";"UTC"
101;"2019-08-17";"2019-08-17";"";"";"weekly";2;;"";"UTC"
101;"2019-08-18";"2019-08-18";"";"";"weekly";2;;"";"UTC"
101;"2019-08-19";"2019-08-19";"";"";"weekly";2;;"";"UTC"
101;"2019-08-29";"2019-08-29";"";"";"weekly";2;;"";"UTC"
101;"2019-08-30";"2019-08-30";"";"";"weekly";2;;"";"UTC"
101;"2019-08-31";"2019-08-31";"";"";"weekly";2;;"";"UTC"
101;"2019-09-01";"2019-09-01";"";"";"weekly";2;;"";"UTC"
101;"2019-09-02";"2019-09-02";"";"";"weekly";2;;"";"UTC"
101;"2019-09-12";"2019-09-12";"";"";"weekly";2;;"";"UTC"
101;"2019-09-13";"2019-09-13";"";"";"weekly";2;;"";"UTC"
101;"2019-09-14";"2019-09-14";"";"";"weekly";2;;"";"UTC"
101;"2019-09-15";"2019-09-15";"";"";"weekly";2;;"";"UTC"
101;"2019-09-16";"2019-09-16";"";"";"weekly";2;;"";"UTC"
101;"2019-09-26";"2019-09-26";"";"";"weekly";2;;"";"UTC"
101;"2019-09-27";"2019-09-27";"";"";"weekly";2;;"";"UTC"
101;"2019-09-28";"2019-09-28";"";"";"weekly";2;;"";"UTC"
101;"2019-09-29";"2019-09-29";"";"";"weekly";2;;"";"UTC"
101;"2019-09-30";"2019-09-30";"";"";"weekly";2;;"";"UTC"

AFTER CORRECTION IT RETURNS THE CORRECT RESULTS

101;"2019-08-12";"2019-08-12";"";"";"weekly";2;;"";"UTC"
101;"2019-08-13";"2019-08-13";"";"";"weekly";2;;"";"UTC"
101;"2019-08-14";"2019-08-14";"";"";"weekly";2;;"";"UTC"
101;"2019-08-15";"2019-08-15";"";"";"weekly";2;;"";"UTC"
101;"2019-08-16";"2019-08-16";"";"";"weekly";2;;"";"UTC"
101;"2019-08-26";"2019-08-26";"";"";"weekly";2;;"";"UTC"
101;"2019-08-27";"2019-08-27";"";"";"weekly";2;;"";"UTC"
101;"2019-08-28";"2019-08-28";"";"";"weekly";2;;"";"UTC"
101;"2019-08-29";"2019-08-29";"";"";"weekly";2;;"";"UTC"
101;"2019-08-30";"2019-08-30";"";"";"weekly";2;;"";"UTC"
101;"2019-09-09";"2019-09-09";"";"";"weekly";2;;"";"UTC"
101;"2019-09-10";"2019-09-10";"";"";"weekly";2;;"";"UTC"
101;"2019-09-11";"2019-09-11";"";"";"weekly";2;;"";"UTC"
101;"2019-09-12";"2019-09-12";"";"";"weekly";2;;"";"UTC"
101;"2019-09-13";"2019-09-13";"";"";"weekly";2;;"";"UTC"
101;"2019-09-23";"2019-09-23";"";"";"weekly";2;;"";"UTC"
101;"2019-09-24";"2019-09-24";"";"";"weekly";2;;"";"UTC"
101;"2019-09-25";"2019-09-25";"";"";"weekly";2;;"";"UTC"
101;"2019-09-26";"2019-09-26";"";"";"weekly";2;;"";"UTC"
101;"2019-09-27";"2019-09-27";"";"";"weekly";2;;"";"UTC"
*/


/*INSERIMENTO EVENTO SETTIMANALE CON RICORRENZA OGNI SETTIMANA PER 20 OCCORRENZE*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation, count) values (103,'2019-08-12', '2019-08-12', 'weekly', 'UTC', 1, 20);

insert into event_recurrences (event_id, day) values (103, 1);
insert into event_recurrences (event_id, day) values (103, 2);

insert into event_recurrences (event_id, day) values (103, 5);
END;

select * from recurring_events_for('2019-08-12 08:00am', '2019-09-30 12:00pm', 'UTC', NULL) WHERE id = 103 ORDER BY starts_on;






/*WEEKLY EVENT WITH 10 RECURRENCES*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation, count) values (104,'2019-08-12', '2019-08-12', 'weekly', 'UTC', 1, 10);

insert into event_recurrences (event_id, day) values (104, 1);
insert into event_recurrences (event_id, day) values (104, 2);
insert into event_recurrences (event_id, day) values (104, 3);
insert into event_recurrences (event_id, day) values (104, 4);
insert into event_recurrences (event_id, day) values (104, 5);
END;

select * from recurring_events_for('2019-08-12 08:00am', '2019-09-30 12:00pm', 'UTC', NULL) WHERE id = 104 ORDER BY starts_on;

/*WRONG BEFORE CORRECTION 

104;"2019-08-12";"2019-08-12";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-13";"2019-08-13";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-20";"2019-08-20";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-21";"2019-08-21";"";"";"weekly";1;10;"";"UTC"
104;"2019-09-03";"2019-09-03";"";"";"weekly";1;10;"";"UTC"
104;"2019-09-09";"2019-09-09";"";"";"weekly";1;10;"";"UTC"
104;"2019-09-10";"2019-09-10";"";"";"weekly";1;10;"";"UTC"
104;"2019-09-11";"2019-09-11";"";"";"weekly";1;10;"";"UTC"
104;"2019-09-19";"2019-09-19";"";"";"weekly";1;10;"";"UTC"
104;"2019-09-25";"2019-09-25";"";"";"weekly";1;10;"";"UTC"

AFTER
104;"2019-08-12";"2019-08-12";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-13";"2019-08-13";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-14";"2019-08-14";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-15";"2019-08-15";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-16";"2019-08-16";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-19";"2019-08-19";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-20";"2019-08-20";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-21";"2019-08-21";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-22";"2019-08-22";"";"";"weekly";1;10;"";"UTC"
104;"2019-08-23";"2019-08-23";"";"";"weekly";1;10;"";"UTC"
*/

/*PROVA INSERIMENTO EVENTO GIORNALIERO  CON RICORRENZA OGNI 14 GG PER 10 OCCORRENZE*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation) values (113,'2019-08-12', '2019-08-12', 'daily', 'UTC', 14);

insert into event_recurrences (event_id, day) values (113, 1);
insert into event_recurrences (event_id, day) values (113, 2);
insert into event_recurrences (event_id, day) values (113, 3);
insert into event_recurrences (event_id, day) values (113, 4);
insert into event_recurrences (event_id, day) values (113, 5);
END;

select * from recurring_events_for('2019-08-12 08:00am', '2019-09-30 12:00pm', 'UTC', NULL) WHERE id = 113 ORDER BY starts_on;
/*NON FUNZIONA*/





/*INSERIMENTO EVENTO SETTIMANALE CON RICORRENZA OGNI SETTIMANA PER 10 OCCORRENZE, PROVO CON ENDS_ON  A NULL*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation, count) values (105,'2019-08-12', NULL, 'weekly', 'UTC', 1, 10);

insert into event_recurrences (event_id, day) values (105, 1);
insert into event_recurrences (event_id, day) values (105, 2);
insert into event_recurrences (event_id, day) values (105, 3);
insert into event_recurrences (event_id, day) values (105, 4);
insert into event_recurrences (event_id, day) values (105, 5);
END;
/*TOTALMENTE ERRATO produce i seguenti risultati*/
select * from recurring_events_for('2019-08-12 08:00am', '2019-09-30 12:00pm', 'UTC', NULL) WHERE id = 105 ORDER BY starts_on;
105;"2019-08-12";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-08-13";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-08-20";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-08-21";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-09-03";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-09-09";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-09-10";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-09-11";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-09-19";"";"";"";"weekly";1;10;"";"UTC"
105;"2019-09-25";"";"";"";"weekly";1;10;"";"UTC"

/*INSERIMENTO EVENTO SETTIMANALE CON RICORRENZA OGNI SETTIMANA PER 10 OCCORRENZE, PROVO CON ENDS_ON  A NULL*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation, count) values (106,'2019-10-12', '2019-10-12', 'weekly', 'UTC', 1, 30);

insert into event_recurrences (event_id, day) values (106, 1);
insert into event_recurrences (event_id, day) values (106, 2);
insert into event_recurrences (event_id, day) values (106, 3);
insert into event_recurrences (event_id, day) values (106, 4);
insert into event_recurrences (event_id, day) values (106, 5);
END;
select * from recurring_events_for('2019-10-12 08:00am', '2019-11-30 12:00pm', 'UTC', NULL) WHERE id = 106 ORDER BY starts_on;



/*INSERIMENTO EVENTO SETTIMANALE CON RICORRENZA OGNI SETTIMANA PER 10 OCCORRENZE, PROVO CON ENDS_ON  A NULL*/
BEGIN;

insert into events (id,starts_on, ends_on, frequency,timezone_name, separation, count) values (107,'2019-08-12', '2019-10-12', 'weekly', 'UTC', 1, 30);

insert into event_recurrences (event_id, day) values (107, 1);
insert into event_recurrences (event_id, day) values (107, 2);
insert into event_recurrences (event_id, day) values (107 3);
insert into event_recurrences (event_id, day) values (107 4);
insert into event_recurrences (event_id, day) values (107, 5);
insert into event_recurrences (event_id, day) values (107, 6);
insert into event_recurrences (event_id, day) values (107, 7);

END;
select *
from events e left join
event_recurrences er on e.id =er.event_id
where e.id = 113 AND er.month IS NULL;



select * from recurring_events_for('2019-08-12 08:00am', '2019-08-31 12:00pm', 'UTC', NULL) WHERE id = 200 ORDER BY starts_on

