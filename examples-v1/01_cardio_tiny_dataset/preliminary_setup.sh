
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

# Trigger collection of core tasks
fractal task collect fractal-tasks-core --package-version 0.6.0

echo "To quickly see whether task collection is complete, issue the command"
echo "fractal task list"

