## What is in this example?
This example processes a dataset with intentional, regular overlap between the field of views. Data is only available on FMI servers and was acquired by Clara Baader. 

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder.
2. BASE_PATH="TBD" needs to be adapted to point to the liberali user folder
3. Proxy settings need to be added at FMI to the WORKER_INIT when first running cellpose with a new model for the first time (to allow model download).
4. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example_fmi.sh`

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Running it with `fractal-server==1.1.0`, `fractal-client==1.1.0` and `fractal-tasks-core==0.9.0`
