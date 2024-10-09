# Base image from DockerHub
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

# 💾 Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    nano \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 🗂️ Clone the PlankAssembly repository into the workspace
COPY . .

# 🐍 Install Conda environment globally
COPY environment.yml .
RUN /opt/conda/bin/conda env update --name base --file /workspace/environment.yml --prune && \
    /opt/conda/bin/conda init bash && \
    echo "source activate plankassembly" > ~/.bashrc

# 🛠️ Install pip dependencies (if needed)
# COPY requirements.txt /workspace/
# RUN pip install -r /workspace/requirements.txt

# 🧩 Set environment variables to persist Conda activation
ENV PATH /opt/conda/envs/plankassembly/bin:$PATH
SHELL ["bash", "-c"]

# 🗂️ Run scripts in separate layers (no need to reactivate environment each time)
RUN chmod +x scripts/step-01-download-data.sh && \
    ./scripts/step-01-download-data.sh

RUN chmod +x scripts/step-02-download-checkpoints.sh && \
    ./scripts/step-02-download-checkpoints.sh

RUN chmod +x scripts/step-03-generate-data.sh && \
    ./scripts/step-03-generate-data.sh

RUN chmod +x scripts/step-04-test.sh && \
    ./scripts/step-04-test.sh

RUN chmod +x scripts/step-05-evaluate.sh && \
    ./scripts/step-05-evaluate.sh

RUN chmod +x scripts/step-06-html.sh && \
    ./scripts/step-06-html.sh

# 👾 Expose ports for Jupyter Notebook
EXPOSE 22
EXPOSE 80
EXPOSE 8080
