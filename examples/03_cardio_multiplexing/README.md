# Setting up a fractal client & run a workflow through Fractal
This example shows how to convert multiplexed data from the Yokogawa CV7K into an OME-Zarr.

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. Get access to the example data (currently only on UZH servers) and copy them into the images folder (`../images/tiny_multiplexing` from this folder)
3. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. run_example.sh` (or `. run_example_reversed_cycles.sh` for processing the cycles in a different order)

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Successfully run with `fractal-server==1.4.0`, `fractal-client==1.4.0` and `fractal-tasks-core==0.14.0`
