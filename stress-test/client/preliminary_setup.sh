conda activate fractal-client-stress-test
rm .cache -r
rm -r tmp

VERSION="0.1.0"

fractal task collect `pwd`/fractal-tasks-stresstest/dist/fractal_tasks_stresstest-${VERSION}-py3-none-any.whl

sleep 5
fractal task check-collection 1
