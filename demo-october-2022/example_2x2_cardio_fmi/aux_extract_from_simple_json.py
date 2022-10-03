import json
import sys


assert len(sys.argv[1:]) > 1

filename, which_id = sys.argv[1:3]
if which_id == "dataset_id":
    assert len(sys.argv[1:]) == 3
    dataset_name = sys.argv[3]

with open(filename, "r") as fin:
    d = json.load(fin)

if which_id == "project_id":
    # Safety check
    assert "project_dir" in d.keys()
    print(d["id"])
elif which_id == "dataset_id":
    dataset_list = d["dataset_list"]
    dataset_id = next(ds["id"]
                      for ds in dataset_list
                      if ds["name"] == dataset_name)
    print(dataset_id)
else:
    raise Exception("ERROR: {which_id=}")