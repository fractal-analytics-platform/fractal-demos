## What is in this example?
This example allows users to compare quantification with or without illumination correction. The `run_example_with_illumCorr.sh` and `run_example_no_illumCorr.sh` work with the example data from example 02. The full well examples run the same workflow on a large dataset that is not public.

## Client setup (from `00_user_setup` folder)
TBD

## Running an example through Fractal
This needs to be done in each example folder you're running
4. Switch to this example folder and save the user credentials here by running the `prepare_user.sh` script (TO BE UPDATED, user credentials either need to be provided on each fractal client command or present in the `.fractal.env` in the folder you're running the client from)
5. If you have not downloaded the example data in example 02 yet: to get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`. Full well example data is not available publicly.
6. Change the input & output paths in the script if necessary
7. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example_no_illumCorr.sh` and `. ./run_example_with_illumCorr.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.0.0rc3, fractal-client==1.0.0rc3, fracal-tasks-core==0.7.0`
