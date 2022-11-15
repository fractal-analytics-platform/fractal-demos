rm -r tmp

for RUN in {0..20}; do
    echo $RUN
    ./run_example.sh $RUN > /dev/null 2>&1
done
