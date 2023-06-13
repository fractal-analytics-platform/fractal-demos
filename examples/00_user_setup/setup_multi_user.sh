#!/bin/bash

# Set server address
PORT=8020
echo -e "FRACTAL_SERVER=http://localhost:$PORT" > .fractal.env

# Modify default admin credentials
DEFAULT_ADMIN="admin@fractal.xy"
DEFAULT_ADMIN_PW="1234"
NEW_ADMIN_EMAIL=real-admin@fractal.xy
echo "Set a new admin password"
read -s NEW_ADMIN_PWD
echo
ADMIN_ID=`fractal -u $DEFAULT_ADMIN -p $DEFAULT_ADMIN_PW --batch user whoami`
fractal  -u $DEFAULT_ADMIN -p $DEFAULT_ADMIN_PW user edit $ADMIN_ID --new-email $NEW_ADMIN_EMAIL --new-password $NEW_ADMIN_PWD

# Register new user
echo "Enter the user email"
read NEW_USER_EMAIL
echo
echo "Enter the user password"
read -s NEW_USER_PASSWORD
echo
echo "Enter the corresponding slurm user"
read SLURM_USER
echo
echo "Enter the corresponding cache directory"
read CACHE_DIR
echo
fractal --user $NEW_ADMIN_EMAIL --password $NEW_ADMIN_PWD user register $NEW_USER_EMAIL $NEW_USER_PASSWORD --slurm-user $SLURM_USER --cache-dir $CACHE_DIR

# Write credentials in a .env file (optional) and check new identity
echo -e "\
FRACTAL_USER=$NEW_USER_EMAIL
FRACTAL_PASSWORD=$NEW_USER_PASSWORD
FRACTAL_SERVER=http://localhost:$PORT
" > .fractal.env
fractal user whoami

# Trigger collection of core tasks
fractal task collect fractal-tasks-core --package-version 0.10.0a2 --package-extras fractal-tasks
