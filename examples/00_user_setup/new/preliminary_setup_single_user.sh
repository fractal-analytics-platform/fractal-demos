#!/bin/bash

# Set server address
PORT=8010
echo -e "FRACTAL_SERVER=http://localhost:$PORT" > .fractal.env

# Modify default admin credentials
DEFAULT_CREDENTIALS="--user admin@fractal.xy --password 1234"
NEW_ADMIN_EMAIL=real-admin@fractal.xy
NEW_ADMIN_PWD=real-admin-password
ADMIN_ID=`fractal $DEFAULT_CREDENTIALS --batch user whoami`
echo "ADMIN_ID: $ADMIN_ID"
fractal $DEFAULT_CREDENTIALS user edit $ADMIN_ID --new-email $NEW_ADMIN_EMAIL --new-password $NEW_ADMIN_PWD

# Write credentials in a .env file (optional) and check new identity
echo -e "\
FRACTAL_USER=$NEW_ADMIN_EMAIL
FRACTAL_PASSWORD=$NEW_ADMIN_PWD
FRACTAL_SERVER=http://localhost:$PORT
" > .fractal.env
fractal user whoami

# Trigger collection of core tasks
fractal task collect fractal-tasks-core --package-version 0.7.0
