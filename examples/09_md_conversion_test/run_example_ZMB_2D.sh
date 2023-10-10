LABEL="ZMB MD parsing 2"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH="/Users/joel/Dropbox/Joel/FMI/Fractal/Example_data/ZMB_MD_data/plate1_Plate_1734"
OUTPUT_PATH="/Users/joel/Desktop/MD_Test_$LABEL"
###############################################################################

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PROJECT_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}  2> /dev/null

###############################################################################

# Create project
PROJECT_ID=`fractal --batch project new $PROJECT_NAME`
echo "PROJECT_ID: $PROJECT_ID"

# Add input dataset, and add a resource to it
DS_IN_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_IN_NAME" --type image --make-read-only`
echo "DS_IN_ID: $DS_IN_ID"
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_OUT_NAME" --type zarr`
echo "DS_OUT_ID: $DS_OUT_ID"
fractal dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PROJECT_ID`
echo "WF_ID: $WF_ID"

###############################################################################

# Prepare some JSON files for task arguments (note: this has to happen here,
# because we need to include the path of the current directory)

CURRENT_FOLDER=`pwd`
echo "{
  \"level\": 0,
  \"expected_dimensions\": 2,
  \"input_ROI_table\": \"FOV_ROI_table\",
  \"workflow_file\": \"$CURRENT_FOLDER/regionprops_from_existing_labels_feature.yaml\",
  \"input_specs\": {
    \"dapi_img\": { \"type\": \"image\", \"channel\":{ \"wavelength_id\": \"C01\" } },
    \"label_img\": { \"type\": \"label\", \"label_name\": \"nuclei\" }
  },
  \"output_specs\": {
    \"regionprops_DAPI\": { \"type\": \"dataframe\", \"table_name\": \"nuclei\" }
  }
}
" > Parameters/args_measurement.json

###############################################################################

# Add tasks to workflow
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Create OME-Zarr MD" --args-file Parameters/args_create_ome_zarr_zmb.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Convert MD to OME-Zarr"
# fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Copy OME-Zarr structure"
# fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation_zmb.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement.json --meta-file Parameters/example_meta.json

# Apply workflow
fractal workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID
