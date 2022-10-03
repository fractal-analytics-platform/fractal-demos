# Installation instructions napari

Make sure you have conda installed. In this tutorial, we will install python via miniconda. However, if you already have anaconda, miniconda, or miniforge installed, those will work as well and you can skip to the next section.

1. In your web browser, navigate to the [miniconda page](https://docs.conda.io/en/latest/miniconda.html).
2. Scroll down to the "Latest Miniconda Installer Links" section. Click the link to download the appropriate version for your operating system.
  - **Windows**: Most likely the Miniconda3 Windows 64-bit  
	- **Mac OS**: Choose between Apple M1 (new Macs with Apple Silicon) or MacOSX. Choose the pkg download for an easy installation procedure  
3. Once you have downloaded the miniconda installer, run it to install python and follow the installer instructions.


## Standard installation napari environment
Use the terminal on Mac & Linux or the Anaconda Prompt on Windows.
`conda create -y --name napari python=3.8`
`conda activate napari`
`pip install napari`
`pip install napari-ome-zarr`
`pip install jupyterlab`

## Advanced installation napari environment
There are versions of the ome-zarr plugin and of core napari that improve the experience, but they are still in development. If you want to check out one of these branches, here are the instructions. Be careful though: The installation is more involved then the standard installation above and there may be bugs in those branches. Among other things, I can only get the napari async branch working in Python 3.10 at the moment.
For today's demo, it doesn't add much to use this version, as it mostly helps with responsiveness when loading very large datasets. But it may be useful in the future.

### Get the new async napari branch
```
conda create -y --name napari-dev python=3.10
conda activate napari-dev

git clone https://github.com/napari/napari
cd napari

# Get the async pull request
git fetch origin pull/4905/head
git checkout -b async_4905 FETCH_HEAD

# Install this version of napari
pip install -e .
# Somehow pyqt is missing from this installation and needs to be installed manually
conda install -y pyqt

# Install the ome-zarr-py version that can load labels for plates
cd ..
git clone https://github.com/ome/ome-zarr-py
cd ome-zarr-py
git fetch origin pull/207/head
git checkout -b plate_207 FETCH_HEAD
pip install -e .

# Install the dev version of the napari-ome-zarr plugin
cd ..
git clone https://github.com/ome/napari-ome-zarr
cd napari-ome-zarr 
git fetch origin pull/54/head
git checkout -b plate_54 FETCH_HEAD
pip install -e .

# Install jupyter lab
pip install jupyterlab
```


## Known issues & workarounds
1. Conda can't install dependencies because of proxy settings.
Check whether you have specified proxy variables. For windows, they are set [here](https://docs.oracle.com/en/database/oracle/machine-learning/oml4r/1.5.1/oread/creating-and-modifying-environment-variables-on-windows.html#GUID-DD6F9982-60D5-48F6-8270-A27EC53807D0) and deleting them solved the issues for some users. On Mac, they would be set in the .bashrc or .zshrc file in your home directory.

2. (Error appears to be solved, I don't run into it anymore) Can't install PyQt5 on M1 macs. `AttributeError: module 'sipbuild.api' has no attribute 'prepare_metadata_for_build_wheel'`
The problem: The current version of PyQt5 in pip does not support M1 macs. Install manually via conda before installing napari:
`conda install pyqt`

3. (You shouldn't need this for today's demo) Installing `imagecodecs` fails on M1 Macs
Install manually using conda: `conda install imagecodecs`


# Installation instructions Fractal client

To install the fractal client, you can just:

`pip install fractal-client`

In the current setup, ports of the server aren't publicly exposed. Thus, if one wants to use a local client, port-forwarding from the server is necessary, e.g. 
`ssh -L 8000:localhost:8000 cluster`
(where cluster is the ssh host name for the machine running the server)

See [here](https://github.com/fractal-analytics-platform/fractal#installation) for additional details about the client setup.

# Installation instructions Fractal server

Installation instructions for the server will change. Find current instructions here: https://github.com/fractal-analytics-platform/fractal-server#installation
