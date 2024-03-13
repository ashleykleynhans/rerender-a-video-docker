variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "rerender-a-video"
}

variable "RELEASE" {
    default = "1.0.6"
}

variable "CU_VERSION" {
    default = "118"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${USERNAME}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.2.0+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.24+cu${CU_VERSION}"
        RERENDER_A_VIDEO_COMMIT="d32b1d6b6c1305ddd06e66868c5dcf4fb7aa048c"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/rerender_a_video"
    }
}
