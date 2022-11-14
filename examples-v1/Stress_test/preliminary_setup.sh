conda activate fractal-client-v1
rm .cache -r
rm -r tmp

# Register user
PORT=8002
USERNAME="$(whoami)"
echo -e "\
FRACTAL_USER=${USERNAME}@me.com
FRACTAL_PASSWORD=${USERNAME}
SLURM_USER=${USERNAME}
FRACTAL_SERVER=http://localhost:$PORT\
" > .fractal.env
fractal register -p $USERNAME ${USERNAME}@me.com $USERNAME

VERSION="0.1.0"

fractal task collect `pwd`/fractal-tasks-stresstest/dist/fractal_tasks_stresstest-${VERSION}-py3-none-any.whl

echo "COMMAND TO CHECK END OF TASK COLLECTION:"
echo "fractal task check-collection .fractal/fractal_tasks_stresstest${VERSION}"
