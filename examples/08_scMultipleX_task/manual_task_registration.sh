# Script to register a task in Fractal server using a python environment 
# that is already set up, has the dependencies installed

cp ../00_user_setup/.fractal.env .fractal.env

PYTHON_SOURCE=/Users/joel/mambaforge/envs/scmultiplex-fractal/bin/python
TASK_BASE_PATH="/Users/joel/Dropbox/Joel/FMI/Code/gliberal-scMultipleX/src/scmultiplex/fractal"
DEFAULT_ARG_FILE_FOLDER="/Users/joel/Dropbox/Joel/FMI/Code/fractal/fractal-demos/examples/08_scMultipleX_task/default_args"
fractal task new --input-type zarr --output-type zarr --default-args-file $DEFAULT_ARG_FILE_FOLDER/args_scmultiplex_measurement.json --meta-file $DEFAULT_ARG_FILE_FOLDER/meta.json "ScMultipleX Measurement" "$PYTHON_SOURCE $TASK_BASE_PATH/scmultiplex_feature_measurements.py" "manual:scmultiplex==0.1.0-scmultiplex_feature_measurements"
