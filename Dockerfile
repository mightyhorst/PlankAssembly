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

# 🌳 scripts
RUN sh scripts/step-00-install-deps.sh
RUN sh scripts/step-01-download-data.sh
RUN sh scripts/step-02-download-checkpoints.sh
RUN sh scripts/step-03-generate-data.sh
RUN sh scripts/step-04-test.sh
RUN sh scripts/step-05-evaluate.sh
RUN sh scripts/step-06-html.sh

# 👾 Expose port for Jupyter Notebook
EXPOSE 22
EXPOSE 80
EXPOSE 8080
