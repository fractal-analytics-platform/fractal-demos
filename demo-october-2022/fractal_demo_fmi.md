# Fractal Demo October 2022

Preparation:
- You can ssh to 1016
- You have a napari environment installed (see installation_instructions.md)

## Step 1
Run Fractal Workflow

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