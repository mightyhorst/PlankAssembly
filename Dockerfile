# Base image from DockerHub
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

# 💾 Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    nano \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 🗂️ Clone the PlankAssembly repository
COPY . .

# 🌳 Install Conda environment and run scripts
RUN chmod +x scripts/step-00-install-deps.sh && \
    ./scripts/step-00-install-deps.sh && \
    chmod +x scripts/step-01-download-data.sh && \
    ./scripts/step-01-download-data.sh && \
    chmod +x scripts/step-02-download-checkpoints.sh && \
    ./scripts/step-02-download-checkpoints.sh && \
    chmod +x scripts/step-03-generate-data.sh && \
    ./scripts/step-03-generate-data.sh && \
    chmod +x scripts/step-04-test.sh && \
    ./scripts/step-04-test.sh && \
    chmod +x scripts/step-05-evaluate.sh && \
    ./scripts/step-05-evaluate.sh && \
    chmod +x scripts/step-06-html.sh && \
    ./scripts/step-06-html.sh

# 👾 Expose port for Jupyter Notebook
EXPOSE 22
EXPOSE 80
EXPOSE 8080
