VERSION="1.3.0a1"

ENVNAME=fractal-client-$VERSION
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.9 -y
conda activate $ENVNAME
conda update pip -y

pip install fractal-client==$VERSION
