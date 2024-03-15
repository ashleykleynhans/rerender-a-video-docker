# Docker image for Rerender A Video: Zero-Shot Text-Guided Video-to-Video Translation

## Installs

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.12
* [Rerender A Video](
  https://github.com/williamyang1991/Rerender_A_Video)
* Torch 2.0.1
* xformers 0.0.22
* Jupyter Lab
* ebsynth
* gmflow_sintel-0c07dcb3.pth
* control_sd15_canny.pth
* control_sd15_hed.pth
* vae-ft-mse-840000-ema-pruned.ckpt
* revAnimated_v122EOL.safetensors
* realisticVisionV51_v51VAE.safetensors
* [runpodctl](https://github.com/runpod/runpodctl)
* [OhMyRunPod](https://github.com/kodxana/OhMyRunPod)
* [RunPod File Uploader](https://github.com/kodxana/RunPod-FilleUploader)
* [croc](https://github.com/schollz/croc)
* [rclone](https://rclone.org/)

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).
You can use my custom [RunPod template](
https://runpod.io/gsc?template=hfucz07h1h&ref=2xxro4sy)
to launch it on RunPod.

## Building the Docker image

> [!NOTE]
> You will need to edit the `docker-bake.hcl` file and update `RELEASE`,
> and `tags`.  You can obviously edit the other values too, but these
> are the most important ones.

```bash
# Clone the repo
git clone https://github.com/ashleykleynhans/rerender-a-video-docker.git

# Log in to Docker Hub
docker login

# Build the image, tag the image, and push the image to Docker Hub
cd rerender-a-video-docker
docker buildx bake -f docker-bake.hcl --push
```

## Running Locally

### Install Nvidia CUDA Driver

- [Linux](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)
- [Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/index.html)

### Start the Docker container

```bash
docker run -d \
  --gpus all \
  -v /workspace \
  -p 3000:3001 \
  -p 8888:8888 \
  -p 2999:2999 \
  -e VENV_PATH="/workspace/venvs/rerender_a_video" \
  ashleykza/rerender-a-video:latest
```

You can obviously substitute the image name and tag with your own.

## Ports

| Connect Port | Internal Port | Description          |
|--------------|---------------|----------------------|
| 3000         | 3001          | Rerender A Video     |
| 8888         | 8888          | Jupyter Lab          |
| 2999         | 2999          | RunPod File Uploader |

## Environment Variables

| Variable             | Description                                           | Default                           |
|----------------------|-------------------------------------------------------|-----------------------------------|
| VENV_PATH            | Set the path for the Python venv for the app          | /workspace/venvs/rerender_a_video |
| JUPYTER_LAB_PASSWORD | Set a password for Jupyter lab                        | not set - no password             |
| DISABLE_AUTOLAUNCH   | Disable Rerender a Video from launching automatically | (not set)                         |

## Logs

Rerender a Video creates a log file, and you can tail the log instead of
killing the service to view the logs.

| Application      | Log file                              |
|------------------|---------------------------------------|
| Rerender a Video | /workspace/logs/rerender_a_video.log  |

For example:

```bash
tail -f /workspace/logs/rerender_a_video.log
```

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/rerender-a-video-docker)
are welcome. Bug fixes and new features are encouraged.

You can contact me and get help with deploying your container
to RunPod on the RunPod Discord Server below,
my username is **ashleyk**.

<a target="_blank" href="https://discord.gg/pJ3P2DbUUq">![Discord Banner 2](https://discordapp.com/api/guilds/912829806415085598/widget.png?style=banner2)</a>

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
