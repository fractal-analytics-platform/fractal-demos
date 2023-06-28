cp ../00_user_setup/.fractal.env .

VERSION="2.0.0"
fractal task collect `pwd`/fractal-tasks-stresstest/dist/fractal_tasks_stresstest-${VERSION}-py3-none-any.whl
echo "Check status with: fractal task check-collection 1"
