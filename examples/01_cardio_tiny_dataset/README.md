First, you have to download a (tiny) dataset via
```
pip install zenodo-get
./fetch_test_data_from_zenodo.sh
```

**IMPORTANT**: The `BASE_FOLDER_EXAMPLE` at the top of the script needs to be adapted to point to the examples folder of the user you submit the example from.


Then run the example script, and you should obtain a zarr file in `tmp_cardio_tiny/output/20200812-CardiomyocyteDifferentiation14-Cycle1.zarr`.


Successfully ran with:
* fractal-server==0.3.3, fractal-client==0.2.9, fracal-tasks-core==0.2.3
* fractal-server==0.3.4, fractal-client==0.2.9, fracal-tasks-core==0.2.5
* fractal-server==0.3.5, fractal-client==0.2.9, fracal-tasks-core==0.2.6

