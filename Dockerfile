FROM ubuntu:24.04

RUN apt-get update && apt-get install -y libstdc++6 libfmt-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia tudo da pasta de build (garanta que o executável está lá)
COPY build/Release/cpp-template /app/cpp-template

# Dá permissão explícita
RUN chmod +x /app/cpp-template

# Comando direto sem variáveis complexas para testar
CMD ["/app/cpp-template"]