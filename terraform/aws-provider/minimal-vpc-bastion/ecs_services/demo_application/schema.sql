--PostgreSQL 9.6
--'\\' is a delimiter

DROP TABLE IF EXISTS scientist;
DROP TABLE IF EXISTS t_random;

CREATE TABLE scientist (id integer, firstname varchar(100), lastname varchar(100));
INSERT INTO scientist (id, firstname, lastname) VALUES (1, 'albert', 'einstein');
INSERT INTO scientist (id, firstname, lastname) VALUES (2, 'isaac', 'newton');
INSERT INTO scientist (id, firstname, lastname) VALUES (3, 'marie', 'curie');


CREATE TABLE t_random AS
SELECT gs, 
	md5(random()::text), cast(cast(random() AS integer) AS boolean) AS bool1,
	cast(cast(random() AS integer) AS boolean) AS bool2,
	trunc(random() * 5 + 1) AS enum
FROM generate_Series(1, 4000) AS gs;

DROP INDEX IF EXISTS t_random_enum_idx;
CREATE INDEX t_random_enum_idx ON t_random(enum);

DROP INDEX IF EXISTS t_random_bool1_idx;
CREATE INDEX t_random_bool1_idx ON t_random(bool1);

DROP INDEX  IF EXISTS t_random_enum_bool1_idx;
CREATE INDEX t_random_enum_bool1_idx ON t_random(enum, bool1);
