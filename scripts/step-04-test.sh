#!/bin/bash

python trainer_complete.py test \
    --config configs/train_complete.yaml \
    --trainer.devices 1 \
    --ckpt_path ./line_complete-checkpoint_999-precision=0.944-recall=0.934-f1=0.938.ckpt
