## What is in this example?
This example allows users to compare quantification with or without illumination correction. The `run_example_with_illumCorr.sh` and `run_example_no_illumCorr.sh` work with the example data from example 02. The full well examples run the same workflow on a large dataset that is not public.

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. If you have not downloaded the example data in example 02 yet: to get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`. Full well example data is not available publicly.
3. Change the input & output paths in the script if necessary
4. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example_no_illumCorr.sh` and `. ./run_example_with_illumCorr.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.1.0.a3, fractal-client==1.1.0a4, fracal-tasks-core==0.9.0`
