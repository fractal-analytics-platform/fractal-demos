# Setting up a Fractal server

Check out the fractal-server documentation for additional details: https://fractal-analytics-platform.github.io/fractal-server/install_and_deploy/

Make sure you have conda installed, then execute the `install_script.sh` to create a server environment.

Modify the `server_config_and_start.sh` script to your setup. For example, if you want to test Fractal locally on your machine, change the `FRACTAL_RUNNER_BACKEND` variable to `process` and remove the `FRACTAL_SLURM_CONFIG_FILE`. If you want to run Fractal on your slurm setup, provide a `config_slurm.json` file with your details (based on `config_uzh.json`).

The `server_config_and_start.sh` defaults to putting the `.fractal_server.env` with the environment variables, the database and additional content in the folder you're running the script from. 

Run `server_config_and_start.sh` to start the server.

