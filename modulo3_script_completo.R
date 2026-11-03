# ==============================================================================
# MÓDULO 3: MODELOS COMPUTACIONAIS
# Script Consolidado - Aulas 1 a 4
# ------------------------------------------------------------------------------
# Curso: Modelos Matemáticos e Computacionais aplicados à Pesquisa em Saúde
# Campus Virtual Fiocruz
# ==============================================================================
# Este script percorre todos os conceitos do módulo em sequência:
#   Aula 1  - Introdução: modelos computacionais e aprendizado de máquina
#   Aula 2  - Aprendizado supervisionado: classificação (base Iris)
#             Tópico 1: Divisão dos dados
#             Tópico 2: Treinamento (k-NN, Naive Bayes, Árvore de Decisão, SVM)
#             Tópico 3: Avaliação (matriz de confusão, acurácia, precisão,
#                       recall, F1-score)
#             Tópico 4: Predição com novos dados
#   Aula 3  - Regressão (base Boston/MASS)
#             Tópico 1: Avaliação (R², MAE, MSE)
#   Aula 4  - Aprendizado não supervisionado: agrupamento (dados simulados)
#             Tópico 1: k-means, hierárquico, DBSCAN
#             Tópico 2: Métricas de validação (silhueta, índice Rand)
# ==============================================================================


# ------------------------------------------------------------------------------
# CONFIGURAÇÃO INICIAL
# ------------------------------------------------------------------------------

# Pacotes necessários — descomente o install.packages se precisar instalar
# install.packages(c("class", "e1071", "rpart", "rpart.plot", "kernlab",
#                    "caret", "MASS", "cluster", "dbscan", "factoextra",
#                    "dendextend", "fossil"))

library(class)        # k-NN
library(e1071)        # Naive Bayes e SVM
library(rpart)        # Árvore de decisão
library(rpart.plot)   # Visualização da árvore
library(kernlab)      # SVM alternativo (opcional)
library(caret)        # Métricas de classificação
library(MASS)         # Base Boston
library(cluster)      # Silhueta
library(dbscan)       # DBSCAN
library(factoextra)   # Visualização de clusters e cotovelo
library(dendextend)   # Dendrograma
library(fossil)       # Índice Rand


# ==============================================================================
# AULA 1 — INTRODUÇÃO: MODELOS COMPUTACIONAIS E APRENDIZADO DE MÁQUINA
# ==============================================================================
# A modelagem computacional permite criar representações de sistemas complexos
# implementadas e analisadas com auxílio de recursos computacionais.
#
# Aprendizado de máquina: subcampo da IA em que computadores aprendem padrões
# a partir de dados, melhorando o desempenho conforme recebem mais informações.
#
# Dois riscos centrais ao treinar modelos:
#   Underfitting: o modelo não captura os padrões dos dados de treinamento.
#   Overfitting : o modelo se ajusta demais ao treinamento e não generaliza.
#
# Tipos de modelos:
#   Preditivos (aprendizado supervisionado):
#     - Classificação : variável de saída discreta (ex.: espécie da flor íris).
#     - Regressão     : variável de saída contínua (ex.: preço de um imóvel).
#   Descritivos (aprendizado não supervisionado):
#     - Agrupamento   : organiza dados em grupos sem rótulos prévios.
#
# Não há cálculo nesta aula. Os conceitos são aplicados a partir da Aula 2.


# ==============================================================================
# AULA 2 — APRENDIZADO SUPERVISIONADO: CLASSIFICAÇÃO
# ==============================================================================
# Base de dados: Iris (150 amostras, 3 espécies, 4 variáveis numéricas)
# Variável de saída (rótulo): Species (setosa, versicolor, virginica)

# ------------------------------------------------------------------------------
# TÓPICO 1: DIVISÃO DOS DADOS
# ------------------------------------------------------------------------------
# Convenção comum: 70% treinamento e 30% teste.
# A divisão preserva a proporção de classes com set.seed para reprodutibilidade.

data(iris)

set.seed(42)
idx_treino  <- createDataPartition(iris$Species, p = 0.7, list = FALSE)
treino      <- iris[ idx_treino, ]
teste       <- iris[-idx_treino, ]

# Separar variáveis preditoras e rótulo
X_treino <- treino[, 1:4]
y_treino <- treino$Species
X_teste  <- teste[, 1:4]
y_teste  <- teste$Species

# Verificação rápida das proporções
prop.table(table(y_treino))   # proporção de cada classe no treino
prop.table(table(y_teste))    # proporção de cada classe no teste


# ------------------------------------------------------------------------------
# TÓPICO 2: TREINAMENTO DE MODELOS DE CLASSIFICAÇÃO
# ------------------------------------------------------------------------------

