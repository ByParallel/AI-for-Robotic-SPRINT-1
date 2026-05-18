# ─────────────────────────────────────────────────────────────
#  Sprint 1 — Monitoramento Preditivo de Motores Elétricos
#  Execução reprodutível via Docker
# ─────────────────────────────────────────────────────────────

FROM python:3.10-slim

# Metadados
LABEL maintainer="ByParallel"
LABEL description="Sprint 1 — Automação RPA: Coleta, Transformação e Persistência de Dados de Motores"

# Diretório de trabalho dentro do container
WORKDIR /app

# Copiar arquivos do projeto
COPY Sprint1_Motores_Eletricos.ipynb .
COPY legado_mtr001.csv ./data/

# Instalar dependências
RUN pip install --no-cache-dir \
    tabulate==0.9.0 \
    nbconvert==7.16.4 \
    jupyter-client==8.6.2

# Criar diretórios de saída
RUN mkdir -p motor_rpa/logs motor_rpa/data

# Converter o notebook em script Python e executar
RUN jupyter nbconvert --to script Sprint1_Motores_Eletricos.ipynb \
    --output sprint1_script

# Ponto de entrada: executa o pipeline completo
CMD ["python", "sprint1_script.py"]
