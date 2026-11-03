# Modelos Matemáticos e Computacionais aplicados à Pesquisa em Saúde

**Campus Virtual Fiocruz**

Este repositório contém os scripts em R utilizados como material prático do curso. Cada script acompanha um módulo específico e pode ser executado de forma independente.

---

## Estrutura do repositório

```
.
├── modulo1_script_completo.R   # Grandes bases de dados e ELT com sparklyr
├── modulo2_script_completo.R   # Modelos matemáticos populacionais e SIR
├── modulo3_script_completo.R   # Modelos computacionais e aprendizado de máquina
└── README.md
```

> O Módulo 4 é de consolidação conceitual e não possui script associado.

---

## Módulo 1 — Introdução a Grandes Bases de Dados

**Script:** `modulo1_script_completo.R`

Aborda o processamento de grandes volumes de dados em saúde usando Apache Spark e o formato Parquet, com aplicação prática de um fluxo ELT completo sobre a base SRAG do OpenDataSUS.

| Aula | Conteúdo |
|------|----------|
| Aula 1 | Big Data e os 5 Vs — contextualização |
| Aula 2 | Apache Spark e Apache Parquet — demonstração de leitura parcial e compressão |
| Aula 3 | ELT com sparklyr: extração do OpenDataSUS, carregamento em Parquet, transformações (select, filter, group_by, mutate) |

**Base de dados:** SRAG 2021 — OpenDataSUS (download automático pelo script)

**Pacotes necessários:**
```r
install.packages("sparklyr")
install.packages("dplyr")
install.packages("arrow")
sparklyr::spark_install(version = "3.5")
```

---

## Módulo 2 — Modelos Matemáticos

**Script:** `modulo2_script_completo.R`

Constrói modelos populacionais e epidemiológicos passo a passo, aplicando o roteiro de modelagem em nove passos do módulo. Todos os exemplos usam o município fictício de Canto Feliz e dados do IBGE — nenhum download externo é necessário.

| Aula | Conteúdo |
|------|----------|
| Aula 1 | O que são modelos matemáticos — contextualização |
| Aula 2 | Os nove passos da modelagem — roteiro aplicado |
| Aula 3 | Crescimento geométrico: taxa constante, fórmula geral, análise de sensibilidade |
| Aula 4 | Dinâmica populacional: natalidade variável (regressão linear) + mortalidade constante |
| Aula 5 | Modelos epidemiológicos clássicos: Bernoulli e Ross — demonstração de dois compartimentos |
| Aula 6 | Modelo SIR: caso Canto Feliz (tosse convulsa), intervenções, imunidade de rebanho, vacinação |

**Pacotes necessários:**
```r
install.packages(c("ggplot2", "tidyr", "scales"))
```

---

## Módulo 3 — Modelos Computacionais

**Script:** `modulo3_script_completo.R`

Implementa o fluxo completo de aprendizado de máquina supervisionado e não supervisionado, cobrindo classificação, regressão e agrupamento com bases de dados clássicas.

| Aula | Conteúdo |
|------|----------|
| Aula 1 | Introdução ao aprendizado de máquina — contextualização |
| Aula 2 | Classificação (base Iris): divisão treino/teste, k-NN, Naive Bayes, árvore de decisão, SVM, matriz de confusão, acurácia, precisão, recall, F1-score, predição com novos dados |
| Aula 3 | Regressão (base Boston/MASS): regressão linear simples e múltipla, árvore de regressão, R², MAE, MSE |
| Aula 4 | Agrupamento (dados simulados): k-means com método do cotovelo, hierárquico com dendrograma, DBSCAN, índice de silhueta, índice Rand |

**Bases de dados:** `iris` (incluída no R), `Boston` (pacote `MASS`) e dados simulados gerados pelo script

**Pacotes necessários:**
```r
install.packages(c("class", "e1071", "rpart", "rpart.plot", "kernlab",
                   "caret", "MASS", "cluster", "dbscan", "factoextra",
                   "dendextend", "fossil"))
```

---

## Como usar

1. Clone ou baixe este repositório.
2. Abra o script do módulo desejado no RStudio.
3. Execute o bloco de instalação de pacotes no início do script (comentado — descomente na primeira vez).
4. Execute o script de cima para baixo. Cada seção corresponde a uma aula e pode ser executada de forma independente, desde que a configuração inicial tenha sido feita.

> **Módulo 1:** requer instalação adicional do Apache Spark via `sparklyr::spark_install()`. O download da base SRAG (~1 GB) ocorre automaticamente durante a execução da Aula 3.

---

## Requisitos

- R versão 4.1 ou superior
- RStudio (recomendado)
- Conexão com a internet (Módulo 1: download da base SRAG; instalação de pacotes)
- Java 8, 11 ou 17 instalado (necessário para o sparklyr/Spark do Módulo 1)

---

## Referências das bases de dados

- **SRAG 2021:** OpenDataSUS / DATASUS — https://opendatasus.saude.gov.br
- **Iris:** Fisher, R.A. (1936). *The use of multiple measurements in taxonomic problems.*
- **Boston:** Harrison, D. & Rubinfeld, D.L. (1978). Disponível via pacote `MASS` do R.
- **Canto Feliz:** município fictício criado para fins didáticos pelo autor do curso.

---

*Campus Virtual Fiocruz — Curso de Modelos Matemáticos e Computacionais aplicados à Pesquisa em Saúde*
