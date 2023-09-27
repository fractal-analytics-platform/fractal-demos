#!/bin/bash

PORT_WEB=5173
PORT_API=8010
RELEASE="0.5.6"

echo "*** Fetch a clean copy of fractal-web ${RELEASE} **"
rm -fr fractal-web-${RELEASE} 
rm -f ${RELEASE}.tar.gz
wget https://github.com/fractal-analytics-platform/fractal-web/archive/refs/tags/${RELEASE}.tar.gz
tar -xvf ${RELEASE}.tar.gz
rm ${RELEASE}.tar.gz

# Enter folder and install dependencies
echo "*** Change folder ***"
cd fractal-web-${RELEASE}
pwd

echo "*** Install dependencies ***"
npm install

# Write down environment variables
echo "*** Write environment variables for development mode ***"
echo "
FRACTAL_SERVER_HOST=http://localhost:$PORT_API
AUTH_COOKIE_NAME=fastapiusersauth
AUTH_COOKIE_SECURE=false
AUTH_COOKIE_DOMAIN=localhost
AUTH_COOKIE_PATH=/
AUTH_COOKIE_MAX_AGE=1800
AUTH_COOKIE_SAME_SITE=lax
AUTH_COOKIE_HTTP_ONLY=true
" > .env #.development

npm run build

ORIGIN=http://localhost:$PORT_WEB PORT=$PORT_WEB node build
