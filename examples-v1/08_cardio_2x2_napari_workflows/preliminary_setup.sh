
# Register user
PORT=8005
USERNAME="$(whoami)"
echo -e "\
FRACTAL_USER=${USERNAME}@me.com
FRACTAL_PASSWORD=${USERNAME}
SLURM_USER=${USERNAME}
FRACTAL_SERVER=http://localhost:$PORT\
" > .fractal.env
fractal register -p $USERNAME ${USERNAME}@me.com $USERNAME

# Trigger collection of core tasks
fractal task collect fractal-tasks-core --package-version 0.3.3

echo "COMMAND TO CHECK END OF TASK COLLECTION:"
echo "fractal task check-collection .fractal/fractal-tasks-core0.3.3"
