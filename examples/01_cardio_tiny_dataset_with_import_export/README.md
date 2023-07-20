# Setting up a fractal client & run a workflow through Fractal

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. If you followed the instructions above, credentials should be used automatically. Alternatively, check the top of the script to set them up manually.
2. Get the example data (unless you already did in the other 01 example): `pip install zenodo_get`, then run `. ./fetch_test_data_from_zenodo.sh`
3. Create a project & add a workflow to it that is downloaded by running `prepare_and_export_workflow.sh`
4. Create a second project, import the workflow and apply it by running `import_and_run_workflow.sh`

This should complete fairly quickly. One can check the status with `fractal job show ID` (where the ID is the job ID of the submitted workflow: 1 for the first workflow submitted, 2 for the second). This is shown when submitting the workflow)

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

Successfully run with `fractal-server==1.3.0a5`, `fractal-client==1.3.0a3` and `fractal-tasks-core==0.10.0a4`
