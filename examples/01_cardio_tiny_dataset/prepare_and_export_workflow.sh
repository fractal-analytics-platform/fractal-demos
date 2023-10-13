LABEL=dummy-project-16

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Create dummy project (note: this is only because a new workflow must be
# associated to a project)
PROJECT_ID=`fractal --batch project new $LABEL`
echo "PROJECT_ID=$PROJECT_ID"

# Create workflow
WF_NAME="My Workflow"
WF_ID=`fractal --batch workflow new "$WF_NAME" $PROJECT_ID`
echo "WF_ID=$WF_ID"

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

# Add tasks to workflow
fractal --batch workflow add-task --task-name "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr.json --meta-file Parameters/example_meta.json $PROJECT_ID $WF_ID
fractal --batch workflow add-task --task-name "Convert Yokogawa to OME-Zarr" $PROJECT_ID $WF_ID
fractal --batch workflow add-task --task-name "Copy OME-Zarr structure" $PROJECT_ID $WF_ID
fractal --batch workflow add-task --task-name "Maximum Intensity Projection" $PROJECT_ID $WF_ID
fractal --batch workflow add-task --task-name "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation.json --meta-file Parameters/example_meta.json $PROJECT_ID $WF_ID
fractal --batch workflow add-task --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement.json --meta-file Parameters/example_meta.json $PROJECT_ID $WF_ID
fractal --batch workflow export --json-file workflow.json $PROJECT_ID $WF_ID
