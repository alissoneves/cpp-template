FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    libstdc++6 \
    libfmt-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# O Jenkins vai passar o nome da pasta aqui
ARG PROJECT_NAME
# O caminho onde o CMake colocou o binário
ARG BUILD_DIR=build/Release

# Copia o binário usando o nome dinâmico definido no CMake
COPY ${BUILD_DIR}/${PROJECT_NAME} /app/executable

RUN chmod +x /app/executable

CMD ["/bin/bash", "-c", "/app/executable && sleep infinity"]