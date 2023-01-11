# Setting up a fractal client & run a workflow through Fractal

1. Install the client using the `install_client.sh` script.
2. Register your user & the fractal core tasks (only needs to be done once when a new server is started) by running `preliminary_setup.sh`
3. Wait for the tasks to be collected by the server. You can use `fractal task check-collection ID`, where the ID to check is shown upon running `preliminary_setup.sh` (1 if you have just started the server). Only once it lists the available tasks can you run a workflow. [The fractal server is installing a python environment containing all the dependencies for the core tasks]
4. Get the example data: `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`
5. One can then either go through the project creation, dataset creation, workflow creation & submission one by one. Or run it all at once by running: `. ./run_example.sh`

This should complete fairly quickly (submitting the script to it being finished took 30s on my machine). One can check the status with `fractal job show ID` (where the ID is the job ID of the submitted workflow, 1 for the first workflow submitted. This is shown when submitting the workflow)

