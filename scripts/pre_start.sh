#!/usr/bin/env bash
export PYTHONUNBUFFERED=1

echo "Container is running"

# Sync venv to workspace to support Network volumes
echo "Syncing venv to workspace, please wait..."
rsync -au /venv/ /workspace/venv/

# Sync Rerender a Video to workspace to support Network volumes
echo "Syncing Rerender a Video to workspace, please wait..."
rsync -au /Rerender_A_Video/ /workspace/Rerender_A_Video/

# Fix the venv to make it work from /workspace
echo "Fixing venv..."
/fix_venv.sh /venv /workspace/venv

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   cd /workspace/Rerender_A_Video"
    echo "   deactivate && source /workspace/venv/bin/activate"
    echo "   export GRADIO_SERVER_NAME=\"0.0.0.0\""
    echo "   export GRADIO_SERVER_PORT=\"3001\""
    echo "   python3 webUI.py"
else
    mkdir -p /workspace/logs
    echo "Starting Rerender a Video"
    source /workspace/venv/bin/activate
    cd /workspace/Rerender_A_Video
    export GRADIO_SERVER_NAME="0.0.0.0"
    export GRADIO_SERVER_PORT="3001"
    nohup python3 webUI.py > /workspace/logs/Rerender_A_Video.log 2>&1 &
    echo "Rerender a Video started"
    echo "Log file: /workspace/logs/Rerender_A_Video.log"
    deactivate
fi

echo "All services have been started"