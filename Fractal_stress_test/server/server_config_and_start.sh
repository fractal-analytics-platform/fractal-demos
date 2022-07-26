#!/bin/bash

PORT=8002

# Create an empty db
mkdir fractal_server/migrations/versions
rm fractal_server/migrations/versions/*.py -v
rm -fr data
mkdir data
alembic revision --autogenerate
alembic upgrade head

# Remove old stuff
rm -fr logs
rm -fr runinfo
rm -fr FRACTAL_ROOT
rm cmd_parsl.slurm.*.*.sh
# Move what cannot be removed easily to some trash folder
TIMESTAMP=$(date +%s)
mkdir -p OLD
mv artifacts OLD/artifacts_$TIMESTAMP

# Set environment variables
FRACTAL_ROOT=`pwd`/FRACTAL_ROOT
echo -e "\
DEPLOYMENT_TYPE=testing
JWT_SECRET_KEY=secret
DATA_DIR_ROOT=/tmp/
SQLITE_PATH=./data/fractal_server.db
FRACTAL_ROOT=${FRACTAL_ROOT}
FRACTAL_LOGGING_LEVEL=10
RUNNER_BACKEND=slurm
RUNNER_ROOT_DIR=\"artifacts\"
FRACTAL_SLURM_CONFIG_FILE=config.json
" > .fractal_server.env


# Start the server
fractal-server --port $PORT
#fractal-server --port $PORT --workers 1
#gunicorn fractal_server.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind :$PORT --access-logfile -
