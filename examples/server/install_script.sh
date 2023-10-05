VERSION="1.3.9"

ENVNAME=fractal-server-$VERSION
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.10 -y
conda activate $ENVNAME

conda install "fractal-server[slurm,gunicorn,postgres]"==$VERSION
