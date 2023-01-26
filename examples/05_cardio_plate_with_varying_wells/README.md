## What is in this example?
This example contains a workflow to process a small cardio dataset. It's a custom dataset only available at UZH which is a combination of the 2 zenodo datasets in examples 01 & 02. The result is a plate with differently sized wells.

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. Get access to the data (currently only available on UZH shares)
3. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.0.0rc3, fractal-client==1.0.0rc3, fracal-tasks-core==0.7.0`
