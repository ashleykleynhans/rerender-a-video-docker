#!/usr/bin/env bash
set -e  # Exit the script if any statement returns a non-true return value

# ---------------------------------------------------------------------------- #
#                          Function Definitions                                #
# ---------------------------------------------------------------------------- #

start_nginx() {
    echo "Starting Nginx service..."
    service nginx start
}

execute_script() {
    local script_path=$1
    local script_msg=$2
    if [[ -f ${script_path} ]]; then
        echo "${script_msg}"
        bash ${script_path}
    fi
}

setup_ssh() {
    if [[ $PUBLIC_KEY ]]; then
        echo "Setting up SSH..."
        mkdir -p ~/.ssh
        echo -e "${PUBLIC_KEY}\n" >> ~/.ssh/authorized_keys
        chmod 700 -R ~/.ssh

        if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
            ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ''
        fi

        if [ ! -f /etc/ssh/ssh_host_dsa_key ]; then
            ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ''
        fi

        if [ ! -f /etc/ssh/ssh_host_ecdsa_key ]; then
            ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ''
        fi

        if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
            ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ''
        fi

        service ssh start

        echo "SSH host keys:"
        cat /etc/ssh/*.pub
    fi
}

export_env_vars() {
    echo "Exporting environment variables..."
    printenv | grep -E '^RUNPOD_|^PATH=|^_=' | awk -F = '{ print "export " $1 "=\"" $2 "\"" }' >> /etc/rp_environment
    echo 'source /etc/rp_environment' >> ~/.bashrc
}

start_jupyter() {
    if [[ $JUPYTER_PASSWORD ]]; then
        echo "Starting Jupyter Lab..."
        mkdir -p /workspace && \
        cd / && \
        nohup jupyter lab --allow-root \
          --no-browser \
          --port=8888 \
          --ip=* \
          --FileContentsManager.delete_to_trash=False \
          --ContentsManager.allow_hidden=True \
          --ServerApp.terminado_settings='{"shell_command":["/bin/bash"]}' \
          --ServerApp.token=${JUPYTER_PASSWORD} \
          --ServerApp.allow_origin=* \
          --ServerApp.preferred_dir=/workspace &> /workspace/logs/jupyter.log &
        echo "Jupyter Lab started"
    fi
}

configure_filezilla() {
    # Only proceed if there is a public IP
    if [[ ! -z "${RUNPOD_PUBLIC_IP}" ]]; then
        # Server information
        hostname="${RUNPOD_PUBLIC_IP}"
        port="${RUNPOD_TCP_PORT_22}"

        # Generate a random password
        password=$(openssl rand -base64 12)

        # Set the password for the root user
        echo "root:${password}" | chpasswd

        # Update SSH configuration
        ssh_config="/etc/ssh/sshd_config"

        # Enable PasswordAuthentication
        grep -q "^PasswordAuthentication" ${ssh_config} && \
          sed -i "s/^PasswordAuthentication.*/PasswordAuthentication yes/" ${ssh_config} || \
          echo "PasswordAuthentication yes" >> ${ssh_config}

        # Enable PermitRootLogin
        grep -q "^PermitRootLogin" ${ssh_config} && \
          sed -i "s/^PermitRootLogin.*/PermitRootLogin yes/" ${ssh_config} || \
          echo "PermitRootLogin yes" >> ${ssh_config}

        # Restart the SSH service
        service ssh restart || systemctl restart sshd

        # Create FileZilla XML configuration for SFTP
        filezilla_config_file="/workspace/filezilla_sftp_config.xml"
        cat > ${filezilla_config_file} << EOF
<?xml version="1.0" encoding="UTF-8"?>
<FileZilla3 version="3.66.1" platform="linux">
    <Servers>
        <Server>
            <Host>${hostname}</Host>
            <Port>${port}</Port>
            <Protocol>1</Protocol> <!-- 1 for SFTP -->
            <Type>0</Type>
            <User>root</User>
            <Pass encoding="base64">$(echo -n ${password} | base64)</Pass>
            <Logontype>1</Logontype> <!-- 1 for Normal logon type -->
            <EncodingType>Auto</EncodingType>
            <BypassProxy>0</BypassProxy>
            <Name>Generated Server</Name>
            <RemoteDir>/workspace</RemoteDir>
            <SyncBrowsing>0</SyncBrowsing>
            <DirectoryComparison>0</DirectoryComparison>
            <!-- Additional settings can be added here -->
        </Server>
    </Servers>
</FileZilla3>
EOF
        echo "FileZilla SFTP configuration file created at: ${filezilla_config_file}"
    else
        echo "RUNPOD_PUBLIC_IP is not set. Skipping FileZilla configuration."
    fi
}

# ---------------------------------------------------------------------------- #
#                               Main Program                                   #
# ---------------------------------------------------------------------------- #

echo "Container Started, configuration in progress..."
start_nginx
execute_script "/pre_start.sh" "Running pre-start script..."
setup_ssh
configure_filezilla
start_jupyter
export_env_vars
execute_script "/post_start.sh" "Running post-start script..."
echo "Container is READY!"
sleep infinity
