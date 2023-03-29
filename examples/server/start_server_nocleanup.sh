#!/bin/bash
# Use this script to restart a server that was previously running
PORT=8010

# Set the db path
export SQLITE_PATH=db/fractal_server.db
fractalctl set-db

# Set environment variables
FRACTAL_TASKS_DIR=`pwd`/FRACTAL_TASKS_DIR
echo -e "\
DEPLOYMENT_TYPE=testing
JWT_SECRET_KEY=secret
SQLITE_PATH=db/fractal_server.db
FRACTAL_TASKS_DIR=${FRACTAL_TASKS_DIR}
FRACTAL_LOGGING_LEVEL=20
FRACTAL_RUNNER_BACKEND=grouped_slurm
FRACTAL_RUNNER_WORKING_BASE_DIR=artifacts
FRACTAL_SLURM_CONFIG_FILE=config_uzh.json
FRACTAL_ADMIN_DEFAULT_EMAIL=admin@fractal.xy
FRACTAL_ADMIN_DEFAULT_PASSWORD=1234
" > .fractal_server.env

# Start the server
fractalctl start --port $PORT
