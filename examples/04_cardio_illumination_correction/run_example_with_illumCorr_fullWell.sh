LABEL="with_illum_corr_fullWell"

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Initialization for some environment variables for the worker
# Needed on clusters where users don't have write access to the conda env and 
# fractal user cache directories
BASE_CACHE_DIR=${HOME}/.cache
WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=$BASE_CACHE_DIR/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=$BASE_CACHE_DIR/NUMBA_CACHE_DIR
export NAPARI_CONFIG=$BASE_CACHE_DIR/napari_config.json
export XDG_CONFIG_HOME=$BASE_CACHE_DIR/XDG_CONFIG
export XDG_CACHE_HOME=$BASE_CACHE_DIR/XDG
"

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp_${LABEL}
rm -r $PROJ_DIR
mkdir $PROJ_DIR

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=/data/active/fractal/3D/PelkmansLab/CardiacMultiplexing/Cycle1_9x8_singleWell
OUTPUT_PATH=/data/active/jluethi/Fractal/20230316_$LABEL
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME $PROJ_DIR`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --new-name "$DS_IN_NAME" --new-type image --make-read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit --new-type zarr --remove-read-only $PRJ_ID $DS_OUT_ID
fractal dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr_illum_corr.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"
echo "{\"overwrite\": \"True\", \"dict_corr\": {\"root_path_corr\": \"`pwd`/../illum_corr_images/\", \"A01_C01\": \"20220621_UZH_manual_illumcorr_40x_A01_C01.png\", \"A01_C02\": \"20220621_UZH_manual_illumcorr_40x_A01_C02.png\", \"A02_C03\": \"20220621_UZH_manual_illumcorr_40x_A02_C03.png\"}}" > Parameters/illumination_correction.json
fractal workflow add-task $WF_ID "Illumination correction" --args-file Parameters/illumination_correction.json
fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection"
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation.json #--meta-file Parameters/example_meta.json
echo "{\"level\": 0, \"input_ROI_table\": \"FOV_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_C01\"}}}" > Parameters/args_measurement_C01.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_C01.json
echo "{\"level\": 0, \"input_ROI_table\": \"FOV_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C02\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_C02\"}}}" > Parameters/args_measurement_C02.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_C02.json
echo "{\"level\": 0, \"input_ROI_table\": \"FOV_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A02_C03\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_C03\"}}}" > Parameters/args_measurement_C03.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_C03.json

# Look at the current workflows
# fractal workflow show $WF_ID
# echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
