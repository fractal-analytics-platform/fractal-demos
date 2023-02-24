# Client setup

There are two main client setups: for a local user or for a multi-user setup. Use the local user setup if you just want to run some tests with Fractal on your machine. The multi-user setup is well suited for running Fractal on a slurm setup.

## Local setup
1. Install the Fractal client by running `install_client.sh` (optionally change the client version you wish to install).
2. Change the admin user password by running `local_user_setup.sh` (you can adapt the new password in the script). This saves the credentials to the .fractal.env file, which is used by default in the other examples afterwards. It also triggers the task collection.
3. Wait for the tasks to be collected by the server. You can use `fractal task check-collection ID`, where the ID to check is shown upon running `local_user_setup.sh` (1 if you have just started the server). Only once it lists the available tasks can you run a workflow. [The fractal server is installing a python environment containing all the dependencies for the core tasks]

## Multi-user setup
1. Install the Fractal client by running `install_client.sh` (optionally change the client version you wish to install).
2. Run `setup_multi_user.sh`. You can adapt the new admin email in the script. The script will then ask you for a new admin password and change those credentials. It will also ask you for user email & password. These credentials are saved to the .fractal.env file, which is used by default in the other examples afterwards. It also triggers the task collection.
3. Wait for the tasks to be collected by the server. You can use `fractal task check-collection ID`, where the ID to check is shown upon running `setup_multi_user.sh` (1 if you have just started the server). Only once it lists the available tasks can you run a workflow. [The fractal server is installing a python environment containing all the dependencies for the core tasks]

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html

Successfully run with `fractal-server==1.0.8`, `fractal-client==1.0.5` and `fractal-tasks-core==0.7.4`

## Know issues:
Task collection on Apple Silicon Macs can fail due to issues with dependencies being install via pip (currently, the imagecodecs dependency of cellpose is not pip installable). We are [evaluating conda packaging](https://github.com/fractal-analytics-platform/fractal-tasks-core/issues/290), but are not releasing those at the moment.
You can work around this by manually installting the tasks (e.g. install imagecodecs first, then the task package) and the register the tasks one-by-one with the server. I created a `manual_task_collection.sh` script that automates this process. Thus, if the automatic task collection fails, try running `manual_task_collection.sh` (after you have run the `local_user_setup.sh` to register the fractal user).


