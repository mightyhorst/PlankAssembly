# Base image from DockerHub
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

# 💾 Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    nano \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 🐍 Install Mamba (faster alternative to Conda)
# RUN /opt/conda/bin/conda install -y mamba -n base -c conda-forge

# 🗂️ Clone the PlankAssembly repository into the workspace
COPY . .

# 🐍 Create the Conda environment with Mamba and initialize for bash
# COPY environment.yml .
# RUN /opt/conda/bin/mamba env create --file environment.yml && \
#     /opt/conda/bin/conda init bash && \
#     echo "conda activate plankassembly" >> ~/.bashrc

# 🧩 Set environment variables to persist Conda activation
ENV PATH /opt/conda/envs/plankassembly/bin:$PATH
SHELL ["bash", "-c"]

# 🗂️ Run scripts in separate layers with Conda environment activated each time
RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    chmod +x scripts/step-01-download-data.sh && \
    ./scripts/step-01-download-data.sh"

RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    chmod +x scripts/step-02-download-checkpoints.sh && \
    ./scripts/step-02-download-checkpoints.sh"

RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    chmod +x scripts/step-03-generate-data.sh && \
    ./scripts/step-03-generate-data.sh"

RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    chmod +x scripts/step-04-test.sh && \
    ./scripts/step-04-test.sh"

RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    chmod +x scripts/step-05-evaluate.sh && \
    ./scripts/step-05-evaluate.sh"

RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    chmod +x scripts/step-06-html.sh && \
    ./scripts/step-06-html.sh"

# 👾 Expose ports for Jupyter Notebook
EXPOSE 22
EXPOSE 80
EXPOSE 8080
