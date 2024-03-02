#!/usr/bin/env bash

export PYTHONUNBUFFERED=1
export APP="Rerender_A_Video"
DOCKER_IMAGE_VERSION_FILE="/workspace/${APP}/docker_image_version"

echo "Template version: ${TEMPLATE_VERSION}"
echo "venv: ${VENV_PATH}"

if [[ -e ${DOCKER_IMAGE_VERSION_FILE} ]]; then
    EXISTING_VERSION=$(cat ${DOCKER_IMAGE_VERSION_FILE})
else
    EXISTING_VERSION="0.0.0"
fi

sync_apps() {
    # Sync venv to workspace to support Network volumes
    echo "Syncing venv to workspace, please wait..."
    mkdir -p ${VENV_PATH}
    rsync --remove-source-files -rlptDu /venv/ ${VENV_PATH}/

    # Sync application to workspace to support Network volumes
    echo "Syncing ${APP} to workspace, please wait..."
    rsync --remove-source-files -rlptDu /${APP}/ /workspace/${APP}/

    echo "${TEMPLATE_VERSION}" > ${DOCKER_IMAGE_VERSION_FILE}
    echo "${VENV_PATH}" > "/workspace/${APP}/venv_path"
}

fix_venvs() {
    # Fix the venv to make it work from /workspace
    echo "Fixing venv..."
    /fix_venv.sh /venv ${VENV_PATH}
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
else
    echo "Existing version is newer than the template version, not syncing!"
fi

if [[ ${DISABLE_AUTOLAUNCH} ]]
then
    echo "Auto launching is disabled so the application will not be started automatically"
    echo "You can launch it manually:"
    echo ""
    echo "   /start_rerender_a_video.sh"
else
    /start_rerender_a_video.sh
fi

echo "All services have been started"
