PORT=8002

rm .cache -r

USERNAME="$(whoami)"
echo -e "FRACTAL_USER=${USERNAME}@me.com\nFRACTAL_PASSWORD=${USERNAME}\nSLURM_USER=${USERNAME}\nFRACTAL_SERVER=http://localhost:$PORT" > .fractal.env
fractal register -p $USERNAME ${USERNAME}@me.com $USERNAME

fractal task collect fractal-tasks-core

echo "COMMAND TO CHECK END OF TASK COLLECTION:"
echo "fractal task check-collection .fractal/fractal-tasks-core"
