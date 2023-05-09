This test aims to reproduce some DB errors described in https://github.com/fractal-analytics-platform/fractal-server/issues/647. Note that passing to fractal-server=1.2.3 solved (or at least greatly mitigated) the current issue, but we are leaving the README here for the record.

It is meant to provide a systematic way of stress-testing `fractal-server` in different configurations:

1. With a SQLite or postgres db;
2. With uvicorn or gunicorn (and possibly with multiple workers);


One run of `run_example.sh` corresponds to a 20+20 test (add 20 tasks to a workflow, and run a workflow 20 times in a row). The most comprehensive test we have is to run several 20+20 tests in parallel. Depending on the configuration, we observed a few different errors appearing (likely all related to concurrent DB connections):
* `sqlite3.OperationalError: database is locked`, then resulting in `httpx.ReadTimeout` on the `fractal` client side;
* `sqlalchemy.exc.TimeoutError: QueuePool limit of size 5 overflow 10 reached, connection timed out, timeout 30.00 (Background on this error at: https://sqlalche.me/e/14/3o7r)`;
* `sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) connection to server at "localhost" (127.0.0.1), port 5432 failed: FATAL:  sorry, too many clients already`.


When a certain `fractal-server` configuration leads to an error, the simplest mitigation strategy is to reduce the API call frequency (e.g. by adding a one-second waiting time between subsequent calls), but this is only meant to be used while testing.

# 2023/05/02 tests

(with fractal-server 1.2.4)

## sqlite

Bugged? See https://github.com/fractal-analytics-platform/fractal-server/issues/661

## uvicorn+postgres

* One 20+20 example goes through.
* Two simultaneous 20+20 examples may still fail with a client-side timeout (but no server-side errors).

## gunicorn+postgres

* With a single worker, two simultaneous 20+20 examples go through. The `lsof -i :5432` command never shows more than three open connections.


# 2023/04/27 tests

(with fractal-server 1.2.2)

## uvicorn+sqlite

In this case, the server startup was through the usual single-worker uvicorn command:
```
fractalctl start
```

To configure SQLite, we addded these variables to the `.fractal_server.env` file
```
DB_ENGINE=sqlite
SQLITE_PATH=db/fractal_server.db
```
and the db was initialized with `fractalctl set-db`.

We observed a case where running two/three simultaneous tests leads to the `sqlite3.OperationalError: database is locked` (on the `fractal-server` side), then leading to `httpx.ReadTimeout` on the `fractal` client side.
After the error appears the first time, the databse remains locked and any call via the `fractal` client (e.g. `fractal task list`) fails with a timeout error.

Note: out of a handful of attempts, there is no systematic position where the test fails (that is, it can fail either during the 20 WorkflowTask insertions or during the 20 workflow-apply calls).

## gunicorn+sqlite

We run gunicorn, with a certain number of workers, as in
```
NUM_WORKERS=1
gunicorn fractal_server.main:app --workers $NUM_WORKERS --worker-class uvicorn.workers.UvicornWorker --bind 127.0.0.1:8010 --access-logfile -
```

For `NUM_WORKERS=1` or `NUM_WORKERS=2`, we end up with the same situation as in the "uvicorn+sqlite" case: locked-database errors server-side, and then timeout errors client-side.
Increasing the number of workers (e.g. `NUM_WORKERS=4`) partly mitigates the problem (the error takes place later during the execution, and the `fractal-server` instance is still reachable), but the error (`database is locked` server side, and timeouts client side) is still there.

Increasing `NUM_WORKERS` even further (e.g. to `8`) apparently solves the problem, but if we look at the db-file in a moment after all tests started (that is, after all API calls were already made) there are still quite a few processes (8 processes, that is, all workers) connected to it:
```
$ fuser ../../server/db/fractal_server.db 

/somewhere/fractal-demos/examples/server/db/fractal_server.db: 60012 60013 60016 60017 60018 60019 60021 60022
```
This is partly expected, because fractal-server still connects to the DB at the beginning/end of workflow execution, but we need to make sure that the connections are not active _during_ workflow execution.

