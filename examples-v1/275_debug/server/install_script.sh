ENVNAME=fractal-server-275
conda deactivate
conda remove --name $ENVNAME -y --all
conda create --name $ENVNAME python==3.8.13 -y
conda activate $ENVNAME
conda update pip -y

CODE_DIR=code_fractal_server
rm -rf $CODE_DIR

git clone git@github.com:fractal-analytics-platform/fractal-server.git $CODE_DIR

HERE=`pwd`
cd $CODE_DIR
git submodule update --init
pip install -e .[slurm]
cd $HERE

#pip install fractal-server[slurm]==1.0.0b3
#pip install fractal-server[slurm]==1.0.0b6
#VERSION="1.0.0b3"
#WHEEL=fractal_server-${VERSION}-py3-none-any.whl
#wget https://github.com/fractal-analytics-platform/fractal-server/releases/download/${VERSION}/${WHEEL} .
#pip install ${WHEEL}[slurm]
#rm -v $WHEEL
