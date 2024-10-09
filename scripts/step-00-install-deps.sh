#!/bin/bash

#
# @step 🌺 create environment
#

# Create the conda environment
conda env create --file environment.yml

# Initialize conda for bash (this adds conda to bashrc for future sessions)
conda init bash

# Activate the 'plankassembly' environment in this session
source ~/.bashrc
conda activate plankassembly

# Show active environments to verify
conda info --envs

#
# @step 🗂️ folders
#
mkdir -p ./lightning_logs/version_0/
