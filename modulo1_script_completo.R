# ==============================================================================
# MÓDULO 1: INTRODUÇÃO A GRANDES BASES DE DADOS
# Script Consolidado - Aulas 1 a 3
# ------------------------------------------------------------------------------
# Curso: Modelos Matemáticos e Computacionais aplicados à Pesquisa em Saúde
# Campus Virtual Fiocruz
# ==============================================================================
# Este script percorre todos os conceitos do módulo em sequência:
#   Aula 1  - Grandes bases de dados: Big Data e os 5 Vs (contextualização)
#   Aula 2  - Processamento paralelo: Apache Spark e Apache Parquet
#   Aula 3  - ELT com sparklyr aplicado à base SRAG 2021 / OpenDataSUS
#             Tópico 1: Extração (Extract)
#             Tópico 2: Carregamento (Load)
#             Tópico 3: Transformação (Transform)
# ==============================================================================


# ------------------------------------------------------------------------------
# CONFIGURAÇÃO INICIAL
# ------------------------------------------------------------------------------

# Definir pasta de trabalho (ajuste para o seu caminho)
setwd("C:/Users/seu_usuario/modulo1")

# Instalar pacotes (executar apenas uma vez)
#install.packages("sparklyr")
# install.packages("dplyr")
# install.packages("arrow")

# Instalar o Apache Spark (executar apenas uma vez após instalar sparklyr)
#sparklyr::spark_install(version = "3.5")

#verificar spark instalado 
#spark_installed_versions()


# Carregar pacotes
library(dplyr)
library(sparklyr)
library(arrow)

# Criar pasta de dados (não sobrescreve se já existir)
dir.create("dados", showWarnings = FALSE)


# ==============================================================================
# AULA 1 — GRANDES BASES DE DADOS
# ==============================================================================
# Big Data: grandes volumes de dados gerados diariamente no mundo.
# Segundo o relatório Data Age 2025 (IDC), cada pessoa gerava ~1,3 GB/dia em
# 2015, com previsão de ~5,3 GB/dia em 2025.
#
# Os 5 Vs do Big Data:
#   Volume    : imensa quantidade de dados gerados e processados.
#   Velocidade: rapidez com que os dados são transportados e processados.
#   Variedade : diversidade de tipos — estruturados (tabelas SQL) e
#               não estruturados (texto, imagem, vídeo, áudio).
#   Veracidade: precisão e qualidade dos dados.
#   Valor     : utilidade que os dados trazem quando analisados adequadamente.
#
# No SUS, trabalhamos diariamente com Big Data:
#   SINAN, SIM, SINASC, SIH-SUS, e-SUS AB, SI-PNI, OpenDataSUS.
#   Cada sistema tem seu próprio formato, variáveis e frequência de atualização.
#
# Não há cálculo nesta aula. Os conceitos são aplicados a partir da Aula 3.


# ==============================================================================
# AULA 2 — PROCESSAMENTO PARALELO: APACHE SPARK E APACHE PARQUET
# ==============================================================================
# Processamento paralelo: divide tarefas em partes menores executadas
# simultaneamente em múltiplos núcleos (cores) ou máquinas.
# Essencial para Big Data — ferramentas tradicionais usam apenas 1 núcleo.
#
# Apache Spark: framework open-source que distribui o processamento entre
# múltiplos processadores/computadores automaticamente.
# Oferece APIs em Java, Scala, Python e R (via sparklyr).
#
# Apache Parquet: formato de arquivo colunar, open-source.
#   - Leitura parcial: acessa apenas as colunas necessárias (não lê tudo).
#   - Compressão eficiente em bases grandes e colunares; o ganho em relação ao
#     CSV depende dos dados.
#   - Preserva tipos de dados completamente (ao contrário do CSV).
#   - Não possui limite intrínseco de linhas; o limite de ~1 milhão de linhas
#     é do Excel, não do CSV.
#   - Requer ferramenta com suporte (R, Python, Spark) — não editável manualmente.

# Demonstração da vantagem do Parquet frente ao CSV
# (usando a base iris como dado de exemplo — não requer download)
write.csv(iris, "dados/iris_demo.csv", row.names = FALSE)
write_parquet(iris, "dados/iris_demo.parquet")

