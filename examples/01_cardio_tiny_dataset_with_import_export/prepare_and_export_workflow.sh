# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Create dummy project (note: this is only because a new workflow must be
# associated to a project)
OUTPUT=`fractal --batch project new dummy-project dummy/project`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
echo "PRJ_ID: $PRJ_ID"

# Create workflow
WF_NAME="My Workflow"
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr.json --meta-file Parameters/example_meta.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"
fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection"
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation.json --meta-file Parameters/example_meta.json
echo "{\"level\": 0, \"ROI_table_name\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei\"}}}" > Parameters/args_measurement.json
fractal workflow add-task $WF_ID "Napari workflows wrapper" --args-file Parameters/args_measurement.json --meta-file Parameters/example_meta.json

fractal workflow export $WF_ID --json-file workflow.json
