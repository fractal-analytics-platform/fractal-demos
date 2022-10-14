This set of examples are being updated, to be used with
```
fractal-server 0.3.3
fractal 0.2.9
fracal-tasks-core 0.2.3
```

To run on a SLURM cluster, we have two required setup procedures:
1. The user that will run the server (typically a `fractal` user) has to setup an environment, install some packages, set some environment variables, run the server.
2. The user that will run the jobs has to setup an environment, install some packages, register as a fractal user (associated to a SLURM user), call the server via the client.

Notes:
* The server and client will communicate on a specific port (e.g. 8000). For these examples, we are specifying it in the current folder, in the file `examples/PORT`, and we are setting it to 8001 (since the 8000 is sometimes taken, on the clusters we use). Thus many of the bash scripts in each subfolder will start with
```bash
PORT=`cat ../PORT`
```
This has nothing to do with fractal, but it's just a way to keep things clean in the examples. We can modify it later if it is a source of confusion.
* For the moment, we assume that the user who wants to use the client is logged on the same machine where the client is running. If this is not the case, they need to specify where the server is accessible - to be added later to this instructions.


## Server side

These are instructions to be followed by the fractal admin (typically within a dedicated `fractal` user, but it is not a hard requirement). Note that to impersonate other users (which is the only allowed behavior, when running fractal in a SLURM cluster) the admin user needs to have some special permissions in the `/etc/sudoers` file - see discussion in https://github.com/fractal-analytics-platform/fractal-server/issues/10.


1. If needed, create an environment (e.g. via `conda create --name fractalserver python==3.8.13 -y; conda activate fractalserver`).

2. Install the required packages via
```
pip uninstall fractal-tasks-core fractal-server fractal-client -y
pip install https://github.com/fractal-analytics-platform/fractal-server/releases/download/0.3.3/fractal_server-0.3.3-py3-none-any.whl fractal-tasks-core==0.2.3
```
(WARNING: this procedure will likely change in the future, when we switch back to PyPI)

3. Verify that the environment is correct, by opening a python terminal and observing this behavior in a python terminal
```
Python 3.8.13 (default, Mar 28 2022, 11:38:47) 
[GCC 7.5.0] :: Anaconda, Inc. on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import fractal_server, fractal, fractal_tasks_core
>>> fractal_server.__VERSION__
'0.3.3'
>>> fractal.__VERSION__
'0.2.9'
>>> fractal_tasks_core.__VERSION__
'0.2.3'
```

4. Setup some environment variables with
```
export RUNNER_CONFIG="XXX"
export RUNNER_LOG_DIR="logs"
export RUNNER_DEFAULT_EXECUTOR="cpu-low"
```
The only relevant one is `RUNNER_CONFIG`, which should be one of `local`, `pelkmanslab`, `fmi`. The others can be ignored (since those are already their default values).

5. Start the server by using
```
./server_config_and_start.sh
```
which should produce a set of logs ending with
```
INFO:     Application startup complete.
2022-10-14 10:52:12,787; INFO; Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8001 (Press CTRL+C to quit)
```

NOTE 1: This script prepares a new database (after **removing the old one**), removes a few folders, and then starts up the server (through its last statement: `fractal-server --port $PORT```). In principle we can also restart the server without restarting the db, but current tests are always done this way.
NOTE 2: Removing the `logs` folder can fail, because it may contain log files which were written by a different user. This is a known problem.


6. The server can be killed by a simple ctrl-c. If something goes wrong, some files/connections may remain open. This is seen for instance if
```
lsof -i :8001 | grep parsl
```
still shows some results, after the server shutdown (say after 30 seconds).
The bash script `cleanup_open_processes.sh` will (aggressively) kill all active processes that are either listed in `lsof -i :8001` or match to some typical parsl keywords. Please use it at your own risk, to avoid interfering with other processes that you may be running.
If upon starting the server you receive a message like "Address already in use", than this script will likely help.


# User side




# ALL WHAT FOLLOWS IS TO BE UPDATED



3. To download the example dataset from Zenodo, you can use
```bash
./fetch_test_data_from_zenodo.sh
```
from one of the relevant folders (e.g. `01_cardio_tiny_dataset`).
Note that this currently requires the `zenodo-get` package. At the moment this is an optional dependency, so just use `pip install zenodo-get` if you don't have it available.
TODO: this will be fixed later, either by adding it as a mandatory (dev) dependency, or by bypassing this external package.


## From the `01_cardio_tiny_dataset/` folder (in a new terminal)

**WARNING**: The current scripts always delete the output folder, before starting. Make sure you change this behavior when running long examples.

Run `. define_and_apply_workflow_1.sh`.
A few seconds after this scripts ends, there should be two zarr files in the `myproj-1/output` folder.

If you want to try simultaneous execution of several independent workflows, there are two almost-identical (apart from labels in file/folder names) script `define_and_apply_workflow_2.sh` and `define_and_apply_workflow_3.sh`.


## Ex-post information

1. The output images can be visualized for instance via
```bash
napari --plugin napari-ome-zarr -vvv 01_cardio_tiny_dataset/myproj-1/output/20200812-CardiomyocyteDifferentiation14-Cycle1.zarr/B/03/0/
```
2. You can use `parsl-visualize -d` from the `server` folder.
