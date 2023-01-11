ENVNAME=fractal-client-stress-test
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8 -y
conda activate $ENVNAME
conda update pip -y

VERSION="1.0.0rc1"
pip install fractal-client==$VERSION
