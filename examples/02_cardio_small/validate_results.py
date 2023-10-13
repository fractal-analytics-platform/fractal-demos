import zarr
import itertools
import logging
import sys
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s; %(levelname)s; %(message)s"
)

outdir = Path("output-cardio-2x2-zenodo-subset-1")
f1 = outdir / "20200812-CardiomyocyteDifferentiation14-Cycle1.zarr"
f2 = outdir / "20200812-CardiomyocyteDifferentiation14-Cycle1_mip.zarr"


for path in [
        f1,
        f1 / "B/03/0",
        f1 / "B/03/0/tables",
        f1 / "B/03/0/tables/well_ROI_table",
        f1 / "B/03/0/tables/FOV_ROI_table",
        f2,
        f2 / "B/03/0",
        f2 / "B/03/0/tables",
        f2 / "B/03/0/tables/well_ROI_table",
        f2 / "B/03/0/tables/FOV_ROI_table",
        ]:
    try:
        g = zarr.open_group(path.as_posix(), "r")
        logging.info(f"{path} is a valid zarr group")
        logging.info(f"Sub-groups/arrays: {list(g.keys())}")
    except Exception as e:
        logging.error(f"{path} is not a valid zarr group")
        logging.error(f"Original error: {str(e)}")
        sys.exit(1)

for (f, level) in itertools.product((f1, f2), range(5)):
    try:
        path = f / "B/03/0" / str(level)
        a = zarr.open_array(path.as_posix(), "r")
        logging.info(f"{path} is a valid zarr array")
    except Exception as e:
        logging.error(f"{path} is not a valid zarr array")
        logging.error(f"Original error: {str(e)}")
        sys.exit(1)
