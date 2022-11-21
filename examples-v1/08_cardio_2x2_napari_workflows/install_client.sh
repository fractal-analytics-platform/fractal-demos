ENVNAME=fractal-client-v1-a0
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y
#pip install git+https://github.com/fractal-analytics-platform/fractal.git -U --force-reinstall

VERSION="1.0.0a0"

WHEEL=fractal_client-${VERSION}-py3-none-any.whl
wget https://github.com/fractal-analytics-platform/fractal/releases/download/${VERSION}/${WHEEL} .
pip install ${WHEEL}[parsl]
rm -v $WHEEL

