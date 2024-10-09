#!/bin/bash

#
# @step 🌺 create environment
#

# Create the conda environment
conda env create --file environment.yml

# Initialize conda for bash and activate the environment in the same RUN command
# This avoids needing to "source" .bashrc, which isn't portable in Docker
RUN echo "conda activate plankassembly" >> ~/.bashrc && \
    conda init bash && \
    bash -c "source ~/.bashrc && conda activate plankassembly && conda info --envs"

#
# @step 🗂️ folders
#
mkdir -p ./lightning_logs/version_0/