# --- k-NN (K-Nearest Neighbors) -----------------------------------------------
# Classifica cada objeto com base nos k vizinhos mais próximos (distância
# euclidiana). k ímpar evita empates; k = 5 é um valor inicial razoável.

pred_knn <- knn(train = X_treino, test = X_teste, cl = y_treino, k = 5)

# --- Naive Bayes ---------------------------------------------------------------
# Classificador probabilístico baseado no teorema de Bayes.
# Assume independência entre as variáveis preditoras.

mod_nb   <- naiveBayes(Species ~ ., data = treino)
pred_nb  <- predict(mod_nb, X_teste)

# --- Árvore de Decisão ---------------------------------------------------------
# Divide o espaço de variáveis sequencialmente, selecionando em cada nó
# a variável que melhor separa as classes.

mod_arvore  <- rpart(Species ~ ., data = treino, method = "class")
pred_arvore <- predict(mod_arvore, X_teste, type = "class")

# Visualização da árvore
rpart.plot(mod_arvore, type = 4, extra = 101,
           main = "Árvore de Decisão — Base Iris")

# --- SVM (Support Vector Machine) ---------------------------------------------
# Busca o hiperplano de margem máxima que separa as classes.
# kernel = "radial" lida com separações não lineares.

mod_svm  <- svm(Species ~ ., data = treino, kernel = "radial")
pred_svm <- predict(mod_svm, X_teste)


# ------------------------------------------------------------------------------
# TÓPICO 3: AVALIAÇÃO DOS MODELOS DE CLASSIFICAÇÃO
# ------------------------------------------------------------------------------
# Métricas calculadas a partir da comparação entre rótulo real e rótulo predito:
#   Acurácia  : proporção de acertos totais (indicada para bases balanceadas).
#   Precisão  : dos classificados como positivos, quantos são reais positivos?
#   Recall    : dos reais positivos, quantos o modelo identificou corretamente?
#   F1-score  : média harmônica entre precisão e recall.
#
# A matriz de confusão organiza TP, TN, FP e FN para cada par real × predito.

avaliar_modelo <- function(real, pred, nome_modelo) {
  cm  <- confusionMatrix(pred, real)
  cat("===", nome_modelo, "===\n")
  print(cm$table)
  cat("Acurácia :", round(cm$overall["Accuracy"], 3), "\n")
  # Para problemas multiclasse, caret calcula métricas por classe; usamos a média
  metricas <- cm$byClass
  cat("Precisão (média):", round(mean(metricas[, "Precision"], na.rm = TRUE), 3), "\n")
  cat("Recall   (média):", round(mean(metricas[, "Recall"],    na.rm = TRUE), 3), "\n")
  cat("F1-score (média):", round(mean(metricas[, "F1"],        na.rm = TRUE), 3), "\n\n")
}

avaliar_modelo(y_teste, pred_knn,    "k-NN")
avaliar_modelo(y_teste, pred_nb,     "Naive Bayes")
avaliar_modelo(y_teste, pred_arvore, "Árvore de Decisão")
avaliar_modelo(y_teste, pred_svm,    "SVM")

# Atenção: valores muito elevados em todas as métricas podem indicar overfitting.
# Em saúde, é fundamental equilibrar precisão e recall conforme o custo de
# falsos positivos e falsos negativos no contexto clínico.


# ------------------------------------------------------------------------------
# TÓPICO 4: PREDIÇÃO COM NOVOS DADOS
# ------------------------------------------------------------------------------
# Um modelo treinado e validado pode classificar amostras inéditas.
# O novo dado precisa ter as mesmas variáveis usadas no treinamento.

nova_amostra <- data.frame(
  Sepal.Length = 5.1,
  Sepal.Width  = 3.5,
  Petal.Length = 1.4,
  Petal.Width  = 0.2
)

# Predição com cada modelo
predict(mod_nb,     nova_amostra)          # Naive Bayes
predict(mod_arvore, nova_amostra, type = "class")  # Árvore de decisão
predict(mod_svm,    nova_amostra)          # SVM

# k-NN requer que o novo dado passe pelo mesmo conjunto de treino
knn(train = X_treino, test = nova_amostra, cl = y_treino, k = 5)


# ==============================================================================
# AULA 3 — REGRESSÃO
# ==============================================================================
# Regressão prevê valores CONTÍNUOS (diferente da classificação, que prevê
# categorias discretas). Amplamente usada em séries temporais e predição
# de variáveis numéricas.
#
# Base de dados: Boston (506 imóveis, 14 variáveis)
#   Variável de saída: medv (valor médio de imóveis — em USD mil)
#   Variáveis preditoras: características socioeconômicas e estruturais

data(Boston)

set.seed(42)
idx_reg    <- createDataPartition(Boston$medv, p = 0.7, list = FALSE)
treino_reg <- Boston[ idx_reg, ]
teste_reg  <- Boston[-idx_reg, ]

