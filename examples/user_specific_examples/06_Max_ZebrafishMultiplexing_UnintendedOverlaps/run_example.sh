###############################################################################
# THINGS TO BE CHANGED BY THE USER
LABEL="max-multiplexing"

# For FMI: needs to point to the liberali group folder

INPUT_PATH_CYCLE_0="/data/active/fractal/3D/PelkmansLab/ZebrafishMultiplexing/cycle0"
INPUT_PATH_CYCLE_1="/data/active/fractal/3D/PelkmansLab/ZebrafishMultiplexing/cycle1"

# Modify this to place the output somewhere else
OUTPUT_PATH="/data/active/jluethi/Fractal/20230317_"$LABEL

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../../00_user_setup/.fractal.env .fractal.env

# Change cache directory or add proxy settings if necessary
WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=$BASE_CACHE_DIR/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=$BASE_CACHE_DIR/NUMBA_CACHE_DIR
export NAPARI_CONFIG=$BASE_CACHE_DIR/napari_config.json
export XDG_CONFIG_HOME=$BASE_CACHE_DIR/XDG_CONFIG
export XDG_CACHE_HOME=$BASE_CACHE_DIR/XDG
"
###############################################################################

# Adapt to settings to where you run the example
BASE_FOLDER_EXAMPLE=`pwd`/..

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
fractal dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH_CYCLE_0
fractal dataset add-resource $PRJ_ID $DS_IN_ID $INPUT_PATH_CYCLE_1

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit --new-type zarr --remove-read-only $PRJ_ID $DS_OUT_ID
fractal dataset add-resource $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
# Manually create parsing arg file to get the correct paths
echo "{\"num_levels\": 5, \"coarsening_xy\": 2, \"metadata_table\": {\"0\": \"`pwd`/site_metadata_ZebrafishMultiplexing_cycle0.csv\", \"1\": \"$PROJ_DIR/../site_metadata_ZebrafishMultiplexing_cycle1.csv\"}, \"allowed_channels\": {\"0\":[{\"colormap\": \"00FFFF\", \"wavelength_id\": \"A01_C01\", \"end\": 200, \"label\": \"0_Channel 1\", \"start\": 110}, {\"colormap\": \"FF00FF\", \"end\": 250, \"wavelength_id\": \"A02_C02\", \"label\": \"0_Channel 2\", \"start\": 110}, {\"colormap\": \"FFFF00\", \"end\": 1000, \"wavelength_id\": \"A03_C03\", \"label\": \"0_Channel 3\", \"start\": 110}], \"1\": [{\"colormap\": \"00FFFF\", \"wavelength_id\": \"A01_C01\", \"end\": 200, \"label\": \"1_Channel 1\", \"start\": 110}, {\"colormap\": \"FF00FF\", \"end\": 250, \"wavelength_id\": \"A02_C02\", \"label\": \"1_Channel 2\", \"start\": 110}, {\"colormap\": \"FFFF00\", \"end\": 1000, \"wavelength_id\": \"A03_C03\", \"label\": \"1_Channel 3\", \"start\": 110}]}}" > Parameters/args_create_ome_zarr.json
fractal workflow add-task $WF_ID "Create OME-ZARR structure (multiplexing)" --args-file Parameters/args_create_ome_zarr.json 
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr" --meta-file Parameters/yoko_parsing.json
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_3D_cells.json
# Manually create measurement arg file to get the correct paths
echo "{\"level\": 0, \"input_ROI_table\": \"FOV_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei\"}}}" > Parameters/args_measurement.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement.json --meta-file Parameters/meta_measurement.json

# 2D processing
fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection" --meta-file Parameters/yoko_parsing.json
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_mip.json
# Add napari workflow (setting parameters here because we need to set some paths in there)
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"zebrafish_embryos\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"zebrafish_embryos\"}}}" > Parameters/args_measurement_2D.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement_2D.json --meta-file Parameters/meta_measurement.json

# Look at the current workflows
fractal workflow show $WF_ID
echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
