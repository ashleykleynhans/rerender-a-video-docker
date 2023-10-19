# Stage 1: Base
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as base

ARG RERENDER_A_VIDEO_COMMIT=a1620540b417954ba40e44037dcdee86aa9b81f6

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

# Create workspace working directory
WORKDIR /

# Install Ubuntu packages
RUN apt update && \
    apt -y upgrade && \
    apt install -y --no-install-recommends \
        software-properties-common \
        build-essential \
        python3.10-venv \
        python3-pip \
        python3-tk \
        python3-dev \
        nginx \
        bash \
        dos2unix \
        git \
        git-lfs \
        ncdu \
        net-tools \
        openssh-server \
        libglib2.0-0 \
        libsm6 \
        libgl1 \
        libxrender1 \
        libxext6 \
        ffmpeg \
        wget \
        curl \
        psmisc \
        rsync \
        vim \
        zip \
        unzip \
        htop \
        pkg-config \
        libcairo2-dev \
        libgoogle-perftools4 \
        libtcmalloc-minimal4 \
        apt-transport-https \
        ca-certificates && \
    update-ca-certificates && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Stage 2: Install Rerender a Video and python modules
FROM base as setup

# Create and use the Python venv
RUN python3 -m venv /venv

# Clone the git repo of Rerender a Video and set version
WORKDIR /
RUN git clone https://github.com/williamyang1991/Rerender_A_Video.git --recursive /Rerender_A_Video && \
    cd /Rerender_A_Video && \
    git checkout ${RERENDER_A_VIDEO_COMMIT}

# Install the dependencies for Rerender a Video
WORKDIR /Rerender_A_Video
RUN source /venv/bin/activate && \
    pip3 install --no-cache-dir torch==2.0.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip3 install --no-cache-dir xformers==0.0.22 && \
    pip3 install wheel && \
    pip3 install -r requirements.txt && \
    python3 install.py && \
    chmod +x /workspace/Rerender_A_Video/deps/ebsynth/bin/ebsynth && \
    pip3 cache purge && \
    deactivate

# Copy the Stable Diffusion Model config
COPY sd_model_cfg.py .

# Download revAnimated model
RUN wget -O models/revAnimated_v122EOL.safetensors https://civitai.com/api/download/models/46846

# Download Realistic Vision model
RUN wget -O models/realisticVisionV51_v51VAE.safetensors "https://civitai.com/api/download/models/130072?type=Model&format=SafeTensor&size=pruned&fp=fp16"

# Install Jupyter
RUN pip3 install -U --no-cache-dir jupyterlab \
        jupyterlab_widgets \
        ipykernel \
        ipywidgets \
        gdown

# Install runpodctl
RUN wget https://github.com/runpod/runpodctl/releases/download/v1.10.0/runpodctl-linux-amd -O runpodctl && \
    chmod a+x runpodctl && \
    mv runpodctl /usr/local/bin

# NGINX Proxy
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/502.html /usr/share/nginx/html/502.html

# Copy the scripts
WORKDIR /
COPY --chmod=755 scripts/* ./

# Start the container
SHELL ["/bin/bash", "--login", "-c"]
CMD [ "/start.sh" ]