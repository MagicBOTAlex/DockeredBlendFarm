FROM nvidia/cuda:12.8.1-runtime-ubuntu24.04 AS base
FROM base AS base-amd64

ENV NV_CUDNN_VERSION=9.8.0.87-1
ENV NV_CUDNN_PACKAGE_NAME=libcudnn9-cuda-12
ENV NV_CUDNN_PACKAGE=libcudnn9-cuda-12=${NV_CUDNN_VERSION}

FROM base AS base-arm64

ENV NV_CUDNN_VERSION=9.8.0.87-1
ENV NV_CUDNN_PACKAGE_NAME=libcudnn9-cuda-12
ENV NV_CUDNN_PACKAGE=libcudnn9-cuda-12=${NV_CUDNN_VERSION}

LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME}

RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    wget \
    unzip \
    libicu-dev

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /farm
RUN wget https://github.com/LogicReinc/LogicReinc.BlendFarm/releases/download/v1.1.6/BlendFarm.Server-1.1.6-Linux64.zip
RUN unzip BlendFarm.Server-*.zip -d ./blendfarm-server
RUN rm BlendFarm.Server-*.zip

# CMD ["bash"]
CMD ["/bin/bash", "-c", "exec /farm/blendfarm-server/*/LogicReinc.BlendFarm.Server"]