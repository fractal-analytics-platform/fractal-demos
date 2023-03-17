## What is in this example?
This example processes some (non-public) data from the Yokogawa CV8K.

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder and save the user credentials here (the script also copies over the .fractal.env info from the 00_user_setup folder)
2. Data is not publicly available, get the right path at UZH or FMI shares & change the input & output paths in the script if necessary
3. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.1.0, fractal-client==1.1.0, fracal-tasks-core==0.9.0`
