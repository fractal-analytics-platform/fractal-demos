ENVNAME=fractal-server-v1
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y

pip install fractal-server[slurm]==1.0.0b7

# VERSION="1.0.0b4"
# WHEEL=fractal_server-${VERSION}-py3-none-any.whl
# wget https://github.com/fractal-analytics-platform/fractal-server/releases/download/${VERSION}/${WHEEL} .
# pip install ${WHEEL}[slurm]
# rm -v $WHEEL
