# 🌟 Base image from DockerHub
FROM pytorch/pytorch:2.4.0-cuda12.1-cudnn9-runtime

# 💾 Install essential dependencies
RUN apt-get update && apt-get install -y \
    git \
    nano \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 🗂️ Clone the PlankAssembly repository into the workspace
COPY . .

# 🌺 Step 1: Create Conda environment and set up for bash
RUN /opt/conda/bin/conda env create --file environment.yml && \
    /opt/conda/bin/conda init bash && \
    echo "source activate plankassembly" > ~/.bashrc && \
    bash -c "source ~/.bashrc && conda activate plankassembly && conda info --envs"

# 🗂️ Step 2: Create necessary folders
RUN mkdir -p ./lightning_logs/version_0/

# 🌳 Step 3: Download data
RUN wget https://manycore-research-azure.kujiale.com/manycore-research/PlankAssembly/data.zip && \
    unzip data.zip

# 🌟 Step 4: Download checkpoints
RUN wget https://manycore-research-azure.kujiale.com/manycore-research/PlankAssembly/models/line_complete-checkpoint_999-precision=0.944-recall=0.934-f1=0.938.ckpt && \
    wget https://manycore-research-azure.kujiale.com/manycore-research/PlankAssembly/models/line_visible-checkpoint_999-precision=0.860-recall=0.843-f1=0.847.ckpt && \
    wget https://manycore-research-azure.kujiale.com/manycore-research/PlankAssembly/models/sideface-checkpoint_999-precision=0.944-recall=0.938-f1=0.939.ckpt

# 🐍 Step 5: Render input and generate data
RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    python dataset/render_complete_svg.py && \
    python dataset/render_noisy_svg.py --data_type noise_05 --noise_ratio 0.05 && \
    python dataset/render_visible_svg.py && \
    python dataset/prepare_info.py && \
    python misc/build_gt_mesh.py"

# 🧪 Step 6: Test the model
RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
    python trainer_complete.py test \
    --config configs/train_complete.cpu.yaml
#     --trainer.devices 1 \
#     --ckpt_path ./line_complete-checkpoint_999-precision=0.944-recall=0.934-f1=0.938.ckpt"

# 🐿️ Step 7: Evaluate and generate prediction mesh
# RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
#     python misc/build_pred_mesh.py && \
#     python evaluate.py --exp_path ./lightning_logs/version_0 && \
#     python misc/build_html.py --exp_path ./lightning_logs/version_0/"

# 🌳 Step 8: Generate final HTML report
# RUN bash -c "source ~/.bashrc && conda activate plankassembly && \
#     python misc/build_html.py --exp_path ./lightning_logs/version_0/"

# 👾 Expose ports for Jupyter Notebook
EXPOSE 22
EXPOSE 80
EXPOSE 8080
