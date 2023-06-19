LABEL="no_illum_corr-4"

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=`pwd`/../images/10.5281_zenodo.7057076
OUTPUT_PATH=`pwd`/tmp_$LABEL
###############################################################################

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}

###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PRJ_NAME`
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
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Convert Yokogawa to OME-Zarr"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Copy OME-Zarr structure"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation.json --meta-file Parameters/cellpose_meta.json

echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"channel\":{ \"wavelength_id\": \"A01_C01\"{}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_C01\"}}}" > Parameters/args_measurement_C01.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement_C01.json
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A01_C02\"}}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_C02\"}}}" > Parameters/args_measurement_C02.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement_C02.json
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_with_coordinates.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A02_C03\"}}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_C03\"}}}" > Parameters/args_measurement_C03.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement_C03.json

# Apply workflow
fractal workflow apply $PRJ_ID $WF_ID $DS_IN_ID $DS_OUT_ID
