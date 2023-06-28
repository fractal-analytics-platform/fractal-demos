VERSION="1.3.1"

ENVNAME=fractal-server-$VERSION
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.9 -y
conda activate $ENVNAME
conda update pip -y

pip install "fractal-server[slurm,gunicorn,postgres]"==$VERSION
