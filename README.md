# AI for Robotic — Sprint 1
## Automação de Coleta, Registro e Atualização de Dados de Ativos
### Monitoramento Preditivo de Motores Elétricos Industriais

---

##  Sobre o Projeto

Sistema de automação RPA desenvolvido na **Sprint 1** para coleta, normalização, persistência e rastreabilidade de dados operacionais de motores elétricos industriais. A solução ingere dados de sensores IoT simulados e arquivos CSV legados, aplica um pipeline de transformação com validação física, persiste tudo em banco relacional e mantém histórico completo de auditoria.

---

##  Arquitetura

```
┌──────────────────────────────────────────────────────────────┐
│                    CAMADA DE FONTES                           │
│  [Sensores IoT]   [Arquivos CSV]   [Entrada Manual]          │
└────────────┬──────────────┬───────────────┬─────────────────┘
             │              │               │
             ▼              ▼               ▼
┌──────────────────────────────────────────────────────────────┐
│              CAMADA DE INGESTÃO                               │
│  - Coleta unificada de múltiplas fontes                      │
│  - Geração de hash SHA-256 para idempotência                 │
│  - Normalização de unidades e cabeçalhos                     │
└─────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│           CAMADA DE TRANSFORMAÇÃO                             │
│  - Coerce de tipos (str → float)                             │
│  - Validação de limites físicos por ativo                    │
│  - Detecção de anomalias operacionais                        │
│  - Separação válidos / rejeitados                            │
└─────────────────────────────┬────────────────────────────────┘
                              │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│  tabela ativos │  │ tabela leituras  │  │tabela historico  │
│  (cadastro)    │  │ (séries temporais│  │(auditoria)       │
└────────────────┘  └──────────────────┘  └──────────────────┘
                              │                ▼
                              │        ┌──────────────────┐
                              │        │  log_execucoes   │
                              ▼        └──────────────────┘
                    ┌──────────────────────┐
                    │  SCHEDULER (batch)   │
                    │  Ciclos periódicos   │
                    │  Retry / Idempot.    │
                    └──────────────────────┘
```

---

## 📁 Estrutura do Repositório

```
AI-for-Robotic-SPRINT-1/
├── Sprint1_Motores_Eletricos.ipynb   ← Código principal (automação completa)
├── documento_tecnico_sprint1.md      ← Documento técnico com arquitetura e justificativas
├── motores.db                        ← Banco SQLite populado com histórico de ativos
├── legado_mtr001.csv                 ← Fonte de dados CSV (sistema legado simulado)
├── execucao_20260429.log             ← Log de execução das automações
├── 2026-04-29 19-55-12.mp4           ← Demonstração funcional em vídeo
├── Dockerfile                        ← Container para execução reprodutível
├── data/
│   └── .gitkeep
└── logs/
    └── .gitkeep
```

---

##  Como Executar

### Opção 1 — Google Colab (recomendado para avaliação)

1. Acesse [colab.research.google.com](https://colab.research.google.com)
2. Faça upload do arquivo `Sprint1_Motores_Eletricos.ipynb`
3. Execute as células em ordem (`Ctrl+F9` para rodar tudo)
4. Ao final, o dashboard de evidências será exibido e o arquivo `evidencias_sprint1.zip` estará disponível para download

### Opção 2 — Docker (execução local reprodutível)

```bash
# Clone o repositório
git clone https://github.com/ByParallel/AI-for-Robotic-SPRINT-1.git
cd AI-for-Robotic-SPRINT-1

# Build e execução via Docker
docker build -t sprint1-motores .
docker run --rm -v $(pwd)/output:/app/motor_rpa sprint1-motores
```

Os arquivos gerados (`motores.db`, `logs/`, `evidencias_sprint1.zip`) estarão na pasta `output/`.

### Opção 3 — Python local

```bash
# Requisitos: Python 3.10+
pip install tabulate

# Executar via Jupyter
jupyter notebook Sprint1_Motores_Eletricos.ipynb
```

---

##  Tecnologias Utilizadas

| Tecnologia | Papel |
|---|---|
| **Python 3.10+** | Linguagem base das automações |
| **SQLite 3** | Banco de dados relacional (ACID, WAL mode) |
| **hashlib (SHA-256)** | Idempotência — evita duplicação de registros |
| **logging (stdlib)** | Rastreabilidade de execuções |
| **csv / io (stdlib)** | Leitura de fontes legadas |
| **dataclasses** | Regras de validação tipadas |
| **tabulate** | Dashboard formatado de evidências |
| **Docker** | Execução reprodutível em container |

---

##  Requisitos Funcionais — Atendimento

| # | Requisito | Status |
|---|---|---|
| RF1 | Ingerir dados de fonte simulada ou real | ✅ IoT simulado + CSV legado |
| RF2 | Transformação e normalização dos dados | ✅ `PipelineTransformacao` com regras físicas |
| RF3 | Registro em base estruturada | ✅ SQLite com schema relacional (4 tabelas) |
| RF4 | Rotina automatizada de atualização | ✅ `executar_ciclo_batch()` com 3 ciclos |
| RF5 | Histórico de atualizações | ✅ `historico_atualizacoes` + `log_execucoes` |
| RF6 | Rastreabilidade via logs | ✅ logging stdlib + tabela `log_execucoes` |

---

## Banco de Dados — Evidências

Ao executar o notebook, o banco `motores.db` conterá:

- **3 ativos** cadastrados (MTR-001 WEG 75kW, MTR-002 WEG 45kW, MTR-003 Siemens 22kW)
- **~6.048 leituras** (3 motores × leituras de 7 dias em intervalos de 5 min)
- **~240–300 anomalias** detectadas (~4% de taxa simulada)
- **8+ entradas** no log de execuções das automações
- **Histórico de auditoria** completo de todos os INSERT/UPDATE

---

##  Escalabilidade Futura

| Eixo | Situação Sprint 1 | Evolução Planejada |
|---|---|---|
| Banco | SQLite (arquivo) | PostgreSQL + TimescaleDB |
| Ingestão | Simulador Python | MQTT broker (Mosquitto) + paho-mqtt |
| Orquestração | Função Python | Apache Airflow DAG / Prefect |
| Volume | Milhares de registros | Particionamento por data em `leituras` |
| Containerização | Docker (simples) | Docker Compose (app + db + broker) |

---

##  Equipe

Projeto desenvolvido pela equipe **ByParallel** — Sprint 1 de Automação com IA para Robótica.
