# Setting up a fractal client & run a workflow through Fractal

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again)
1. Install the client using the `install_client.sh` script in the `00_user_setup` folder.
2. Register your user & the fractal core tasks (only needs to be done once when a new server is started) by running `preliminary_setup.sh` in the `00_user_setup` folder.
3. Wait for the tasks to be collected by the server. You can use `fractal task check-collection ID`, where the ID to check is shown upon running `preliminary_setup.sh` (1 if you have just started the server). Only once it lists the available tasks can you run a workflow. [The fractal server is installing a python environment containing all the dependencies for the core tasks]

## Running an example through Fractal
This needs to be done in each example folder you're running
4. Switch to this example folder and save the user credentials here by running the `prepare_user.sh` script (user credentials either need to be provided on each fractal client command or present in the `.fractal.env` in the folder you're running the client from)
5. Get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`
6. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

This should complete fairly quickly (submitting the script to it being finished took 30s on my machine). One can check the status with `fractal job show ID` (where the ID is the job ID of the submitted workflow, 1 for the first workflow submitted. This is shown when submitting the workflow)

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Successfully run with `fractal-server==1.0.0rc1`, `fractal-client==1.0.0rc0` and `fractal-tasks-core==0.6.5`