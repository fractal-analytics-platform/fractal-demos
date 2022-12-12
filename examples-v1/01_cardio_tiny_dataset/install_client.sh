ENVNAME=fractal-client-v1
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y


VERSION="1.0.0a4"
pip install fractal-client==$VERSION

# Installing from github releases:
# WHEEL=fractal_client-${VERSION}-py3-none-any.whl
# pip install https://github.com/fractal-analytics-platform/fractal/releases/download/${VERSION}/${WHEEL}
