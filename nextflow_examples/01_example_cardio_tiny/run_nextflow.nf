// Parameters need to be set by the user
task_root = "/Users/joel/opt/miniconda3/envs/nextflow-fractal/lib/python3.9/site-packages/fractal_tasks_core/"
def fractal_demos_folder = "/Users/joel/Library/CloudStorage/Dropbox/Joel/FMI/Code/fractal/fractal-demos/"

// static parameters
helper_function = fractal_demos_folder + "nextflow_examples/helper_functions/"

// Data sources
input_path = fractal_demos_folder + "examples/images/10.5281_zenodo.7057076"
output_path = fractal_demos_folder + "nextflow_examples/01_example_cardio_tiny/output"

process create_ome_zarr {
    tag "${sample}"
    debug true

    input:
    path(input_parameters)

    output:
    path("*metadata_out.json")

    script:

    """
    # Remove old output folder
    rm -rf ${output_path}
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${input_path} --output_path ${output_path}
    python ${task_root}create_ome_zarr.py -j task_params.json --metadata-out 0_metadata_out.json
    """
}

process yokogawa_to_ome_zarr {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)

    output:
    path("*metadata_out.json")

    script:
    """
    # Create the necessary input json files
    # yokogawa to zarr doesn't need any  --args_path parameters
    python ${helper_function}json_helper.py --save_path task_params.json --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component "20200812-CardiomyocyteDifferentiation14-Cycle1.zarr/B/03/0/"
    python ${task_root}yokogawa_to_ome_zarr.py -j task_params.json --metadata-out metadata_diff.json
    # Add the metadata to the existing metadata
    python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path 1_metadata_out.json
    """
}

process copy_ome_zarr {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(input_parameters)

    output:
    path("*metadata_out.json")

    script:
    """
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}
    python ${task_root}copy_ome_zarr.py -j task_params.json --metadata-out metadata_diff.json
    python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path 2_metadata_out.json
    """
}

process maximum_intensity_projection {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)

    output:
    path("*metadata_out.json")

    script:
    """
    # Create the necessary input json files
    # yokogawa to zarr doesn't need any  --args_path parameters
    python ${helper_function}json_helper.py --save_path task_params.json --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component "20200812-CardiomyocyteDifferentiation14-Cycle1_mip.zarr/B/03/0/"
    python ${task_root}maximum_intensity_projection.py -j task_params.json --metadata-out metadata_diff.json
    python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path 3_metadata_out.json
    """
}

process cellpose_segmentation {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(input_parameters)

    output:
    path("*metadata_out.json")

    script:
    """
    # Create the necessary input json files
    # yokogawa to zarr doesn't need any  --args_path parameters
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component "20200812-CardiomyocyteDifferentiation14-Cycle1_mip.zarr/B/03/0/"
    python ${task_root}cellpose_segmentation.py -j task_params.json --metadata-out metadata_diff.json
    python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path 4_metadata_out.json
    """
}

process napari_workflows_wrapper {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(input_parameters)

    output:
    path("*metadata_out.json")

    script:
    """
    # Create the necessary input json files
    # yokogawa to zarr doesn't need any  --args_path parameters
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component "20200812-CardiomyocyteDifferentiation14-Cycle1_mip.zarr/B/03/0/"
    python ${task_root}napari_workflows_wrapper.py -j task_params.json --metadata-out metadata_diff.json
    # napari workflows doesn't currently create a metadata diff (see https://github.com/fractal-analytics-platform/fractal-tasks-core/issues/357)
    touch metadata_out.json
    """
}

workflow {
    def parameter_folder = fractal_demos_folder + "examples/01_cardio_tiny_dataset/Parameters/"
    // Parameter files as input
    create_ome_zarr_params = Channel.fromPath(parameter_folder + "args_create_ome_zarr.json")
    copy_ome_zarr_params = Channel.fromPath(fractal_demos_folder + "nextflow_examples/01_example_cardio_tiny/extra_params/copy_ome_zarr.json")
    cellpose_params = Channel.fromPath(parameter_folder + "args_cellpose_segmentation.json")
    measurement_params = Channel.fromPath(fractal_demos_folder + "nextflow_examples/01_example_cardio_tiny/extra_params/args_measurement.json")
    
    metadata_out = create_ome_zarr(create_ome_zarr_params)
    metadata_yoko = yokogawa_to_ome_zarr(metadata_out)
    metadata_copy = copy_ome_zarr(metadata_yoko, copy_ome_zarr_params)
    metadata_mip = maximum_intensity_projection(metadata_copy)
    metadata_cellpose = cellpose_segmentation(metadata_mip, cellpose_params)
    metadata_mip = napari_workflows_wrapper(metadata_cellpose, measurement_params)
}
