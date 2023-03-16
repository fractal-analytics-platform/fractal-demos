VERSION="1.1.0a3"

ENVNAME=fractal-server-$VERSION
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.9 -y
conda activate $ENVNAME
conda update pip -y

pip install "fractal-server[slurm]"==$VERSION
