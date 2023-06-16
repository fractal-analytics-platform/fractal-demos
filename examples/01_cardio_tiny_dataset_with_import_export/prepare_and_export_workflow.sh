# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Create dummy project (note: this is only because a new workflow must be
# associated to a project)
OUTPUT=`fractal --batch project new dummy-project-5`
PRJ_ID=`echo $OUTPUT | cut -d ' ' -f1`
echo "PRJ_ID: $PRJ_ID"

# Create workflow
WF_NAME="My Workflow"
WF_ID=`fractal --batch workflow new "$WF_NAME" $PRJ_ID`
echo "WF_ID: $WF_ID"

# Add tasks to workflow
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Create OME-Zarr structure" --args-file Parameters/args_create_ome_zarr.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Convert Yokogawa to OME-Zarr"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Copy OME-Zarr structure"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters/args_cellpose_segmentation.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/args_measurement.json --meta-file Parameters/example_meta.json

fractal --batch workflow export $PRJ_ID $WF_ID --json-file workflow.json
