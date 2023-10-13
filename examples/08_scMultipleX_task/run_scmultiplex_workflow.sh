LABEL="scmultiplex-7"

###############################################################################
# IMPORTANT: modify the following lines so that they point to absolute paths
INPUT_PATH=/data/active/fractal/Liberali/1_well_15_fields_20_planes_SF_w_errors/D10_R1/220304_172545_220304_175557
OUTPUT_PATH=/data/active/jluethi/Fractal/20230421_$LABEL
# INPUT_PATH=/Users/joel/shares/dataShareFractal/fractal/Liberali/1_well_15_fields_20_planes_SF_w_errors/D10_R1/220304_172545_220304_175557
# OUTPUT_PATH=/Users/joel/Desktop/Zarr_$LABEL
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
rm -rv ${FRACTAL_CACHE_PATH} 2> /dev/null

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

# Add tasks to workflow
fractal workflow add-task $WF_ID "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json
fractal workflow add-task $WF_ID "Convert Yokogawa to OME-Zarr"

fractal workflow add-task $WF_ID "Copy OME-Zarr structure"
fractal workflow add-task $WF_ID "Maximum Intensity Projection"

# Organoid segmentation
fractal workflow add-task $WF_ID "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation_overlap.json

fractal workflow add-task $WF_ID "ScMultipleX Measurement" --args-file Parameters/scmultiplex.json

# Apply workflow
fractal workflow apply -o $DS_OUT_ID -p $PROJECT_ID $WF_ID $DS_IN_ID
