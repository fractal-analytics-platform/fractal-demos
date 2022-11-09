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

# Set environment variables
FRACTAL_ROOT=`pwd`/FRACTAL_ROOT
echo -e "DEPLOYMENT_TYPE=testing\nJWT_SECRET_KEY=secret\nDATA_DIR_ROOT=/tmp/\nSQLITE_PATH=./data/fractal_server.db\nFRACTAL_ROOT=${FRACTAL_ROOT}\nFRACTAL_LOGGING_LEVEL=10" > .fractal_server.env


# Start the server
fractal-server --port $PORT
