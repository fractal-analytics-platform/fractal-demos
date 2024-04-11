VERSION="2.0.0a4"


ENVNAME=fractal-server-$VERSION
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.10 -y
conda activate $ENVNAME
conda update pip -y

# pip install "fractal-server[slurm,gunicorn,postgres]"==$VERSION
pip install fractal-server==$VERSION
