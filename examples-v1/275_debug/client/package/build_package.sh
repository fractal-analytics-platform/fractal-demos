ENVNAME=justforpoetry
conda create --name $ENVNAME python==3.8 -y
conda activate $ENVNAME
pip install poetry==1.3

HERE=`pwd`
cd fractal-tasks-core-low
poetry build
cd $HERE
cp -v fractal-tasks-core-low/dist/fractal_tasks_core_minimal_version-0.0.0-py3-none-any.whl .
conda deactivate
conda remove --name $ENVNAME --all -y
