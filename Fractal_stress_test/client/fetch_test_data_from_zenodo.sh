#!/bin/bash

DOI="10.5281/zenodo.7059515"
CLEAN_DOI=${DOI/\//_}
pip install zenodo-get
zenodo_get $DOI -o ../images/${CLEAN_DOI}
