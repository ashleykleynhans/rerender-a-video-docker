# Docker image for Rerender A Video: Zero-Shot Text-Guided Video-to-Video Translation

## Installs

* Ubuntu 22.04 LTS
* CUDA 11.8
* Python 3.10.12
* [Rerender A Video](
  https://github.com/williamyang1991/Rerender_A_Video)
* Torch 2.0.1
* xformers 0.0.22
* ebsynth
* gmflow_sintel-0c07dcb3.pth
* control_sd15_canny.pth
* control_sd15_hed.pth
* vae-ft-mse-840000-ema-pruned.ckpt
* revAnimated_v122EOL.safetensors
* realisticVisionV51_v51VAE.safetensors
* [runpodctl](https://github.com/runpod/runpodctl)
* [croc](https://github.com/schollz/croc)
* [rclone](https://rclone.org/)

## Available on RunPod

This image is designed to work on [RunPod](https://runpod.io?ref=2xxro4sy).
You can use my custom [RunPod template](
https://runpod.io/gsc?template=hfucz07h1h&ref=2xxro4sy)
to launch it on RunPod.

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
  -e JUPYTER_PASSWORD=Jup1t3R! \
  ashleykza/rerender-a-video:latest
```

You can obviously substitute the image name and tag with your own.

## Community and Contributing

Pull requests and issues on [GitHub](https://github.com/ashleykleynhans/rerender-a-video-docker)
are welcome. Bug fixes and new features are encouraged.

You can contact me and get help with deploying your container
to RunPod on the RunPod Discord Server below,
my username is **ashleyk**.

<a target="_blank" href="https://discord.gg/pJ3P2DbUUq">![Discord Banner 2](https://discordapp.com/api/guilds/912829806415085598/widget.png?style=banner2)</a>

## Appreciate my work?

<a href="https://www.buymeacoffee.com/ashleyk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