# Regressão linear simples: medv ~ lstat (% de população de baixa renda)
mod_rl_simples <- lm(medv ~ lstat, data = treino_reg)
summary(mod_rl_simples)

# Visualização do ajuste
plot(treino_reg$lstat, treino_reg$medv,
     xlab = "% população baixa renda (lstat)",
     ylab = "Valor do imóvel (medv)",
     main = "Regressão Linear Simples — Base Boston",
     pch = 16, col = "steelblue")
abline(mod_rl_simples, col = "tomato", lwd = 2)

# Regressão linear múltipla: todas as variáveis preditoras
mod_rl_mult <- lm(medv ~ ., data = treino_reg)
summary(mod_rl_mult)

# Árvore de regressão (a mesma lógica da árvore de decisão, para saída contínua)
mod_arvore_reg  <- rpart(medv ~ ., data = treino_reg, method = "anova")
rpart.plot(mod_arvore_reg, main = "Árvore de Regressão — Base Boston")


# ------------------------------------------------------------------------------
# TÓPICO 1: AVALIAÇÃO DOS MODELOS DE REGRESSÃO
# ------------------------------------------------------------------------------
# Métricas de regressão medem a distância numérica entre valores preditos e reais.
#   R²  : proporção da variância explicada pelo modelo (0 = nada, 1 = tudo).
#         Valores elevados devem ser analisados com cautela (risco de overfitting).
#   MAE : média das distâncias absolutas entre predito e real (mesma escala da variável).
#   MSE : média dos quadrados dos erros; penaliza mais os erros grandes.

avaliar_regressao <- function(real, pred, nome_modelo) {
  r2  <- cor(real, pred)^2
  mae <- mean(abs(real - pred))
  mse <- mean((real - pred)^2)
  cat("===", nome_modelo, "===\n")
  cat("R²  :", round(r2,  3), "\n")
  cat("MAE :", round(mae, 3), "\n")
  cat("MSE :", round(mse, 3), "\n\n")
}

pred_rl_simples <- predict(mod_rl_simples, teste_reg)
pred_rl_mult    <- predict(mod_rl_mult,    teste_reg)
pred_arvore_reg <- predict(mod_arvore_reg, teste_reg)

avaliar_regressao(teste_reg$medv, pred_rl_simples, "Regressão Linear Simples")
avaliar_regressao(teste_reg$medv, pred_rl_mult,    "Regressão Linear Múltipla")
avaliar_regressao(teste_reg$medv, pred_arvore_reg, "Árvore de Regressão")

# Comparação visual: valores reais vs. preditos (regressão múltipla)
plot(teste_reg$medv, pred_rl_mult,
     xlab = "Valores reais", ylab = "Valores preditos",
     main = "Regressão Linear Múltipla — Real vs. Predito",
     pch = 16, col = "steelblue")
abline(0, 1, col = "tomato", lwd = 2)   # linha de referência: predito = real


# ==============================================================================
# AULA 4 — APRENDIZADO NÃO SUPERVISIONADO: AGRUPAMENTO
# ==============================================================================
# O agrupamento organiza dados em grupos (clusters) sem rótulos prévios.
# Objetivo: objetos de um mesmo cluster são mais semelhantes entre si
# do que em relação aos demais clusters.
#
# Dados simulados: pacientes com doenças crônicas
#   X: número de consultas na atenção básica nos últimos 12 meses
#   Y: número de internações no mesmo período
# Três perfis esperados: bem acompanhados, em risco, estáveis.

set.seed(42)
perfil_1 <- data.frame(consultas = rnorm(50, mean = 10, sd = 1.5),
                        internacoes = rnorm(50, mean = 1,  sd = 0.5))   # bem acompanhados
perfil_2 <- data.frame(consultas = rnorm(50, mean = 2,  sd = 1.0),
                        internacoes = rnorm(50, mean = 6,  sd = 1.0))   # em risco
perfil_3 <- data.frame(consultas = rnorm(50, mean = 3,  sd = 1.0),
                        internacoes = rnorm(50, mean = 1,  sd = 0.5))   # estáveis

pacientes        <- rbind(perfil_1, perfil_2, perfil_3)
rotulos_reais    <- factor(rep(c("Bem acompanhado", "Em risco", "Estável"), each = 50))

# Padronização: necessária para que as escalas das variáveis não distorçam
# a medida de distância usada pelos algoritmos
pacientes_scaled <- scale(pacientes)


# ------------------------------------------------------------------------------
# TÓPICO 1: TREINAMENTO DE MODELOS DE AGRUPAMENTO
# ------------------------------------------------------------------------------

