# Installation
1. Create a conda environment: `conda create --name nextflow-fractal python=3.9 -y`
2. Activate the environment: `conda activate nextflow-fractal`
3. Install nextflow: `conda install -c bioconda nextflow -y`
4. (On Macs: Install imagecodecs separately: `conda install imagecodecs -y`)
5. Install fractal-tasks-core in the version you want: `pip install fractal-tasks-core`
6. (Install nomkl to avoid `OMP: Error #15: Initializing libomp.dylib, but found libomp.dylib already initialized.`: `conda install nomkl -y`)
7. Get the base folder where fractal-tasks-core Python files are put (e.g. `/Users/joel/opt/miniconda3/envs/nextflow-fractal/lib/python3.9/site-packages/fractal_tasks_core/` => in the conda environment) or download the tasks separately to a known folder. This folder will be needed in the nextflow scripts.



