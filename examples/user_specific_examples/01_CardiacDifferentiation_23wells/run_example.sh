LABEL="20231221_23well_Cardiomyocytes_2DIllum_singleFOV"

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
PROJECT_NAME="proj-$LABEL"
DS_IN_NAME="input-ds-$LABEL"
DS_OUT_NAME="output-ds-$LABEL"
WF_NAME="Workflow $LABEL"

# Set cache path and remove any previous file from there
export FRACTAL_CACHE_PATH=`pwd`/".cache"
rm -rv ${FRACTAL_CACHE_PATH} 2> /dev/null

###############################################################################

# Create project
PROJECT_ID=`fractal --batch project new "$PROJECT_NAME"`
echo "PROJECT_ID=$PROJECT_ID"  # Do not remove this line, it's used in fractal-containers

# Add input dataset, and add a resource to it
DS_IN_ID=`fractal --batch project add-dataset  --type image --make-read-only $PROJECT_ID "$DS_IN_NAME"`
echo "DS_IN_ID=$DS_IN_ID"
fractal dataset add-resource $PROJECT_ID $DS_IN_ID $INPUT_PATH

# Add output dataset, and add a resource to it
DS_OUT_ID=`fractal --batch project add-dataset  --type zarr $PROJECT_ID "$DS_OUT_NAME"`
echo "DS_OUT_ID=$DS_OUT_ID"
fractal dataset add-resource $PROJECT_ID $DS_OUT_ID $OUTPUT_PATH

# Create workflow
WF_ID=`fractal --batch workflow new "$WF_NAME" $PROJECT_ID`
echo "WF_ID=$WF_ID"

# Add tasks to workflow
# fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure_subset.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure_subset.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Convert Yokogawa to OME-Zarr" --meta-file Parameters/example_meta.json
# Maximum intensity projection
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Copy OME-Zarr structure"
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Maximum Intensity Projection" --meta-file Parameters/example_meta.json

# IlluminationCorrection
echo "{\"overwrite\": \"True\", \"background\": 115, \"dict_corr\": {\"root_path_corr\": \"`pwd`/../../illum_corr_images/\", \"A01_C01\": \"20220621_UZH_manual_illumcorr_40x_A01_C01.png\", \"A01_C02\": \"20220621_UZH_manual_illumcorr_40x_A01_C02.png\", \"A02_C03\": \"20220621_UZH_manual_illumcorr_40x_A02_C03.png\"}}" > Parameters/illumination_correction.json
fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Illumination correction" --args-file Parameters/illumination_correction.json  --meta-file Parameters/meta_illumcorr.json

fractal --batch workflow add-task $PROJECT_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation.json 

# Apply workflow
JOB_ID=`fractal --batch workflow apply $PROJECT_ID $WF_ID $DS_IN_ID $DS_OUT_ID`
