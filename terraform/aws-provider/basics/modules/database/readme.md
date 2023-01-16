## Connection using the root account (login password) :

```

set AWS_REGION (aws configure get region)

set RDSHOST (aws secretsmanager get-secret-value --secret-id '/DEMO/test/database/credentials' --region $AWS_REGION | jq -r '.SecretString' | jq -r '.host')
set RDSPORT (aws secretsmanager get-secret-value --secret-id '/DEMO/test/database/credentials' --region $AWS_REGION | jq -r '.SecretString' | jq -r '.port')
set DBNAME (aws secretsmanager get-secret-value --secret-id '/DEMO/test/database/credentials' --region $AWS_REGION | jq -r '.SecretString' | jq -r '.dbname')


set PG_ROOT_USER (aws secretsmanager get-secret-value --secret-id '/DEMO/test/database/credentials' --region $AWS_REGION | jq -r '.SecretString' | jq -r '.username')
set PG_ROOT_PASSWORD (aws secretsmanager get-secret-value --secret-id '/DEMO/test/database/credentials' --region $AWS_REGION | jq -r '.SecretString' | jq -r '.password')
docker run -it --env PGPASSWORD=$PG_ROOT_PASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PG_ROOT_USER -d $DBNAME -c 'SELECT current_user;'
```


## Connection using IAM 

/!\ the user must have a policy Allowing rds-db:connect.

### First you need to create one PG role (database_role_1):

```
docker run -it --env PGPASSWORD=$PG_ROOT_PASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PG_ROOT_USER -d $DBNAME -c "
  DROP ROLE IF EXISTS database_role_1; 
  CREATE ROLE database_role_1 WITH LOGIN;
  GRANT rds_iam TO database_role_1;
  ALTER ROLE database_role_1 SET log_statement TO 'all';
"
```

See documentation for log_statement : https://postgresqlco.nf/doc/fr/param/log_statement/

### Then generate a temporary token for this role :

```
set PGUSER database_role_1
set PGPASSWORD (aws rds generate-db-auth-token --hostname $RDSHOST --port $RDSPORT --region $AWS_REGION --username $PGUSER)

docker run -it --env PGPASSWORD=$PGPASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PGUSER -d $DBNAME -c 'SELECT current_user;'
```

### Going further :

#### Create a dummy table scientist with database_role_1

```
docker run -it --env PGPASSWORD=$PGPASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PGUSER -d $DBNAME -c "
	DROP TABLE IF EXISTS scientist;
	CREATE TABLE scientist (id integer, firstname varchar(100), lastname varchar(100));
	INSERT INTO scientist (id, firstname, lastname) VALUES (1, 'albert', 'einstein');
	INSERT INTO scientist (id, firstname, lastname) VALUES (2, 'isaac', 'newton');
	INSERT INTO scientist (id, firstname, lastname) VALUES (3, 'marie', 'curie');"
```

#### Create a new role database_role_2 (using root account)

```
docker run -it --env PGPASSWORD=$PG_ROOT_PASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PG_ROOT_USER -d $DBNAME -c "
  DROP ROLE IF EXISTS database_role_2; 
  CREATE ROLE database_role_2 WITH LOGIN INHERIT;
  GRANT rds_iam TO database_role_2;
  ALTER ROLE database_role_2 SET log_statement TO 'all';" 
```

#### Change user (database_role_2) 

```
set PGUSER database_role_2
set PGPASSWORD (aws rds generate-db-auth-token --hostname $RDSHOST --port $RDSPORT --region $AWS_REGION --username $PGUSER)
docker run -it --env PGPASSWORD=$PGPASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PGUSER -d $DBNAME -c 'SELECT current_user;'
```

#### Check the ownership of table scientist

`docker run -it --env PGPASSWORD=$PGPASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PGUSER -d $DBNAME -c "select * from pg_tables where tablename = 'scientist'";`


#### Insert into the table own by another user :

`docker run -it --env PGPASSWORD=$PGPASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PGUSER -d $DBNAME -c "INSERT INTO scientist (firstname, lastname) VALUES ('database_role_2', 'database_role_2');"`

=> ERROR:  permission denied for table scientist
We need to have the same right than database_role_1 to make it work

`docker run -it --env PGPASSWORD=$PG_ROOT_PASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PG_ROOT_USER -d $DBNAME -c "GRANT database_role_1 TO database_role_2;"`

Now, the previous command work correctly without any permission deny.

#### Dropping a user that own some object :

Let's create a dummy function on own by database_role_2

```
docker run -it --env PGPASSWORD=$PGPASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PGUSER -d $DBNAME -c "
	DROP FUNCTION IF EXISTS add; 
	CREATE FUNCTION add(integer, integer) RETURNS integer
    AS 'select \$1 + \$2;'
    LANGUAGE SQL
    IMMUTABLE
    RETURNS NULL ON NULL INPUT;SELECT add(5,6);"
```

Trying to drop the user :

`docker run -it --env PGPASSWORD=$PG_ROOT_PASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PG_ROOT_USER -d $DBNAME -c "DROP ROLE IF EXISTS database_role_2;"`

=> ERROR:  role "database_role_2" cannot be dropped because some objects depend on it

We need to reassign all own by the user to another one :

```
docker run -it --env PGPASSWORD=$PG_ROOT_PASSWORD --rm postgres:latest psql -h host.docker.internal -p 5432 -U $PG_ROOT_USER -d $DBNAME -c "
	DROP ROLE IF EXISTS change_owner;
	CREATE ROLE change_owner;
	GRANT database_role_2 TO change_owner;
	GRANT change_owner TO postgres;
	REASSIGN OWNED BY database_role_2 TO change_owner;
	REASSIGN OWNED BY change_owner TO postgres;
	DROP ROLE IF EXISTS database_role_2;
	DROP ROLE IF EXISTS change_owner;"
```

Now the drop of database_role_2 should work.
