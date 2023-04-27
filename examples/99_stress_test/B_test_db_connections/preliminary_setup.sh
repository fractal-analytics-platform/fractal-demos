rm -r tmp
cp ../../00_user_setup/.fractal.env .

# Register user
VERSION="1.0.0"
fractal task collect `pwd`/../fractal-tasks-stresstest/dist/fractal_tasks_stresstest-${VERSION}-py3-none-any.whl
sleep 5
fractal task check-collection 1
