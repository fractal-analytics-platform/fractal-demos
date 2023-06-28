#!/bin/bash

# Fetch a clean fractal-web copy
rm -fr fractal-web
git clone git@github.com:fractal-analytics-platform/fractal-web.git
cd fractal-web
git checkout 0.5.1
npm install

# Write down environment variables
echo "
FRACTAL_SERVER_HOST=http://localhost:8010
AUTH_COOKIE_NAME=fastapiusersauth
AUTH_COOKIE_SECURE=false
AUTH_COOKIE_DOMAIN=localhost
AUTH_COOKIE_PATH=/
AUTH_COOKIE_MAX_AGE=1800
AUTH_COOKIE_SAME_SITE=lax
AUTH_COOKIE_HTTP_ONLY=true
" > .env.development

npm run dev
