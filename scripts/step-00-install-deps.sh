#!/bin/bash

#
# @step 🌺 create environment
#
conda env create --file environment.yml 
conda init
source ~/.bashrc 
conda activate plankassembly

#
# @step 🗂️ folders
#
mkdir -p ./lightning_logs/version_0/
