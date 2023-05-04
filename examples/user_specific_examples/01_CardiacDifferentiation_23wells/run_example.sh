LABEL="20230504_23well_Cardiomyocytes_2DIllum_full"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=/data/active/jluethi/20200810-CardiomyocyteDifferentiation14/Cycle1/images_renamed
OUTPUT_PATH=/data/active/jluethi/Fractal/$LABEL
###############################################################################

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PRJ_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH} 2> /dev/null

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
fractal --batch workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr" --meta-file Parameters/example_meta.json
# Maximum intensity projection
fractal --batch workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal --batch workflow add-task $WF_ID "Maximum Intensity Projection" --meta-file Parameters/example_meta.json

# IlluminationCorrection
echo "{\"overwrite\": \"True\", \"background\": 115, \"dict_corr\": {\"root_path_corr\": \"`pwd`/../../illum_corr_images/\", \"A01_C01\": \"20220621_UZH_manual_illumcorr_40x_A01_C01.png\", \"A01_C02\": \"20220621_UZH_manual_illumcorr_40x_A01_C02.png\", \"A02_C03\": \"20220621_UZH_manual_illumcorr_40x_A02_C03.png\"}}" > Parameters/illumination_correction.json
fractal --batch workflow add-task $WF_ID "Illumination correction" --args-file Parameters/illumination_correction.json  --meta-file Parameters/meta_illumcorr.json

fractal --batch workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation.json 

# Run a series of napari workflows
echo "{\"level\": 0, \"input_ROI_table\": \"FOV_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"lamin_img\": {\"type\": \"image\", \"wavelength_id\": \"A02_C03\"}, \"nanog_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C02\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"regionprops_DAPI\"}, \"regionprops_lamin\": {\"type\": \"dataframe\", \"table_name\": \"regionprops_lamin\"}, \"regionprops_nanog\": {\"type\": \"dataframe\", \"table_name\": \"regionprops_nanog\"}}}" > Parameters/measurement.json
fractal --batch workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/measurement.json --meta-file Parameters/meta_napari_workflows.json

# Apply workflow
fractal --batch workflow apply -o $DS_OUT_ID -p $PRJ_ID $WF_ID $DS_IN_ID
