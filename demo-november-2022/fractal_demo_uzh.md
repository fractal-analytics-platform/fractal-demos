# Fractal Demo October 2022

Preparation:
- You can ssh to the pelkmans lab cluster, i.e. `ssh USERNAME@cluster.pelkmanslab.org` & log in with your credentials
- You can git clone the fractal-demos repository on the cluster, e.g. in your home folder: `cd ~; git clone https://github.com/fractal-analytics-platform/fractal-demos;`
- You have a local napari environment installed on your laptop (see [installation_instructions.md](https://github.com/jluethi/fractal-demos/blob/main/demo-november-2022/installation_instructions.md))

## Run a Fractal workflow yourself
Run Fractal Workflow  

1. Connect to the pelkmanslab cluster
`ssh USERNAME@cluster.pelkmanslab.org` & log in with your credentials

2. Go to the fractal-demos folder you cloned. If you used the command above, you can:  
`cd fractal-demos/demo-november-2022/example_2x2_cardio_uzh/`

3. If conda is unavailable for you at login, run this  
`source /opt/easybuild/software/Anaconda3/2019.07/etc/profile.d/conda.sh`

4. Activate the shared fractal-client conda environment  
`conda activate /data/homes/fractal/sharedfractal`

5. Download the example data we're using today:  
`. fetch_test_data_from_zenodo.sh`
(If you can't download the image data, is is also available at `/data/homes/jluethi/03_fractal/fractal-demos/examples/images/10.5281_zenodo.7057076` and you can change the input path in the `run_fractal_demo.sh` to that)

6. Follow instructions on how the client works / have a look at the `run_fractal_demo.sh` file. If fractal-demos is not in your home folder, you will need to change the `BASE_FOLDER_EXAMPLE` at the top of your `run_fractal_demo.sh` file.

7. Run your fractal demo file  
`. run_fractal_demo.sh`

8. To see what's running on the cluster, check squeue:  
`watch -n 1 squeue`

9. Once your job has finished running on the cluster, check your output folder:  
`cd ~/fractal-demos/demo-november-2022/output_cardio_2x2`

## Visualize an OME-Zarr file in napari
To view the output OME-Zarr file we just created, make sure you have a local python environment with napari & the napari-ome-zarr plugin installed  on your laptop (see [installation_instructions.md](https://github.com/jluethi/fractal-demos/blob/main/demo-october-2022/installation_instructions.md)). Activate it by e.g. (change napari to your environment name):
`conda activate napari`

Before starting napari, turn on the async mode (not required anymore in the new async branch):  
`export NAPARI_ASYNC=1`

Then start napari:  
`napari`

If you can't mount your home share on your computer or could not run part 1, you can download the example OME-Zarr dataset here (the MIP is the most relevant, but this dataset also contains 3D segmentation & measurements):  
[10.5281/zenodo.7144919](https://zenodo.org/record/7144919)

## Use Jupyter notebook to load ROIs & visualize features
Lazy loading of OME-Zarr files in napari gets you far. But there are certain things that get tricky 
(e.g. 3D view) and others that haven't been implemented yet (e.g. visualizing features). 
For that purpose, we will use a jupyter notebook 

Activate your environment again  
`conda activate napari`

Go into the correct folder & start jupyter lab
`cd ~/fractal-demos/demo-november-2022`  
`jupyter-lab`

Follow the instructions in the `ROIs_and_FeatureVis.ipynb` notebook

## Use the alpha version of napari-roi-loader for ROI loading
If you want to try the alpha version of the napari-roi-loader plugin to load ROIs into napari:  
Make sure it is installed in your environment (`pip install git+https://github.com/jluethi/napari-ome-zarr-roi-loader.git`)

1. Start napari by typing the following in your console where the napari environment is activated: `napari`

2. Start the plugin: Go to Plugins > napari-ome-zarr-roi-loader: Load OME-Zarr ROI Widget

3. Choose the Zarr file by clicking Choose Directory (the alpha version just supports individual Zarr files, not HCS plates yet => a valid choice would be `PATH/TO/20200812-CardiomyocyteDifferentiation14-Cycle1.zarr/B/03/0`)

4. Choose the parameters (e.g. `FOV_ROI_table`, 0, 0, 0) & click `Run`. napari will briefly be unresponsive, then the data is loaded into memory & you can go into 3D mode etc.

