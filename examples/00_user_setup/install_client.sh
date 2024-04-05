VERSION="2.0.0a0"

ENVNAME=fractal-client-$VERSION
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.10 -y
conda activate $ENVNAME
conda update pip -y

# pip install fractal-client==$VERSION
pip install git+https://github.com/fractal-analytics-platform/fractal-client@dev-v2-cli