# Comparação de tamanho (em bytes): em bases pequenas, como iris, o Parquet
# pode não ser menor que o CSV.
print(paste("Tamanho CSV:    ", file.size("dados/iris_demo.csv"), "bytes"))
print(paste("Tamanho Parquet:", file.size("dados/iris_demo.parquet"), "bytes"))
print(paste("Redução:        ", round((1 - file.size("dados/iris_demo.parquet") /
                                           file.size("dados/iris_demo.csv")) * 100), "%"))

# Leitura parcial com Parquet: lê apenas as colunas de interesse
# Em grandes bases, isso poupa memória e tempo significativamente
iris_parcial <- read_parquet("dados/iris_demo.parquet",
                             col_select = c("Sepal.Length", "Species"))
head(iris_parcial)


# ==============================================================================
# AULA 3 — ELT: EXTRACT, LOAD, TRANSFORM
# ==============================================================================
# ELT é o processo que os profissionais do SUS já fazem — muitas vezes
# manualmente no Excel — ao trabalhar com sistemas como SINAN, SIM, SINASC:
#   Baixar dados de diferentes sistemas       → Extract
#   Carregar/Salvar em formato adequado para análise   → Load
#   Limpar, padronizar, criar variáveis(organizar os dados para responder uma pergunta)       → Transform
#
# Com sparklyr, esse fluxo pode ser automatizado e escalado para
# milhões de registros.
#
# Base utilizada: SRAG 2021 — Síndrome Respiratória Aguda Grave
# Fonte: OpenDataSUS (DATASUS)

# Iniciar conexão com o Spark (modo local: usa os núcleos da própria máquina)

# Criar uma configuração personalizada para o Spark
# Aqui vamos informar ao Spark quanta memória ele pode usar
# e como ele deve dividir algumas tarefas internamente
conf <- spark_config()

# Define a quantidade de memória disponível para o "motor principal" do Spark
# Neste exemplo, estamos permitindo o uso de até 3 GB de memória para o driver.
conf$spark.driver.memory <- "3G"

# Define a quantidade de memória disponível para executar as tarefas do Spark
# No modo local, esse valor ajuda o Spark a trabalhar com arquivos maiores
conf$spark.executor.memory <- "3G"

# Define em quantas partes o Spark vai dividir algumas operações internas,
# como agrupamentos, junções e ordenações

conf$spark.sql.shuffle.partitions <- 4

#spark_disconnect_all() # limpar a conexao do spark se for preciso reiniciar o processo

sc <- spark_connect(master = "local[*]", config = conf)

# ------------------------------------------------------------------------------
# TÓPICO 1: EXTRAÇÃO (Extract)
# ------------------------------------------------------------------------------
# Extração: obter os dados brutos de onde estão armazenados.
#
# Fontes comuns no SUS e seus formatos típicos:
#   SINAN  (Vigilância)    : DBF, CSV — notificações de dengue, COVID, tuberculose.
#   SIM    (Mortalidade)   : DBC, CSV — óbitos por causas específicas.
#   SINASC (Nascidos vivos): DBC, CSV — indicadores de saúde materna.
#   SIH-SUS (Internações)  : DBC, CSV — custos hospitalares, procedimentos.
#   e-SUS AB (Aten. Básica): CSV, API — atendimentos nas UBS.
#   SI-PNI (Imunização)    : CSV      — cobertura vacinal.
#   OpenDataSUS (Portal)   : CSV, Parquet — bases consolidadas nacionais.
#
# Desafios comuns:
#   - Arquivos grandes que travam o Excel.
#   - Formatos antigos (DBF, DBC) que precisam de conversão.
#   - Dados espalhados em múltiplos arquivos (um por mês/ano).
#   - Atualizações frequentes que exigem re-download.

# Definir URL e destino do arquivo
url_csv     <- "https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/SRAG/2021/INFLUD21-01-05-2023.csv"
destino_csv <- "dados/SRAG_2021.csv"

# Baixar arquivo (pode demorar alguns minutos)
download.file(url = url_csv, destfile = destino_csv, method = "auto")