# --- k-means ------------------------------------------------------------------
# Algoritmo particional: divide os dados em k clusters minimizando a
# variabilidade interna (inércia) de cada grupo.
# O número k precisa ser definido previamente.

# Método do cotovelo: auxilia na escolha de k
# Avalia como a inércia total cai à medida que k aumenta;
# o "cotovelo" indica onde o ganho marginal se torna pequeno.
fviz_nbclust(pacientes_scaled, kmeans, method = "wss",
             k.max = 8) +
  labs(title = "Método do Cotovelo — Escolha do k",
       x = "Número de clusters (k)", y = "Inércia total (WSS)")

# Treinamento com k = 3 (sugerido pelo cotovelo)
set.seed(42)
mod_kmeans <- kmeans(pacientes_scaled, centers = 3, nstart = 25)

# Visualização dos clusters
fviz_cluster(mod_kmeans, data = pacientes_scaled,
             geom = "point", ellipse.type = "convex",
             main = "k-means — Perfis de Pacientes (k = 3)")


# --- Agrupamento Hierárquico --------------------------------------------------
# Gera uma sequência de partições aninhadas representadas por um dendrograma.
# Abordagem aglomerativa: começa com cada objeto como cluster individual
# e combina os mais próximos iterativamente.
# Métodos de ligação disponíveis: "single", "complete", "average", "ward.D2"

dist_matrix <- dist(pacientes_scaled, method = "euclidean")
mod_hier    <- hclust(dist_matrix, method = "average")   # average linkage

# Dendrograma com corte em 3 grupos
dend <- as.dendrogram(mod_hier)
dend <- color_branches(dend, k = 3)
plot(dend,
     main  = "Dendrograma — Agrupamento Hierárquico (average linkage)",
     ylab  = "Distância", leaflab = "none")
abline(h = 3.5, col = "red", lty = 2)   # linha de corte ilustrativa

# Definindo os clusters pelo corte
clusters_hier <- cutree(mod_hier, k = 3)


# --- DBSCAN -------------------------------------------------------------------
# Agrupa regiões de alta densidade; não exige definição prévia de k.
# Identifica automaticamente ruídos (objetos que não pertencem a nenhum cluster).
# Parâmetros:
#   eps    : raio de vizinhança para definir regiões densas
#   minPts : número mínimo de objetos para formar um ponto central

mod_dbscan <- dbscan(pacientes_scaled, eps = 0.5, minPts = 4)

# Visualização DBSCAN (cluster 0 = ruído)
fviz_cluster(mod_dbscan, data = pacientes_scaled,
             geom = "point",
             main = "DBSCAN — Clusters e Ruídos (eps=0.5, minPts=4)")

# Objetos classificados como ruído (cluster = 0)
sum(mod_dbscan$cluster == 0)


# ------------------------------------------------------------------------------
# TÓPICO 2: MÉTRICAS DE VALIDAÇÃO PARA AGRUPAMENTO
# ------------------------------------------------------------------------------

# --- Validação interna: Índice de Silhueta ------------------------------------
# Mede coesão (similaridade dentro do cluster) e separação (dissimilaridade
# entre clusters). Valores de -1 a 1:
#   ~  1 : objeto bem alocado no seu cluster
#   ~  0 : objeto na fronteira entre clusters
#   ~ -1 : objeto provavelmente no cluster errado

sil_kmeans <- silhouette(mod_kmeans$cluster, dist_matrix)
sil_hier   <- silhouette(clusters_hier,      dist_matrix)

# Valor médio de silhueta
mean(sil_kmeans[, "sil_width"])   # k-means
mean(sil_hier[,   "sil_width"])   # hierárquico

# Gráfico de silhueta por cluster
fviz_silhouette(sil_kmeans,
                main = "Índice de Silhueta — k-means (k = 3)")
fviz_silhouette(sil_hier,
                main = "Índice de Silhueta — Agrupamento Hierárquico (k = 3)")


# --- Validação externa: Índice Rand -------------------------------------------
# Compara os clusters gerados com rótulos conhecidos (quando disponíveis).
# Mede a proporção de pares de objetos classificados de forma consistente.
# Varia de 0 (nenhuma correspondência) a 1 (correspondência perfeita).
# Disponível aqui porque os dados foram simulados com rótulos conhecidos.

rand_kmeans <- rand.index(as.integer(mod_kmeans$cluster),
                           as.integer(rotulos_reais))
rand_hier   <- rand.index(clusters_hier,
                           as.integer(rotulos_reais))
rand_dbscan <- rand.index(mod_dbscan$cluster,
                           as.integer(rotulos_reais))

round(rand_kmeans, 3)   # índice Rand — k-means
round(rand_hier,   3)   # índice Rand — hierárquico
round(rand_dbscan, 3)   # índice Rand — DBSCAN

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
