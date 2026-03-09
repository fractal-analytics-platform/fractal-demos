// Parameters need to be set by the user
// task_root = "/Users/joel/opt/miniconda3/envs/nextflow-fractal/lib/python3.9/site-packages/fractal_tasks_core/"
// def fractal_demos_folder = "/Users/joel/Library/CloudStorage/Dropbox/Joel/FMI/Code/fractal/fractal-demos/"
task_root = "/Users/joel/mambaforge/envs/nextflow-fractal/lib/python3.9/site-packages/fractal_tasks_core/"
def fractal_demos_folder = "/Users/joel/Dropbox/Joel/FMI/Code/fractal/fractal-demos/"

// static parameters
helper_function = fractal_demos_folder + "nextflow_examples/helper_functions/"

// Data sources
// input_path = fractal_demos_folder + "examples/images/10.5281_zenodo.7057076"
input_path = fractal_demos_folder + "examples/images/10.5281_zenodo.7059515"
output_path = fractal_demos_folder + "nextflow_examples/01_cardio_tiny_dataset/output"

process create_ome_zarr {
    tag "${sample}"
    debug true

    input:
    path(input_parameters)

    output:
    path("metadata_out.json")
    path("*_component.txt")

    script:
    """
    # Remove old output folder
    rm -rf ${output_path}
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${input_path} --output_path ${output_path}
    python ${task_root}create_ome_zarr.py -j task_params.json --metadata-out metadata_out.json
    python ${helper_function}create_component_files.py --metadata_path metadata_out.json
    """
}

process yokogawa_to_ome_zarr {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(component)

    output:
    path("dummy.txt")

    script:
    """
    component_str=`cat $component`
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component \${component_str}  
    python ${task_root}yokogawa_to_ome_zarr.py -j task_params.json --metadata-out metadata_diff.json
    touch dummy.txt
    # Add the metadata to the existing metadata
    # python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path metadata_out.json
    """
}


process copy_ome_zarr {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(input_parameters)
    val dummy

    output:
    path("new_metadata_out.json")
    path("mip_*_component.txt")

    script:
    """
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}
    python ${task_root}copy_ome_zarr.py -j task_params.json --metadata-out metadata_diff.json
    python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path new_metadata_out.json
    python ${helper_function}create_component_files.py --metadata_path new_metadata_out.json --filename_prefix mip
    """
}

process maximum_intensity_projection {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(component)

    output:
    path("dummy.txt")

    script:
    """
    component_str=`cat $component`
    python ${helper_function}json_helper.py --save_path task_params.json --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path} --component \${component_str} 
    python ${task_root}maximum_intensity_projection.py -j task_params.json --metadata-out metadata_diff.json
    touch dummy.txt
    #python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path metadata_out.json
    """
}

process cellpose_segmentation {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(component)
    path(input_parameters)
    val dummy

    output:
    path("dummy.txt")

    script:
    """
    component_str=`cat $component`
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component \${component_str} 
    python ${task_root}cellpose_segmentation.py -j task_params.json --metadata-out metadata_diff.json
    #python ${helper_function}combine_metadata.py --metadata_old ${metadata_path} --metadata_diff metadata_diff.json --save_path metadata_out.json
    touch dummy.txt
    """
}

process napari_workflows_wrapper {
    tag "${sample}"
    debug true

    input:
    path(metadata_path)
    path(component)
    path(input_parameters)
    val dummy

    output:
    path("dummy.txt")

    script:
    """
    component_str=`cat $component`
    # Create the necessary input json files
    python ${helper_function}json_helper.py --save_path task_params.json --args_path ${input_parameters} --input_path ${output_path} --output_path ${output_path} --metadata_path ${metadata_path}  --component \${component_str} 
    python ${task_root}napari_workflows_wrapper.py -j task_params.json --metadata-out metadata_diff.json
    # napari workflows doesn't currently create a metadata diff (see https://github.com/fractal-analytics-platform/fractal-tasks-core/issues/357)
    touch dummy.txt
    """
}

workflow {
    def parameter_folder = fractal_demos_folder + "examples/01_cardio_tiny_dataset/Parameters/"
    // Parameter files as input
    create_ome_zarr_params = Channel.value(parameter_folder + "args_create_ome_zarr.json")
    copy_ome_zarr_params = Channel.value(fractal_demos_folder + "nextflow_examples/01_cardio_tiny_dataset/extra_params/copy_ome_zarr.json")
    cellpose_params = Channel.value(parameter_folder + "args_cellpose_segmentation.json")
    measurement_params = Channel.value(fractal_demos_folder + "nextflow_examples/01_cardio_tiny_dataset/extra_params/args_measurement.json")
      
    // For example 02
    // def parameter_folder = fractal_demos_folder + "examples/02_cardio_small/Parameters/"
    // create_ome_zarr_params = Channel.value(parameter_folder + "create_zarr_structure.json")
    // copy_ome_zarr_params = Channel.value(fractal_demos_folder + "nextflow_examples/02_cardio_small/extra_params/copy_ome_zarr.json")
    // cellpose_params = Channel.value(parameter_folder + "cellpose_segmentation.json")
    // measurement_params = Channel.value(fractal_demos_folder + "nextflow_examples/02_cardio_small/extra_params/args_measurement.json")

    // Generate the metadata & components from the plate-level tasks, don't update them in other tasks
    create_ome_zarr_out = create_ome_zarr(create_ome_zarr_params)
    metadata = create_ome_zarr_out[0]
    component_list = create_ome_zarr_out[1]
    dummy = yokogawa_to_ome_zarr(metadata, component_list)
    copy_out = copy_ome_zarr(metadata, copy_ome_zarr_params, dummy)
    metadata_mip = copy_out[0]
    component_list_mip = copy_out[1]
    dummy2 = maximum_intensity_projection(metadata_mip, component_list_mip)
    dummy3 = cellpose_segmentation(metadata_mip, component_list_mip, cellpose_params, dummy2)
    metadata_mip = napari_workflows_wrapper(metadata_mip, component_list_mip, measurement_params, dummy3)

}
