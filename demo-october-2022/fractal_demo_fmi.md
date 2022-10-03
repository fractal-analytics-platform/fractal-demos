# Fractal Demo October 2022

Preparation:
- You can ssh to the 1016
- You have a napari environment installed (see [installation_instructions.md](https://github.com/jluethi/fractal-demos/blob/main/demo-october-2022/installation_instructions.md))

## Step 1
Run Fractal Workflow  

Follow the instructions to run the example in `example_2x2_cardio_fmi`

Details of how to activate the environment & submit the example TBD.

## Step 2
Visualize OME-Zarr file

To view the output OME-Zarr file, make sure you have a python environment with napari & the napari-ome-zarr plugin installed (see installation_instructions.md). Activate it by e.g. (change napari to your environment name):
`conda activate napari`

Before starting napari, turn on the async mode (not required anymore in the new async branch):
`export NAPARI_ASYNC=1`

Then start napari:
`napari`

## Step 3
Use notebook for ROI loading & visualization
