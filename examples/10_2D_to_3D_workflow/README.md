# Setting up a fractal client & run a workflow through Fractal

Testing the custom 2D to 3D task on example 01 data. Install those tasks first (follow instructions here: https://github.com/jluethi/napari-ome-zarr-roi-loader/tree/main/examples)

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. Get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`
3. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

This should complete fairly quickly (submitting the script to it being finished took 30s on my machine). One can check the status with `fractal job show ID` (where the ID is the job ID of the submitted workflow, 1 for the first workflow submitted. This is shown when submitting the workflow)

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Successfully run with `fractal-server==1.3.0`, `fractal-client==1.3.0` and `fractal-tasks-core==0.10.0a6`
