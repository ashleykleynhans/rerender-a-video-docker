#!/usr/bin/env bash
echo "Starting Rerender a Video"
mkdir -p /workspace/logs
VENV_PATH=$(cat /workspace/Rerender_A_Video/venv_path)
source ${VENV_PATH}/bin/activate
cd /workspace/Rerender_A_Video
export GRADIO_SERVER_NAME="0.0.0.0"
export GRADIO_SERVER_PORT="3001"
nohup python3 webUI.py > /workspace/logs/rerender_a_video.log 2>&1 &
echo "Rerender a Video started"
echo "Log file: /workspace/logs/rerender_a_video.log"
deactivate
