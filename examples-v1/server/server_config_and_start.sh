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
mv artifacts OLD/
rm cmd_parsl.slurm.*.*.sh

# Set environment variables
FRACTAL_ROOT=`pwd`/FRACTAL_ROOT
echo -e "\
DEPLOYMENT_TYPE=testing
JWT_SECRET_KEY=secret
DATA_DIR_ROOT=/tmp/
SQLITE_PATH=./data/fractal_server.db
FRACTAL_ROOT=${FRACTAL_ROOT}
FRACTAL_LOGGING_LEVEL=10
RUNNER_BACKEND=parsl
RUNNER_PARSL_ENV_ACTIVATE=\"source /opt/easybuild/software/Anaconda3/2019.07/etc/profile.d/conda.sh; conda activate fractal-server-v1;\"
" > .fractal_server.env


# Start the server
fractal-server --port $PORT
