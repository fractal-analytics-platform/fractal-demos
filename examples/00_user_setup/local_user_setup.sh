#!/bin/bash

# Set server address
PORT=8010

# Modify default admin credentials
DEFAULT_ADMIN="admin@fractal.xy"
DEFAULT_ADMIN_PW="1234"
NEW_ADMIN_EMAIL=real-admin@fractal.xy
NEW_ADMIN_PWD="new_pwd"
ADMIN_ID=`fractal --user $DEFAULT_ADMIN --password $DEFAULT_ADMIN_PW --batch user whoami`
fractal --user $DEFAULT_ADMIN --password $DEFAULT_ADMIN_PW user edit $ADMIN_ID --new-email $NEW_ADMIN_EMAIL --new-password $NEW_ADMIN_PWD

# Write credentials in a .env file (optional) and check new identity
echo -e "\
FRACTAL_USER=$NEW_ADMIN_EMAIL
FRACTAL_PASSWORD=$NEW_ADMIN_PWD
FRACTAL_SERVER=http://localhost:$PORT
" > .fractal.env
fractal user whoami

# Trigger collection of core tasks
fractal task collect fractal-tasks-core --package-version 0.14.0a0 --package-extras fractal-tasks
