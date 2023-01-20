## What is in this example?
This example processes some (non-public) search-first Yokogawa data, then parses the positions correctly of each field of view to place it in the right position in the well.

## Client setup (from `00_user_setup` folder)
TBD

## Running an example through Fractal
This needs to be done in each example folder you're running
4. Switch to this example folder and save the user credentials here by running the `prepare_user.sh` script (TO BE UPDATED, user credentials either need to be provided on each fractal client command or present in the `.fractal.env` in the folder you're running the client from)
5. Data is not publicly available, get the right path at UZH or FMI shares & change the input & output paths in the script if necessary
6. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.0.0rc3, fractal-client==1.0.0rc3, fracal-tasks-core==0.7.0`
