# Run example 01 through Nextflow

This example just works for the test dataset at `10.5281_zenodo.7057076`. Download it first by installing `zenodo-get` in your python environment and running `fetch_test_data_from_zenodo_2x2.sh`.

### Nextflow setup
Check the README in the nextflow_examples folder for correct Nextflow setup & task installation

### Necessary example setup
1. Adapt the paths at the top of the `run_nextflow.nf` script. Folder-paths need to end with a /: 
    - `task_root` needs to point to the fractal-tasks-core folder containing the task (see installation instructions).
    - `fractal_demos_folder` needs to point to the fractal-demos folder
2. Download the example image data: Go to ../../examples/01_cardio_tiny_dataset/, follow the download instructions there.
3. Copy or create the measurement args_measurement.json file into the `extra_parameters` folder. If you have run the 01_cardio_tiny_dataset through Fractal using Fractal demos, copy it from ../../examples/01_cardio_tiny_dataset/Parameters. Otherwise, create it by running the relevant code from ../../examples/01_cardio_tiny_dataset/run_example.sh (the echo line). For example: 
    ```
    echo "{\"level\": 0, \"input_ROI_table\": \"well_ROI_table\", \"workflow_file\": \"`pwd`/../../examples/01_cardio_tiny_dataset/regionprops_from_existing_labels_feature.yaml\", \"input_specs\": {\"dapi_img\": {\"type\": \"image\", \"wavelength_id\": \"A01_C01\"}, \"label_img\": {\"type\": \"label\", \"label_name\": \"nuclei\"}}, \"output_specs\": {\"regionprops_DAPI\": {\"type\": \"dataframe\",\"table_name\": \"nuclei\"}}}" > extra_params/args_measurement.json
    ```
4. Run nextflow: `nextflow run run_nextflow.nf`


### Known limitations
1. Currently, everything is tested for 1 well only
2. Currently, nextflow & the tasks run in the same environment and all tasks run in the same conda environment. This can be generalized further
3. I haven't figured out where the task logs go so far.


Tested with fractal-tasks-core 0.9.0
