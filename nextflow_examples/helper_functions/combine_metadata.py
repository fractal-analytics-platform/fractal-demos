import json_helper
import json
import argparse

def combine_metadata(metadata_old, metadata_diff, save_path):
    metadata_dict = json_helper.load_json(metadata_old)
    metadata_diff_dict = json_helper.load_json(metadata_diff)
    for key, value in metadata_diff_dict.items():
        metadata_dict[key] = value

    with open(save_path, 'w') as outfile:
        outfile.write(json.dumps(metadata_dict, indent=4))

def parse_args():
    parser = argparse.ArgumentParser(
                prog='Json Helper',
                description='Combines JSON files for Fractal',
            )
    parser.add_argument('--metadata_old')
    parser.add_argument('--metadata_diff')
    parser.add_argument('--save_path')

    args=parser.parse_args()
    return args

                
if __name__ == '__main__':
    inputs = parse_args()
    combine_metadata(
        inputs.metadata_old, 
        inputs.metadata_diff, 
        inputs.save_path,
    )