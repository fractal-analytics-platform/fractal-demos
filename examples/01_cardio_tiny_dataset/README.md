First, you have to download a (tiny) dataset via
```
pip install zenodo-get
./fetch_test_data_from_zenodo.sh
```

**IMPORTANT**: the `INPUT_PATH` and `OUTPUT_PATH` variables (in `run_example.sh`) must be updated to an absolute path pointing to the two folders where images are and where you want the output to be. The current version only works when the server admin and user are actually the same user, working from the same examples directory.

Then run the example script, and you should obtain a zarr file in `tmp_cardio_tiny/output/20200812-CardiomyocyteDifferentiation14-Cycle1.zarr`.


Successfully ran with:
* fractal-server==0.3.3, fractal-client==0.2.9, fracal-tasks-core==0.2.3
* fractal-server==0.3.4, fractal-client==0.2.9, fracal-tasks-core==0.2.5
* fractal-server==70fe645ea200e502d9d1758ba298b240e0abd4ee (to become 0.3.5), fractal-client==0.2.9, fracal-tasks-core==0.2.4
