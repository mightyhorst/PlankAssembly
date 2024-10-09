#!/bin/bash

#
# 👉 render complete inputs
#
python dataset/render_complete_svg.py

#
# 👉 render noisy inputs, please specify the noise ratio
#
python dataset/render_noisy_svg.py --data_type noise_05 --noise_ratio 0.05

#
# 👉 render visible inputs
#
python dataset/render_visible_svg.py

#
# 👉 create json info
#
python dataset/prepare_info.py

#
# 👉 create the ground tructh meshes
#
python misc/build_gt_mesh.py
