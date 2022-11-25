First, you have to download a (tiny) dataset via
```
pip install zenodo-get
./fetch_test_data_from_zenodo.sh
```

**IMPORTANT**: The `BASE_FOLDER_EXAMPLE` at the top of the script needs to be adapted to point to the examples folder of the user you submit the example from. Also, the input path is relative for the current installation setup and may need to be changed.

The user needs to run `install_client.sh` (once to set up the client environment) and `preliminary_setup.sh` (installs the tasks environment on the server-side and registers the user). Change the `PORT` in `preliminary_setup.sh` to the port being used on the server side.

If `preliminary_setup.sh` has already been ran somewhere else with the server running (=> the tasks are collected in the correct version), the user can also run `prepare_user.sh` to just prepare the user credentials.

This example ran successfully with:   
* `fractal-server==1.0.0a15, fractal-client==1.0.0a0, fracal-tasks-core==0.4.6`

Waiting for an executor bug fix before testing cellpose here, so at the moment, it just does parsing & MIPs at FMI