# Carregar CSV no Spark (delimiter = ";" pois é padrão do DataSUS)
df <- spark_read_csv(sc, path = destino_csv, delimiter = ";")  # esse arquivo é muito maior que a base de dados iris!

# ------------------------------------------------------------------------------
# TÓPICO 2: CARREGAMENTO (Load)
# ------------------------------------------------------------------------------
# Boas práticas:
#   - Manter arquivo original intacto (nunca sobrescrever a fonte).
#   - Nomear arquivos com data de processamento.
#   - Organizar em pastas por etapa: brutos/, processados/, analises/.

# Salvar os dados em um diretório Parquet (o Spark cria arquivos de partes)
# Se o diretório de destino já existir, esta chamada falha.
# Para substituí-lo em uma nova execução, acrescente mode = "overwrite" aos argumentos.
spark_write_parquet(df, path = "dados/SRAG_2021.parquet")

# Para ler uma pasta com vários arquivos Parquet, informe o caminho da pasta:
# exemplo <- spark_read_parquet(sc, name = "exemplo", path = "dados/pasta_parquet")

# Ler o diretório Parquet gerado
df_parquet <- spark_read_parquet(sc, name = "dados_parquet", path = "dados/SRAG_2021.parquet")

# ------------------------------------------------------------------------------
# TÓPICO 3: TRANSFORMAÇÃO (Transform)
# ------------------------------------------------------------------------------
# Operações mais comuns no SUS:
#   1. Limpeza       : duplicatas, valores faltantes (999, "IGN"), erros de digitação.
#   2. Padronização  : códigos de município, CID-10, formatos de data.
#   3. Vars derivadas: faixa etária, região de saúde, tempo de internação.
#   4. Filtros       : período, área geográfica, condição clínica.
#   5. Agregações    : contagem por município, taxas por 100.000 habitantes.

# Visualizar primeiras linhas
df_parquet %>% head()

# Verificar dimensões
sdf_nrow(df_parquet)
length(colnames(df_parquet))

# Listar todas as colunas
colnames(df_parquet)

# SELECT - Selecionar colunas de interesse
# EVOLUCAO: 1=Cura, 2=Óbito, 3=Óbito outras causas, 9=Ignorado
# TP_IDADE : 1=Dias, 2=Meses, 3=Anos
df_new <- df_parquet %>%
  select(DT_NOTIFIC, SG_UF, EVOLUCAO, NU_IDADE_N, TP_IDADE)

df_new %>% glimpse()

# FILTER - Filtrar registros
df_cura <- df_new %>%
  filter(EVOLUCAO == 1 & TP_IDADE == 3)

df_cura %>% glimpse()

# Tratar valores nulos na variável UF
df_cura %>% filter(is.na(SG_UF))

df_cura <- df_cura %>%
  filter(!is.na(SG_UF))

# GROUP_BY + SUMMARISE - Agregar dados por UF
df_agregado <- df_cura %>%
  group_by(SG_UF) %>%
  summarise(
    soma_idade  = sum(NU_IDADE_N),
    media_idade = mean(NU_IDADE_N),
    idade_min   = min(NU_IDADE_N),
    idade_max   = max(NU_IDADE_N),
    total_casos = n()
  )

df_agregado



# MUTATE - Criar novas variáveis
df_cura <- df_cura %>%
  mutate(
    FAIXA_ETARIA = if_else(NU_IDADE_N >= 18, "Maior Idade", "Menor Idade")
  )

df_cura %>% glimpse()

# ARRANGE - Ordenar dados
df_cura <- df_cura %>%
  arrange(SG_UF, NU_IDADE_N)

df_cura

# Salvar a base processada em um diretório Parquet
# Se o diretório de destino já existir, esta chamada falha.
# Para substituí-lo em uma nova execução, acrescente mode = "overwrite" aos argumentos.
spark_write_parquet(df_cura, path = "dados/SRAG_2021_processado")


# ------------------------------------------------------------------------------
# FINALIZAÇÃO
# ------------------------------------------------------------------------------

# Encerrar conexão com o Spark
spark_disconnect(sc)


# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
