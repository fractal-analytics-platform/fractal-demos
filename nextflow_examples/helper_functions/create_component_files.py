import json_helper
import json
import argparse

def create_component_files(metadata_path, filename_prefix=None):
    # Creating tiny text files just containing the name of a component
    # Silly way to do things, but couldn't find a better way to pass arguments 
    # between Nextflow steps
    metadata_dict = json_helper.load_json(metadata_path)
    for i, component in enumerate(metadata_dict['image']):
        if filename_prefix:
            filename = f"{filename_prefix}_{i}_component.txt"
        else:
            filename = f"{i}_component.txt"
        with open(filename, 'w') as outfile:
            outfile.write(component)

def parse_args():
    parser = argparse.ArgumentParser(
                prog='Component Writer',
                description='Stores each component in its own file',
            )
    parser.add_argument('--metadata_path')
    parser.add_argument('--filename_prefix')

    args=parser.parse_args()
    return args

                
if __name__ == '__main__':
    inputs = parse_args()
    create_component_files(
        inputs.metadata_path,
        inputs.filename_prefix
    )