This test aims to reproduce some DB errors described in https://github.com/fractal-analytics-platform/fractal-server/issues/647.

It is meant to provide a systematic way of stress-testing `fractal-server` in different configurations:

1. With a SQLite or postgres db;
2. With uvicorn or gunicorn (and possibly with multiple workers);


One run of `run_example.sh` corresponds to a 20+20 test (add 20 tasks to a workflow, and run a workflow 20 times in a row). The most comprehensive test we have is to run several 20+20 tests in parallel. Depending on the configuration, we observed a few different errors appearing (likely all related to concurrent DB connections):
* `sqlite3.OperationalError: database is locked`, then resulting in `httpx.ReadTimeout` on the `fractal` client side;
* `sqlalchemy.exc.TimeoutError: QueuePool limit of size 5 overflow 10 reached, connection timed out, timeout 30.00 (Background on this error at: https://sqlalche.me/e/14/3o7r)`.


When a certain `fractal-server` configuration leads to an error, the simplest mitigation strategy is to reduce the API call frequency (e.g. by adding a one-second waiting time between subsequent calls), but this is only meant to be used while testing.

# 2023/04/27 tests

## uvicorn+sqlite

In this case, the server startup was through the usual single-worker uvicorn command:
```
fractalctl start
```

We observed a case where running two/three simultaneous tests leads to the `sqlite3.OperationalError: database is locked` (on the `fractal-server` side), then leading to `httpx.ReadTimeout` on the `fractal` client side.
After the error appears the first time, the databse remains locked and any call via the `fractal` client (e.g. `fractal task list`) fails with a timeout error.

Note: out of a handful of attempts, there is no systematic position where the test fails (that is, it can fail either during the 20 WorkflowTask insertions or during the 20 workflow-apply calls).

## gunicorn+sqlite

We run gunicorn, with a certain number of workers, as in
```
NUM_WORKERS=1
gunicorn fractal_server.main:app --workers $NUM_WORKERS --worker-class uvicorn.workers.UvicornWorker --bind 127.0.0.1:$PORT --access-logfile -
```

For `NUM_WORKERS=1` or `NUM_WORKERS=2`, we end up with the same situation as in "uvicorn+sqlite": locked-database errors server-side, and then timeout errors client-side.
Increasing the number of workers (e.g. `NUM_WORKERS=4`) partly mitigates the problem (the error takes place later during the execution, and the `fractal-server` instance is still reachable), but the error (`database is locked` server side, and timeouts client side) is still there.

Increasing `NUM_WORKERS` even further (e.g. to `8`) apparently solves the problem, but if we look at the db-file in a moment after all tests started (that is, after all API calls were already made) there are still quite a few processes (8 processes, that is, all workers) connected to it:
```
$ fuser ../../server/db/fractal_server.db 

/somewhere/fractal-demos/examples/server/db/fractal_server.db: 60012 60013 60016 60017 60018 60019 60021 60022
```
This is partly expected, because fractal-server still connects to the DB at the beginning/end of workflow execution, but we need to make sure that the connections are not active _during_ workflow execution.

Note that the final cleanup is done correctly, because the situation after all workflow executions are over is:
* `fractal-server` running
* `fuser` showing that there is no active connection to `fractal_server.db`
