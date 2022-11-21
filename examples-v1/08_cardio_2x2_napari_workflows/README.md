First, you have to download a (tiny) dataset via
```
pip install zenodo-get
./fetch_test_data_from_zenodo.sh
```

**IMPORTANT**: The `BASE_FOLDER_EXAMPLE` at the top of the script needs to be adapted to point to the examples folder of the user you submit the example from.

The user needs to run `install_client.sh` (once to set up the client environment) and `preliminary_setup.sh` (installs the tasks environment on the server-side and registers the user). Change the `PORT` in `preliminary_setup.sh` to the port being used on the server side.

This example ran successfully with:   
* `fractal-server==1.0.0a15, fractal-client==1.0.0a0, fracal-tasks-core==0.3.5`
