#!/usr/bin/env python3 
# 4-space indented, v0.0.1
# File name: map_chrom_names.py
# Description: Map back chromosome identifiers to the patched assembly after ragtag patch is run.
# Author: Robert Linder
# Date: 2024-08-26

import argparse
import re 
import numpy as np

def parse_args():
	"""this enables users to provide input as command line arguments to minimize the need for directly modifying the script; please enter '-h' to see the full list of options"""
	parser = argparse.ArgumentParser(description="Map chromosome names to the patched assembly")
	parser.add_argument("scaffold_file", type=str, help="scaffolded sequence lengths file")
	parser.add_argument("patch_file", type=str, help="patched sequence lengths file")
	args = parser.parse_args()
	return args

def map_chr_names(scaffold, patch):
    """Iterate through the scaffold and patch sequences and lengths to map chromosome identifiers back to the appropriate patched sequences"""
    scaffold_lens = []
    scaffold_names = []
    patch_lens = []
    patch_names = []
    with open(scaffold, 'r') as scaff, open(patch, 'r') as pat, open("map_ids.txt", 'w') as output:
        for line in scaff:
             fields = line.split('\t')
             scaffold_lens.append(int(fields[1].split('\n')[0]))
             scaffold_names.append(fields[0])
        for line in pat:
             fields = line.split('\t')
             patch_lens.append(int(fields[1].split('\n')[0]))
             patch_names.append(fields[0])
        scaffold_lens = np.array(scaffold_lens)
        patch_lens = np.array(patch_lens)
        closest_indices = np.argmin(np.abs(patch_lens[:, np.newaxis] - scaffold_lens), axis = 0)
        patch_names_ordered = [patch_names[i] for i in list(closest_indices)]
        for idx, chrom in enumerate(scaffold_names):
            output.write(f"{patch_names_ordered[idx]}\t{chrom}\n")

def main():
    inputs = parse_args()
    scaffold =  inputs.scaffold_file
    patch = inputs.patch_file
    map_chr_names(scaffold, patch)

if __name__ =="__main__":
    main()