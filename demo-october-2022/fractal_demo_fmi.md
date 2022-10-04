# Fractal Demo October 2022

Preparation:
- You can ssh to the 1016: `ssh username@vcl1016.fmi.ch` & log in with your credentials
- You have a local napari environment installed on your laptop (see [installation_instructions.md](https://github.com/jluethi/fractal-demos/blob/main/demo-october-2022/installation_instructions.md))

## Run a Fractal workflow yourself
Run Fractal Workflow  

1. Connect to 1016  
`ssh username@vcl1016.fmi.ch` & log in with your credentials

2. Go to the correct folder  
`cd /tungstenfs/scratch/gliberal/Fractal_Dev/fractal/fractal-demos/demo-october-2022/example_2x2_cardio_fmi/`
Follow the instructions to run the example in `example_2x2_cardio_fmi`

3. Activate the bash profile  
`source .bashrc`

4. Activate the fractal-client conda environment  
`conda activate fractal-client`

5. Follow instructions on how the client works / have a look at your own `run_fractal_demo.sh` file  

6. Run your fractal demo file  
`. joel_run_fractal_demo.sh`

7. To see what's running on the cluster, check squeue:  
`squeue --format "%.18i %.9P %.8j %.8u %.8T %.10M %.9l %.6D %R %C %m"`

8. Once your job has finished running on the cluster, check your output folder (something like `joel_output`):  
`cd ..`   
`cd joel_output`  
`ls`

## Visualize an OME-Zarr file in napari
To view the output OME-Zarr file we just created, make sure you have a python environment with napari & the napari-ome-zarr plugin installed (see [installation_instructions.md](https://github.com/jluethi/fractal-demos/blob/main/demo-october-2022/installation_instructions.md)). Activate it by e.g. (change napari to your environment name):
`conda activate napari`

Before starting napari, turn on the async mode (not required anymore in the new async branch):  
`export NAPARI_ASYNC=1`

Then start napari:  
`napari`

If you could not run part 1, you can download the example OME-Zarr dataset here (the MIP is the most relevant):  
[10.5281/zenodo.7120354](https://zenodo.org/record/7120354)

## Use Jupyter notebook to load ROIs & visualize features
Lazy loading of OME-Zarr files in napari gets you far. But there are certain things that get tricky 
(e.g. 3D view) and others that haven't been implemented yet (e.g. visualizing features). 
For that purpose, we will use a jupyter notebook 

Activate your environment again  
`conda activate napari`

Download the demo repository locally:  
`git clone https://github.com/jluethi/fractal-demos`

Go into the correct folder & start jupyter lab
`cd fractal-demos/demo-october-2022`  
`jupyter-lab`

Follow the instructions in the `ROIs_and_FeatureVis.ipynb` notebook
