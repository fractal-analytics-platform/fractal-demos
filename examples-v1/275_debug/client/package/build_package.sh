ENVNAME=justforpoetry
conda create --name $ENVNAME python==3.8 -y
conda activate $ENVNAME
curl -sSL https://install.python-poetry.org | python3 -

HERE=`pwd`
cd fractal-tasks-core-low
poetry build
cd $HERE
cp -v fractal-tasks-core-low/dist/fractal_tasks_core-0.0.0-py3-none-any.whl .
conda deactivate
conda remove --name $ENVNAME --all -y
