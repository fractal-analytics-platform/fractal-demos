LABEL="cardiac-tiny"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=`pwd`/../images/10.5281_zenodo.8287221/
OUTPUT_PATH=`pwd`/output_${LABEL}
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
WORKFLOW_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}  2> /dev/null

###############################################################################

# Create project
OUTPUT=`fractal --batch project new $PROJECT_NAME`
PROJECT_ID=`echo $OUTPUT | cut -d ' ' -f1`
DS_IN_ID=`echo $OUTPUT | cut -d ' ' -f2`
echo "PROJECT_ID=$PROJECT_ID"  # Do not remove this line, it's used in fractal-containers
echo "DS_IN_ID=$DS_IN_ID"

# Update dataset name/type, and add a resource
fractal dataset edit --new-name "$DS_IN_NAME" --new-type image --make-read-only $PROJECT_ID $DS_IN_ID
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID=$DS_OUT_ID"

fractal dataset edit --new-type zarr --remove-read-only $PROJECT_ID $DS_OUT_ID
fractal dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WORKFLOW_ID=`fractal --batch workflow new "$WORKFLOW_NAME" $PROJECT_ID`
echo "WORKFLOW_ID=$WORKFLOW_ID"

###############################################################################

# Prepare some JSON files for task arguments (note: this has to happen here,
# because we need to include the path of the current directory)
CURRENT_FOLDER=`pwd`
echo "{
  \"level\": 0,
  \"input_ROI_table\": \"well_ROI_table\",
  \"workflow_file\": \"$CURRENT_FOLDER/regionprops_from_existing_labels_feature.yaml\",
  \"input_specs\": {
    \"dapi_img\": { \"type\": \"image\", \"channel\":{ \"wavelength_id\": \"A01_C01\" } },
    \"label_img\": { \"type\": \"label\", \"label_name\": \"nuclei\" }
  },
  \"output_specs\": {
    \"regionprops_DAPI\": { \"type\": \"dataframe\", \"table_name\": \"nuclei\" }
  }
}
" > Parameters/args_measurement.json

###############################################################################

# Add tasks to workflow
fractal --batch workflow add-task $PROJECT_ID $WORKFLOW_ID --task-name "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PROJECT_ID $WORKFLOW_ID --task-name "Convert Yokogawa to OME-Zarr"
fractal --batch workflow add-task $PROJECT_ID $WORKFLOW_ID --task-name "Copy OME-Zarr structure" --args-file Parameters/copy_ome_zarr.json
fractal --batch workflow add-task $PROJECT_ID $WORKFLOW_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PROJECT_ID $WORKFLOW_ID --task-name "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation.json #--meta-file Parameters/cellpose_meta.json
fractal --batch workflow add-task $PROJECT_ID $WORKFLOW_ID --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement.json --meta-file Parameters/example_meta.json

# Apply workflow
JOB_ID=`fractal --batch workflow apply $PROJECT_ID $WORKFLOW_ID $DS_IN_ID $DS_OUT_ID`
echo "JOB_ID=$JOB_ID"  # Do not remove this line, it's used in fractal-containers
