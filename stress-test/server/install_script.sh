ENVNAME=fractal-server-stress-test

conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.9 -y
conda activate $ENVNAME
conda update pip -y

pip install git+https://github.com/fractal-analytics-platform/fractal-server.git@new-slurm
