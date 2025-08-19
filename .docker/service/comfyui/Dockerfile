# Multi-stage build para otimizar tamanho da imagem
FROM python:3.11-bookworm as builder

# Instalar dependências de build
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar diretório de trabalho
WORKDIR /app

# Clonar ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .

# Instalar extensões personalizadas
RUN git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager

# Instalar dependências Python em ambiente virtual
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Atualizar pip primeiro
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Instalar PyTorch com suporte CUDA (otimizado para RTX 2060 Super)
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu129

# Instalar xformers para otimização de memória
RUN pip install --no-cache-dir xformers

# Instalar dependências base do ComfyUI
RUN pip install --no-cache-dir -r requirements.txt || echo "requirements.txt não encontrado, continuando..."

# Instalar dependências do ComfyUI Manager
RUN pip install --no-cache-dir -r custom_nodes/ComfyUI-Manager/requirements.txt || echo "Manager requirements não encontrado"


# Instalar dependências essenciais primeiro
RUN pip install --no-cache-dir \
    pillow \
    numpy \
    requests \
    psutil \
    tqdm

# Instalar dependências para modelos avançados
RUN pip install --no-cache-dir \
    accelerate \
    diffusers \
    transformers \
    sentencepiece \
    protobuf \
    safetensors \
    huggingface_hub \
    einops \
    omegaconf \
    ftfy \
    regex

# Instalar dependências extras
RUN pip install --no-cache-dir \
    opencv-python-headless \
    GitPython \
    scipy \
    matplotlib \
    imageio


# Stage final - imagem mais leve
FROM python:3.11-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# Instalar apenas dependências de runtime necessárias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libgl1-mesa-glx \
        libgl1-mesa-dev \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender-dev \
        libgomp1 \
        libgstreamer1.0-0 \
        libgstreamer-plugins-base1.0-0 \
        git \
        curl \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


# Criar usuário não-root para segurança
RUN groupadd -r comfyui && useradd -r -g comfyui -u 1000 -m comfyui

# Copiar ambiente virtual do stage builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copiar aplicação
COPY --from=builder /app /app
WORKDIR /app

# Criar diretórios necessários
RUN mkdir -p models/checkpoints models/vae models/clip models/unet \
        models/loras models/controlnet models/upscale_models \
        input output custom_nodes temp && \
    chown -R comfyui:comfyui /app && \
    chmod -R 755 /app

# Configurar volumes
# VOLUME ["/app/models", "/app/input", "/app/output", "/app/custom_nodes"]

# Expor porta
EXPOSE 8188

# Configurar usuário não-root
USER comfyui

# Configuração de saúde da aplicação
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8188/ || exit 1

# Comando padrão com configurações otimizadas para RTX 2060 Super
CMD ["python", "main.py", \
    "--listen", "0.0.0.0", \ 
    "--port", "8188", \
    "--dont-print-server", \
    "--lowvram", \
    "--cpu-vae", \
    "--preview-method", "auto"]

    # "--fp16-vae", \
    # "--force-fp16", \