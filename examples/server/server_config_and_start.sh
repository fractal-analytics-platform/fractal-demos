#!/bin/bash

# Use this script to startup a clean fractal-server instance (with an empty
# database, and without folders for artifacts and task venvs).

HOST=localhost
PORT=8010

# Create an empty db
rm -fr db
mkdir db
export SQLITE_PATH=db/fractal_server.db
fractalctl set-db

# Remove old stuff
rm -fr FRACTAL_TASKS_DIR
rm -r artifacts

# Set environment variables
FRACTAL_TASKS_DIR=`pwd`/FRACTAL_TASKS_DIR
echo -e "\
DEPLOYMENT_TYPE=testing
JWT_SECRET_KEY=secret
SQLITE_PATH=${SQLITE_PATH}
FRACTAL_TASKS_DIR=${FRACTAL_TASKS_DIR}
FRACTAL_LOGGING_LEVEL=10
FRACTAL_RUNNER_BACKEND=local
FRACTAL_RUNNER_WORKING_BASE_DIR=artifacts
FRACTAL_SLURM_CONFIG_FILE=config_uzh.json
FRACTAL_ADMIN_DEFAULT_EMAIL=admin@fractal.xy
FRACTAL_ADMIN_DEFAULT_PASSWORD=1234
JWT_EXPIRE_SECONDS=84600
" > .fractal_server.env

# Start the server
fractalctl start --host $HOST --port $PORT
