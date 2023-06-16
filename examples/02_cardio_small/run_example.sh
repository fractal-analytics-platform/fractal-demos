LABEL="cardio-2x2-11"

###############################################################################
# IMPORTANT: This defines the location of input & output data
INPUT_PATH=`pwd`/../images/10.5281_zenodo.7057076
OUTPUT_PATH=`pwd`/output-${LABEL}
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
HERE=`pwd`

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
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Create OME-Zarr structure" --args-file Parameters/create_zarr_structure.json --meta-file Parameters/example_meta.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Convert Yokogawa to OME-Zarr"

echo "{\"overwrite\": \"True\", \"illumination_profiles_folder\": \"`pwd`/../illum_corr_images/\", \"dict_corr\": {\"A01_C01\": \"20220621_UZH_manual_illumcorr_40x_A01_C01.png\", \"A01_C02\": \"20220621_UZH_manual_illumcorr_40x_A01_C02.png\", \"A02_C03\": \"20220621_UZH_manual_illumcorr_40x_A02_C03.png\"}}" > Parameters/illumination_correction.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Illumination correction" --args-file Parameters/illumination_correction.json

# 3D Segmentation & measurements
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation_3D.json --meta-file Parameters/meta_cellpose.json
echo "{\"level\": 0, \"input_ROI_table\": \"FOV_ROI_table\", \"workflow_file\": \"${HERE}/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A01_C01\"}}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"regionprops_DAPI\"}}}" > Parameters/measurements_3D.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/measurements_3D.json


# Maximum intensity projection
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Copy OME-Zarr structure"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Maximum Intensity Projection"
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Cellpose Segmentation" --args-file Parameters/cellpose_segmentation.json --meta-file Parameters/meta_cellpose.json

# Run a series of napari workflows
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"${HERE}/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A01_C01\"}}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"regionprops_DAPI\"}}}" > Parameters/measurement.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/measurement.json

# # Workflow 2: 
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"${HERE}/np_wf_2_label.yaml\", \"input_specs\": {\"slice_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A01_C01\"}}, \"slice_img_c2\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A02_C03\"}}}, \"output_specs\": {\"Result of Expand labels (scikit-image, nsbatwm)\": {\"type\": \"label\", \"label_name\": \"wf_2_labels\"}}}" > Parameters/measurement2.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/measurement2.json

# Workflow 3: 
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"${HERE}/np_wf_3_label_df.yaml\", \"input_specs\": {\"slice_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A01_C01\"}}, \"slice_img_c2\": {\"type\": \"image\", \"channel\":{ \"wavelength_id\": \"A02_C03\"}}}, \"output_specs\": {\"Result of Expand labels (scikit-image, nsbatwm)\": {\"type\": \"label\", \"label_name\": \"wf_3_labels\"}, \"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"nuclei_measurements_wf3\"}}}" > Parameters/measurement3.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/measurement3.json

# Workflow 4: 
echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"${HERE}/np_wf_4_label_multi_df.yaml\", \"input_specs\": {\"slice_img\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A01_C01\"}}, \"slice_img_c2\": {\"type\": \"image\", \"channel\":{\"wavelength_id\": \"A02_C03\"}}}, \"output_specs\": {\"Result of Expand labels (scikit-image, nsbatwm)\": {\"type\": \"label\", \"label_name\": \"wf_4_labels\"}, \"regionprops_DAPI\": {\"type\": \"dataframe\", \"table_name\": \"nuclei_measurements_wf4\"}, \"regionprops_Lamin\": {\"type\": \"dataframe\",\"table_name\": \"nuclei_lamin_measurements_wf4\"}}}" > Parameters/measurement4.json
fractal --batch workflow add-task $PRJ_ID $WF_ID --task-name "Napari workflows wrapper" --args-file Parameters/measurement4.json

# Apply workflow
fractal workflow apply $PRJ_ID $WF_ID $DS_IN_ID $DS_OUT_ID
