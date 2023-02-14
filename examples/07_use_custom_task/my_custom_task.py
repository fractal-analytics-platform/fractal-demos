from pathlib import Path
import json
import logging
from argparse import ArgumentParser
from typing import Sequence
from typing import Dict
from typing import Any

"""
WARNING:root:input_paths=['/home/tommaso/Fractal/fractal-demos/examples/07_use_custom_task/../images/10.5281_zenodo.7059515/*.png']
WARNING:root:output_path='/home/tommaso/Fractal/fractal-demos/examples/07_use_custom_task/tmp_4/output/*.zarr'
WARNING:root:metadata={}
WARNING:root:num_levels=10
"""


def task_function(
        *,
        input_paths: Sequence[Path],
        output_path: Path,
        metadata: Dict[str, Any],
        num_levels: int = 3,
        ):

    Path(output_path).parent.mkdir(exist_ok=True, parents=True)
    with (Path(output_path).parent / "output.txt").open("w") as f:
        f.write("Arguments:\n")
        f.write(f"    {input_paths=}\n")
        f.write(f"    {output_path=}\n")
        f.write(f"    {metadata=}\n")
        f.write(f"    {num_levels=}\n\n")
        f.write("Some \"scientific\" output:\n")
        f.write(f"    {(1+1)=}\n\n")
        f.write("End of the task.\n")
    return {"some": "metadata"}


if __name__ == "__main__":

    # Parse `-j` and `--metadata-out` arguments
    parser = ArgumentParser()
    parser.add_argument(
        "-j", "--json", help="Read parameters from json file", required=True
    )
    parser.add_argument(
        "--metadata-out",
        help="Output file to redirect serialised returned data",
        required=True,
    )
    args = parser.parse_args()

    # Preliminary check
    if Path(args.metadata_out).exists():
        logging.error(
            f"Output file {args.metadata_out} already exists. Terminating"
        )
        exit(1)

    # Read parameters dictionary
    with open(args.json, "r") as f:
        pars = json.load(f)

    # Validating arguments' types and run task
        logging.info("START  task")
        metadata_update = task_function(**pars)
        logging.info("END task")

    # Write output metadata to file, with custom JSON encoder
    with open(args.metadata_out, "w") as fout:
        json.dump(metadata_update, fout)
