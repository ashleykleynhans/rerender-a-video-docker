#!/usr/bin/env bash

export PYTHONUNBUFFERED=1

echo "Template version: ${TEMPLATE_VERSION}"

if [[ -e "/workspace/template_version" ]]; then
    EXISTING_VERSION=$(cat /workspace/template_version)
else
    EXISTING_VERSION="0.0.0"
fi

sync_apps() {
    # Sync venv to workspace to support Network volumes
    echo "Syncing venv to workspace, please wait..."
    rsync --remove-source-files -rlptDu /venv/ /workspace/venv/

    # Sync Rerender a Video to workspace to support Network volumes
    echo "Syncing Rerender a Video to workspace, please wait..."
    rsync --remove-source-files -rlptDu /Rerender_A_Video/ /workspace/Rerender_A_Video/

    echo "${TEMPLATE_VERSION}" > /workspace/template_version
}

fix_venvs() {
    # Fix the venv to make it work from /workspace
    echo "Fixing venv..."
    /fix_venv.sh /venv /workspace/venv
}

if [ "$(printf '%s\n' "$EXISTING_VERSION" "$TEMPLATE_VERSION" | sort -V | head -n 1)" = "$EXISTING_VERSION" ]; then
    if [ "$EXISTING_VERSION" != "$TEMPLATE_VERSION" ]; then
        sync_apps
        fix_venvs

        # Create directories
        mkdir -p /workspace/logs /workspace/tmp
    else
        echo "Existing version is the same as the template version, no syncing required."
    fi
fi

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
