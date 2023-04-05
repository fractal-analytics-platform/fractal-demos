ENVNAME=fractal-client-stress-test
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.9 -y
conda activate $ENVNAME
conda update pip -y

VERSION="1.1.0"
pip install fractal-client==$VERSION
