#!/bin/bash
#
#👉 conda install pytorch==1.10.0 torchvision==0.11.0 torchaudio==0.10.0 cudatoolkit=11.3 -c pytorch -c conda-forge
# pip install pytorch-lightning==1.7.7 torchmetrics==0.11.4 rich==12.5.1 'jsonargparse[signatures]'
# conda deactivate
apt-get install -y nano
pip install pip==23.2.1
# pip install pytorch-lightning==1.7.7 torchmetrics==0.11.4 rich==12.5.1 'jsonargparse[signatures]'
# pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu113/torch1.10/detectron2-0.6%2Bcu113-cp38-cp38-linux_x86_64.whl
# conda install -c conda-forge pythonocc-core=7.6.2
# pip install numpy shapely svgwrite svgpathtools trimesh setuptools==59.5.0 html4vision


#
# @step download the data
#
wget https://manycore-research-azure.kujiale.com/manycore-research/PlankAssembly/data.zip
alias install="apt-get install -y"
install unzip
unzip data.zip

#
# @step generate data
# 
python dataset/render_complete_svg.py
python dataset/render_complete_svg.py dataset/render_noisy_svg.py --data_type noise_05 --noise_ratio 0.05
python dataset/render_noisy_svg.py --data_type noise_05 --noise_ratio 0.05
python dataset/render_visible_svg.py
python dataset/prepare_info.py 
python misc/build_gt_mesh.py

#
# @step test
#
python trainer_complete.py test --config configs/train_complete.yaml
python trainer_complete.py test --config configs/train_complete.yaml --trainer.devices 1 --ckpt_path ./line_complete-checkpoint_999-precision\=0.944-recall\=0.934-f1\=0.938>

#
# @step evaluate and generate html
#
python misc/build_pred_mesh.py
python evaluate.py --exp_path ./lightning_logs/version_0
python misc/build_html.py --exp_path ./lightning_logs/version_0/

#
# @step fix svgs path for html page
#
cp -R data/data/complete/svgs ./lightning_logs/version_0/svgs

#
# @step kill jupyter and server html
# 👉 kill -9 333
# 👉 python -m http.server 8080
