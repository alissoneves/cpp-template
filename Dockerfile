FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    libfmt-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Recebe o nome do binário vindo do Jenkins
ARG PROJECT_NAME
ARG BUILD_DIR=build/Release

# Copia o binário correto dinamicamente
COPY ${BUILD_DIR}/${PROJECT_NAME} /app/executable

# Permissão de execução
RUN chmod +x /app/executable

# Executa
CMD ["/bin/bash", "-c", "/app/executable && sleep infinity"]