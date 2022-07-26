ENVNAME=fractal-client-v1
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y
pip install git+https://github.com/fractal-analytics-platform/fractal.git -U --force-reinstall
