## What is in this example?
This example shows how to register a custom task and the run it within a workflow.
The custom task shown is very simple.

CAREFUL: Don't add the same task multiple times. At the moment, the client depends on unique task names. If you want to rerun the addition of the custom task, change the LABEL value at the top of the script

## Client setup (from `00_user_setup` folder)
This only needs to be done once (unless the server is restarted again). Follow the instructions in the `00_user_setup` folder.

## Running an example through Fractal
This needs to be done in each example folder you're running
1. Switch to this example folder. 
2. Change the TASK_LABEL at the top of `add_custom_task`. Then run `add_custom_task`.
3. Run a dummy workflow that uses this task by running `run_custom_task.sh`.

Check the client documentation for details on using the Fractal Client: https://fractal-analytics-platform.github.io/fractal/install.html
Check the Fractal Tasks Core documentation for details on the individual tasks of this example workflow: https://fractal-analytics-platform.github.io/fractal-tasks-core/

This example ran successfully with:   
* `fractal-server==1.1.0a3, fractal-client==1.1.0a4, fracal-tasks-core==0.9.0`
