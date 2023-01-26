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

Successfully run with `fractal-server==1.0.2`, `fractal-client==1.0.1` and `fractal-tasks-core==0.7.0`

Know issues:
Installation on Macs can fail due to qt in a dependency. We're trying to work around this at the moment. See here for more details: https://github.com/fractal-analytics-platform/fractal-tasks-core/issues/286#issuecomment-1404640818
