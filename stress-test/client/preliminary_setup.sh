conda activate fractal-client-stress-test

CACHE_DIR=`pwd`/cache

rm -r $CACHE_DIR
rm -r tmp

USER_ID=`fractal --batch user whoami`
fractal user edit $USER_ID --new-cache-dir $CACHE_DIR


VERSION="1.0.0"

fractal task collect `pwd`/fractal-tasks-stresstest/dist/fractal_tasks_stresstest-${VERSION}-py3-none-any.whl

sleep 5
fractal task check-collection 1
