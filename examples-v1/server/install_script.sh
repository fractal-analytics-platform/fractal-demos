ENVNAME=fractal-server-v1
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y
pip install https://github.com/fractal-analytics-platform/fractal-server/releases/download/1.0.0a3/fractal_server-1.0.0a3-py3-none-any.whl
