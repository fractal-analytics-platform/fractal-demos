LABEL="conny-illum-new"

###############################################################################
# THINGS TO BE CHANGED BY THE USER
# This needs to point to the Liberali group folder on scratch
BASE_PATH=TBD

INPUT_PATH=$BASE_PATH"/Users/schwcorn/2_Yokogawa/Multiplexing_Screen/Round1/42h_batch1/220120cs001aaa42h_20220203_083238_illuminationCorr/TIF"
OUTPUT_PATH=$BASE_PATH"/Users/luetjoel/Fractal/output_$LABEL"
###############################################################################
mkdir -p $OUTPUT_PATH

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../../00_user_setup/.fractal.env .fractal.env

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
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"

# Create the illumination correction settings file (to have a full path)
echo "{\"dict_corr\": {\"root_path_corr\": \"$BASE_PATH/Users/schwcorn/2_Yokogawa/Processed/221022CS001AAA-ILC-dyes-20-40x/forYoko/YokoUse/\", \"A01_C04\": \"221109_40x_BP676_CH04.tif\", \"A02_C03\": \"221109_40x_BP600_CH03.tif\", \"A03_C02\": \"221109_40x_BP525_CH02.tif\", \"A04_C01\": \"221109_40x_BP445_CH01.tif\"}, \"background\": 110, \"overwrite\": \"True\"}" > Parameters/illum_corr.json
fractal workflow add-task $WF_ID "Illumination correction"  --args-file Parameters/illum_corr.json

# Make a MIP & process that
fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection"
echo "{\"wavelength_id\": \"A04_C01\", \"level\": 3, \"input_ROI_table\": \"well_ROI_table\", \"diameter_level0\": 200, \"cellprob_threshold\": -3.0, \"flow_threshold\": 0.4, \"pretrained_model\": \"$BASE_PATH/Fractal_Dev/models/Hummingbird.331986\", \"output_label_name\": \"organoids\"}" > Parameters/args_cellpose_organoid_custom_model.json
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/args_cellpose_organoid_custom_model.json --meta-file Parameters/meta_high.json
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A04_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"organoids\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"organoids\"}}}" > Parameters/args_measurement_organoid.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_organoid.json --meta-file Parameters/example_meta.json

# Run cyto2 model for organoid segmentation
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation_organoid_cyto2.json --meta-file Parameters/meta_high.json
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A04_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"organoids_cyto2\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"organoids_cyto2\"}}}" > Parameters/args_measurement_organoid_cyto2.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_organoid_cyto2.json --meta-file Parameters/example_meta.json


# Look at the current workflows
fractal workflow show $WF_ID
echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
