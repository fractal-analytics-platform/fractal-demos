ENVNAME=fractal-server-v1
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y

VERSION="1.0.0a12"

WHEEL=fractal_server-${VERSION}-py3-none-any.whl
wget https://github.com/fractal-analytics-platform/fractal-server/releases/download/${VERSION}/${WHEEL} .
pip install ${WHEEL}[parsl]
rm -v $WHEEL