Note that the final cleanup is done correctly, because the situation after all workflow executions are over is the expected one:
* `fractal-server` running
* `fuser` showing that there is no active connection to `fractal_server.db`

## uvicorn+postgres

In this case, the server startup was through the usual single-worker uvicorn command:
```
fractalctl start
```

To configure postgres, we first restarted the db as in
```
$ psql -U fractal -h 127.0.0.1 -d postgres
Password for user fractal: 
psql (14.7 (Ubuntu 14.7-0ubuntu0.22.04.1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, bits: 256, compression: off)
Type "help" for help.

postgres=# drop database fractal;
DROP DATABASE
postgres=# create database fractal;
CREATE DATABASE
```
and then added these variables to the `.fractal_server.env` file (see also https://github.com/fractal-analytics-platform/fractal-server/issues/388#issuecomment-1366713291):
```
DB_ENGINE=postgres
POSTGRES_USER=fractal
POSTGRES_PASSWORD=XXXXXXXXXXXXXXXX
POSTGRES_SERVER=localhost
POSTGRES_PORT=5432
POSTGRES_DB=fractal
```
so that the db can be initialized as in
```
$ fractalctl set-db
Run alembic.config, with argv=['-c', '/home/tommaso/miniconda3/envs/fractal-server-1.2.2/lib/python3.9/site-packages/fractal_server/alembic.ini', 'upgrade', 'head']
fractal_server.app.db
INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
INFO  [alembic.runtime.migration] Will assume transactional DDL.
INFO  [alembic.runtime.migration] Running upgrade  -> 47072e0106ce, Initial schema
INFO  [alembic.runtime.migration] Running upgrade 47072e0106ce -> 385aa8c18489, Add user.cache_dir
INFO  [alembic.runtime.migration] Running upgrade 385aa8c18489 -> 6dede8d6fd9d, Drop project.project_dir
```

Running a single 20+20 example still fails; the server-side error is `QueuePool limit of size 5 overflow 10 reached, connection timed out, timeout 30.00 (Background on this error at: https://sqlalche.me/e/14/3o7r)`, which then leads to timeouts client-side. Note that, at a difference with the uvicorn+sqlite example, the DB is not locked and we can successfully make other calls to it (e.g. via `fractal task list`).


## gunicorn+postgres

We set up a postgres db, and we run gunicorn, with a certain number of workers, as in
```
NUM_WORKERS=1
gunicorn fractal_server.main:app --workers $NUM_WORKERS --worker-class uvicorn.workers.UvicornWorker --bind 127.0.0.1:8010 --access-logfile -
```

* Once again, even running a single 20+20 test leads to an error (with `NUM_WORKERS=1`).
* Having `NUM_WORKERS=4` also leads to an error (e.g. when running three 20+20 tests)
* Setting an even higher number of workers (e.g. `8`) eventually also fails, with a different error (`sqlalchemy.exc.OperationalError: (psycopg2.OperationalError) connection to server at "localhost" (127.0.0.1), port 5432 failed: FATAL:  sorry, too many clients already`).

## Debugging DB connections

Before shutting down the `fractal-server` instance, there appears to be several open connections to the postgres port (5432).
Starting with a fresh DB+fractal-server, and after running a single 20+20 test, we observe
```
$ lsof -i :5432  | wc -l
62
```
where the entries look like
```
$ lsof -i :5432 | head
COMMAND    PID    USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
gunicorn 65684 tommaso   13u  IPv4 1997489      0t0  TCP localhost:50706->localhost:postgresql (ESTABLISHED)
gunicorn 65684 tommaso   15u  IPv4 2006209      0t0  TCP localhost:39948->localhost:postgresql (ESTABLISHED)
```

After waiting a while (that is, after all workflow executions are complete), there are still 54 open connections listed in `lsof`. Shutting down the fractal-server instance (which happens without any error or warning), correctly leads to 0 open connections.


**To be understood**: what are those ~60 connections? Why are they still established?
