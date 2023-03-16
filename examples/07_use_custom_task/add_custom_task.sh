TASK_LABEL=meta-writer
# Get the credentials: If you followed the instructions, they can be copied 
# from the .fractal.env file in ../00_user_setup. Alternatively, you can write
# a .fractal.env file yourself or add --user & --password entries to all fractal
# commands below
cp ../00_user_setup/.fractal.env .fractal.env

# Add custom task to database
MY_TASK_NAME="my custom task $TASK_LABEL"
MY_TASK_COMMAND="`which python3` `pwd`/my_custom_task.py"
MY_TASK_SOURCE="my-new-source-$TASK_LABEL"
fractal task new "$MY_TASK_NAME" "$MY_TASK_COMMAND" "$MY_TASK_SOURCE"
