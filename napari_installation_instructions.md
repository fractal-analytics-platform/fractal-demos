# napari async installation

This guide walks you through installing the current main version of napari, which has better support to load large OME-Zarr data than the released napari version 0.4.18.
It also shows how to install a few of our often needed plugins.

## Setting up conda

In this tutorial, we will install python via miniconda. However, if you already have anaconda, miniconda, or miniforge installed, those will work as well and you can skip to the next section.

1. In your web browser, navigate to the [miniconda page](https://docs.conda.io/en/latest/miniconda.html).
2. Scroll down to the "Latest Miniconda Installer Links" section. Click the link to download the appropriate version for your operating system.
  - **Windows**: Most likely the Miniconda3 Windows 64-bit  
	- **Mac OS**: Choose between Apple M1 (new Macs with Apple Silicon) or MacOSX. Choose the pkg download for an easy installation procedure  
3. Once you have downloaded the miniconda installer, run it to install python and follow the installer instructions.

In some setups, conda is already installed, but you need to activate it first.
For a faster setup, check out [mamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html)

## Setting up your environment
1. Open your terminal.
	- **Windows**: Open Anaconda Prompt
	- **Mac OS**: Open Terminal (you can search for it in spotlight - cmd + space)
	- **Linux**: Open your terminal application

2. We want to install napari in its own evnironment. This ensures that it does not interfere with your other python projects. To create the environment (named `napari`), enter the following command.

	```
	conda create -n napari python=3.10 -y
	```

3. Activate your environment

   	```
    	conda activate napari
    	```

## Installing napari & plugins
1. Clone the napari repository

```
git clone https://github.com/napari/napari
cd napari
```

2. (If necessary, get a specific version of napari (I'd expect all main versions to work decently here, but it's only tested with this one))

```
git checkout 91868815831cbf58141824d01d4942d2143bb31b
```

3. Install napari

```
pip install -e .
```

4. Install qt

```
conda install pyqt -y
```

5. Install plugins:

```
pip install napari-ome-zarr
pip install napari-feature-classifier
pip install git+https://github.com/jluethi/napari-ome-zarr-roi-loader.git
```

## Activate the new async mode in napari
The first time you open napari, go to the napari preferences (via the File/napari menu, top left). In the experimental tab, check the box at "Render Images Asynchronously".



