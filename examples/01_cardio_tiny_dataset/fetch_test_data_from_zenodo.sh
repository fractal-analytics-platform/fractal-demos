#!/bin/bash

DOI="10.5281/zenodo.8287221"
CLEAN_DOI=${DOI/\//_}
zenodo_get $DOI -o ../images/${CLEAN_DOI}
