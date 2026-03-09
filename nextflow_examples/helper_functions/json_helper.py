import json
import argparse

def load_json(path):
    with open(path, 'r') as json_file:
        data = json.load(json_file)
    
    return data

def combine_parameters(params_dict, input_path, output_path, metadata_path=None, component = None):
    if metadata_path:
        metadata_dict = load_json(metadata_path)
    else:
        metadata_dict={}

    new_dict = {
        "input_paths": [input_path],
        "output_path": output_path,
        "metadata": metadata_dict
    }

    if component:
        new_dict["component"] = component

    combined_dict = new_dict | params_dict

    return combined_dict

def create_combined_json(save_path, args_path, input_path, output_path, metadata_path=None, component = None):
    if args_path:
        params_dict = load_json(args_path)
    else:
        params_dict = {}
    combined_dict = combine_parameters(params_dict, input_path, output_path, metadata_path, component)
    with open(save_path, 'w') as outfile:
        outfile.write(json.dumps(combined_dict, indent=4))

def parse_args():
    parser = argparse.ArgumentParser(
                prog='Json Helper',
                description='Combines JSON files for Fractal',
            )
    parser.add_argument('--save_path')
    parser.add_argument('--args_path')
    parser.add_argument('--input_path')
    parser.add_argument('--output_path')
    parser.add_argument('--metadata_path')
    parser.add_argument('--component')

    args=parser.parse_args()
    return args

                
if __name__ == '__main__':
    inputs = parse_args()
    create_combined_json(
        inputs.save_path, 
        inputs.args_path, 
        inputs.input_path,
        inputs.output_path, 
        inputs.metadata_path, 
        inputs.component
    )
