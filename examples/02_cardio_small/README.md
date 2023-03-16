## What is in this example?
This example contains a workflow to create a 3D & 2D OME-Zarr dataset of a single well with 4 field of views. It creates 2D & 3D segmentation with 2D & 3D measurements. It's output is close to https://zenodo.org/record/7144919 (the Zenodo data is not fully up to data and has been processed with an older Fractal version with a similar workflow). It's still a small-ish dataset that can be processed in 30 minutes. It uses all current core Fractal tasks and runs segmentation both on CPU (the 2D one) and GPU (the 3D one).

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. Get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`
3. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`


Comments:
Runs faster if the level is decreased for the 2D Cellpose segmentation or if 2D cellpose segmentation is also run on the GPU.

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Successfully run with `fractal-server==1.1.0a3`, `fractal-client==1.1.0a4` and `fractal-tasks-core==0.9.0`
