LABEL="import-11"

# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Set useful variables
PROJECT_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=`pwd`/../images/10.5281_zenodo.7059515
OUTPUT_PATH=`pwd`/$DS_OUT_NAME
###############################################################################


# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH}  2> /dev/null

# Create project
PROJECT_ID=`fractal --batch project new $PROJECT_NAME`
echo "PROJECT_ID=$PROJECT_ID" 

# Add dataset to project and add resource to dataset
DS_IN_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_IN_NAME" --type image --make-read-only`
echo "DS_IN_ID: $DS_IN_ID"
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset $PROJECT_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID: $DS_OUT_ID"

fractal dataset edit --new-type zarr --remove-read-only $PROJECT_ID $DS_OUT_ID
fractal dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Import workflow
OUTPUT=`fractal --batch workflow import --project-id $PROJECT_ID --json-file workflow.json`
WF_ID=`echo $OUTPUT | cut -d ' ' -f1`

# Apply workflow
fractal workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID
