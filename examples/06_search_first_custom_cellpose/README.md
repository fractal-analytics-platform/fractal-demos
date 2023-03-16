## What is in this example?
This example processes some (non-public) search-first Yokogawa data, then parses the positions correctly of each field of view to place it in the right position in the well. Additionally, a custom cellpose network is applied to segment the organoids in those images.

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. Data is not publicly available, get the right path at UZH or FMI shares & change the input & output paths in the script if necessary. You may also have to change the path to the custom cellpose network in the `cellpose_segmentation.json` file.
3. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.1.0a3, fractal-client==1.1.0a4, fracal-tasks-core==0.9.0`
