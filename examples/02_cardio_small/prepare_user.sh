PORT=8010
USERNAME="$(whoami)"
echo -e "\
FRACTAL_USER=${USERNAME}@me.com
FRACTAL_PASSWORD=${USERNAME}
SLURM_USER=${USERNAME}
FRACTAL_SERVER=http://localhost:$PORT\
" > .fractal.env