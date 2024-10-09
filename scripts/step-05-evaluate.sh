#!/bin/bash

#
# @step 🐿️ evaluate and generate html
#
python misc/build_pred_mesh.py
python evaluate.py --exp_path ./lightning_logs/version_0
python misc/build_html.py --exp_path ./lightning_logs/version_0/