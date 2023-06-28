cp ../00_user_setup/.fractal.env .
cp ../00_user_setup/.fractal.env A_many_running_workflows_and_tasks/
cp ../00_user_setup/.fractal.env B_test_db_connections/


VERSION="2.0.0"
fractal task collect `pwd`/fractal-tasks-stresstest/dist/fractal_tasks_stresstest-${VERSION}-py3-none-any.whl
echo "Check status with: fractal task check-collection ID"
