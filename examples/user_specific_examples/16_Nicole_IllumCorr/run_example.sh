LABEL="nicole_illumcorr-60x-1"

BASE_PATH=TBD

# Initialization for some environment variables for the worker
# Needed on clusters where users don't have write access to the conda env
WORKER_INIT="\
export CELLPOSE_LOCAL_MODELS_PATH=${HOME}/.cache/CELLPOSE_LOCAL_MODELS_PATH
export NUMBA_CACHE_DIR=${HOME}/.cache/NUMBA_CACHE_DIR
export NAPARI_CONFIG=${HOME}/.cache/NAPARI_CACHE_DIR
export XDG_CONFIG_HOME=${HOME}/.cache/XDG
"

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH} 2> /dev/null

# Define/initialize empty project folder and temporary file
PROJ_DIR=`pwd`/tmp_${LABEL}
rm -r $PROJ_DIR 2> /dev/null
mkdir $PROJ_DIR

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=$BASE_PATH"/repinico/Yokogawa/20220715_MethTest/221202_XYillum/231117_CellTrace2D_60x/230117NAR001"
OUTPUT_PATH=$BASE_PATH"/luetjoel/Fractal/illumination_correction/$LABEL"
###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME $PROJ_DIR`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PRJ_ID: $PRJ_ID"
echo "DS_IN_ID: $DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --name "$DS_IN_NAME" -t image --read-only $PRJ_ID $DS_IN_ID
fractal dataset add-resource -g "*.tif" $PRJ_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PRJ_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit -t zarr --read-write $PRJ_ID $DS_OUT_ID
fractal dataset add-resource -g "*.zarr" $PRJ_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"

echo "{\"overwrite\": \"True\", \"dict_corr\": {\"root_path_corr\": \"$BASE_PATH/luetjoel/illumination_correction/FMI_IllumCorr_matrices_60x_binned\", \"A04_C01\": \"2022-12-21_60x-W_405nm_BP445-45-2511567cf11ccdf3_binned2x2.tif\", \"A03_C02\": \"2022-12-21_60x-W_488nm_BP525-50-7fa31c953f10dca0_binned2x2.tif\", \"A02_C03\": \"2022-12-21_60x-W_561nm_BP600-37-786385f2d6adbc80_binned2x2.tif\", \"A01_C04\": \"2022-12-21_60x-W_640nm_BP676-29-0a7e989ed5562ac9_binned2x2.tif\"}}" > Parameters/illumination_correction.json
fractal workflow add-task $WF_ID "Illumination correction" --args-file Parameters/illumination_correction.json

# Maximum intensity projection
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation.json --meta-file Parameters/example_meta.json

# Run a series of napari workflows
echo "{\"level\": 0, \"ROI_table_name\": \"FOV_ROI_table\", \"workflow_file\": \"$PROJ_DIR/../regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A04_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"Channel1\"}}}" > Parameters/measurement.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/measurement.json

# Workflow 2: 
echo "{\"level\": 0, \"ROI_table_name\": \"FOV_ROI_table\", \"workflow_file\": \"$PROJ_DIR/../regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A03_C02\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"Channel2\"}}}" > Parameters/measurement2.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/measurement2.json

# Workflow 3: 
echo "{\"level\": 0, \"ROI_table_name\": \"FOV_ROI_table\", \"workflow_file\": \"$PROJ_DIR/../regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A02_C03\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"Channel3\"}}}" > Parameters/measurement3.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/measurement3.json

# Workflow 4: 
echo "{\"level\": 0, \"ROI_table_name\": \"FOV_ROI_table\", \"workflow_file\": \"$PROJ_DIR/../regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C04\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"Channel4\"}}}" > Parameters/measurement4.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/measurement4.json

# Look at the current workflows
# fractal workflow show $WF_ID
# echo

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID --worker-init "$WORKER_INIT"
