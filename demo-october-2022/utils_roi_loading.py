from typing import Iterable
from typing import List

import anndata as ad
import dask.array as da
import numpy as np
import pandas as pd
import zarr

def convert_ROI_table_to_indices(
    ROI: ad.AnnData,
    level: int = 0,
    coarsening_xy: int = 2,
    full_res_pxl_sizes_zyx: Iterable[float] = None,
    cols_xyz_pos: Iterable[str] = [
        "x_micrometer",
        "y_micrometer",
        "z_micrometer",
    ],
    cols_xyz_len: Iterable[str] = [
        "len_x_micrometer",
        "len_y_micrometer",
        "len_z_micrometer",
    ],
) -> List[List[int]]:

    # Set pyramid-level pixel sizes
    pxl_size_z, pxl_size_y, pxl_size_x = full_res_pxl_sizes_zyx
    prefactor = coarsening_xy**level
    pxl_size_x *= prefactor
    pxl_size_y *= prefactor

    x_pos, y_pos, z_pos = cols_xyz_pos[:]
    x_len, y_len, z_len = cols_xyz_len[:]

    origin_x = min(ROI[:, x_pos].X[:, 0])
    origin_y = min(ROI[:, y_pos].X[:, 0])
    origin_z = min(ROI[:, z_pos].X[:, 0])

    list_indices = []
    for FOV in ROI.obs_names:

        # Extract data from anndata table
        x_micrometer = ROI[FOV, x_pos].X[0, 0] - origin_x
        y_micrometer = ROI[FOV, y_pos].X[0, 0] - origin_y
        z_micrometer = ROI[FOV, z_pos].X[0, 0] - origin_z
        len_x_micrometer = ROI[FOV, x_len].X[0, 0]
        len_y_micrometer = ROI[FOV, y_len].X[0, 0]
        len_z_micrometer = ROI[FOV, z_len].X[0, 0]

        # Identify indices along the three dimensions
        start_x = x_micrometer / pxl_size_x
        end_x = (x_micrometer + len_x_micrometer) / pxl_size_x
        start_y = y_micrometer / pxl_size_y
        end_y = (y_micrometer + len_y_micrometer) / pxl_size_y
        start_z = z_micrometer / pxl_size_z
        end_z = (z_micrometer + len_z_micrometer) / pxl_size_z
        indices = [start_z, end_z, start_y, end_y, start_x, end_x]

        # Round indices to lower integer
        indices = list(map(round, indices))

        # Append ROI indices to to list
        list_indices.append(indices[:])

    return list_indices

def load_label_roi(zarr_url, well, roi_index_of_interest, labels_name, level=0,  image_index=0, roi_table='FOV_ROI_table'):
    # Loads the label image of a given ROI in a well
    # returns the image as a numpy array + a list of the image scale
    
    # image_index defaults to 0 (Change if you have more than one image per well) => FIXME for multiplexing
    
    # Get the ROI table
    roi_an = ad.read_zarr(zarr_url / f'{well}/{image_index}/tables/{roi_table}')
    
    # Load the pixel sizes from the OME-Zarr file
    attrs_path = zarr_url / f'{well}/{image_index}/labels/{labels_name}'
    dataset = 0 # FIXME, hard coded in case multiple multiscale 
    # datasets would be present & multiscales is a list
    with zarr.open(attrs_path) as metadata:
        scale_labels = metadata.attrs["multiscales"][dataset]['datasets'][level]['coordinateTransformations'][0]['scale']

    # Get ROI indices for labels
    list_indices = convert_ROI_table_to_indices(
        roi_an,
        level=level,
        full_res_pxl_sizes_zyx=scale_labels,
    )

    # Get the indices for a given roi
    indices = list_indices[roi_index_of_interest]
    s_z, e_z, s_y, e_y, s_x, e_x = indices[:]

    # Load labels
    label_data_zyx = da.from_zarr(zarr_url / f'{well}/{image_index}/labels/{labels_name}/{level}')
    label_roi = label_data_zyx[s_z:e_z, s_y:e_y, s_x:e_x]
    return np.array(label_roi), scale_labels

def load_intensity_roi(zarr_url, well, roi_index_of_interest, channel_index, level=0, image_index=0,  roi_table='FOV_ROI_table'):
    # Loads the intensity image of a given ROI in a well
    # returns the image as a numpy array + a list of the image scale
    
    # image_index defaults to 0 (Change if you have more than one image per well) => FIXME for multiplexing
    
    # Get the ROI table
    roi_an = ad.read_zarr(zarr_url / f'{well}/{image_index}/tables/{roi_table}')
    
    # Load the pixel sizes from the OME-Zarr file
    attrs_path = zarr_url / f"{zarr_url}/{well}/{image_index}"
    dataset = 0 # FIXME, hard coded in case multiple multiscale 
    # datasets would be present & multiscales is a list
    with zarr.open(attrs_path) as metadata:
        scale_img = metadata.attrs["multiscales"][dataset]['datasets'][level]['coordinateTransformations'][0]['scale']

    # Get ROI indices for labels
    list_indices = convert_ROI_table_to_indices(
        roi_an,
        level=level,
        full_res_pxl_sizes_zyx=scale_img,
    )

    # Get the indices for a given roi
    indices = list_indices[roi_index_of_interest]
    s_z, e_z, s_y, e_y, s_x, e_x = indices[:]

    
    # Load labels
    img_data_zyx = da.from_zarr(f"{zarr_url}/{well}/{image_index}/{level}")[channel_index]
    img_roi = img_data_zyx[s_z:e_z, s_y:e_y, s_x:e_x]
    return np.array(img_roi), scale_img