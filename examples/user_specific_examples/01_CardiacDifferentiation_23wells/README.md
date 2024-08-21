## What is in this example?
This example contains a workflow to create a 3D & 2D OME-Zarr dataset of a single well with 4 field of views. It creates 2D & 3D segmentation with 2D & 3D measurements. It's output is close to https://zenodo.org/record/7144919 (the Zenodo data is not fully up to data and has been processed with an older Fractal version with a similar workflow). It's still a small-ish dataset that can be processed in 30 minutes. It uses all current core Fractal tasks and runs segmentation both on CPU (the 2D one) and GPU (the 3D one).

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
4. Switch to this example folder and save the user credentials here by running the `prepare_user.sh` script (TO BE UPDATED, user credentials either need to be provided on each fractal client command or present in the `.fractal.env` in the folder you're running the client from)
5. Get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`
6. Change whether it's run on a subset of the data or the whole dataset (the `"include_glob_patterns": ["*F001*"]` parameter in create_zarr_structure.json limits it to the first field of view for each well, thus running way faster)
7. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`


Comments:
Runs faster if the level is decreased for the 2D Cellpose segmentation or if 2D cellpose segmentation is also run on the GPU.

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Running it with `fractal-server==1.2.4`, `fractal-client==1.2.0` and `fractal-tasks-core==0.9.4`
