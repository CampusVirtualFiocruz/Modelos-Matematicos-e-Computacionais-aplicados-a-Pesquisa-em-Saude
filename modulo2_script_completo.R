# ==============================================================================
# MÓDULO 2: MODELOS MATEMÁTICOS
# Script Consolidado - Aulas 1 a 6
# ------------------------------------------------------------------------------
# Curso: Modelos Matemáticos e Computacionais aplicados à Pesquisa em Saúde
# Campus Virtual Fiocruz
# ==============================================================================
# Este script percorre todos os conceitos do módulo em sequência:
#   Aula 1  - O que são modelos matemáticos (contextualização)
#   Aula 2  - Os nove passos da modelagem (roteiro aplicado)
#   Aula 3  - Crescimento geométrico: taxa constante e taxa calculada
#   Aula 4  - Dinâmica populacional: natalidade variável + mortalidade constante
#   Aula 5  - Modelos epidemiológicos clássicos (Bernoulli e Ross — conceitual)
#   Aula 6  - Modelo SIR: caso de Canto Feliz (tosse convulsa)
# ==============================================================================


# ------------------------------------------------------------------------------
# CONFIGURAÇÃO INICIAL
# ------------------------------------------------------------------------------


# install.packages(c("ggplot2", "tidyr", "scales"))  # Descomente se precisar instalar
library(ggplot2)
library(tidyr)


# ==============================================================================
# AULA 1 — O QUE SÃO MODELOS MATEMÁTICOS
# ==============================================================================
# Um modelo matemático é a descrição de uma situação por meio de expressões
# matemáticas. Ele permite:
#   1. Descrever processos demográficos e fazer projeções.
#   2. Entender o padrão em sino das curvas epidêmicas.
#   3. Avaliar cenários de intervenção (ex.: vacinação).
#
# Todo modelo é uma simplificação da realidade —
# o que importa é que ele capture as características essenciais.
#
# Não há cálculo nesta aula. Os conceitos são aplicados a partir da Aula 3.


# ==============================================================================
# AULA 2 — OS NOVE PASSOS DA MODELAGEM
# ==============================================================================
# Roteiro aplicado ao problema de Canto Feliz (crescimento geométrico):
#
#   Passo 1 — Pergunta        : Qual a população de Canto Feliz em 2034?
#   Passo 2 — Ingredientes    : P0 = 5000 (2010), a = 5% ao ano.
#   Passo 3 — Diagrama        : P(t) --> [crescimento a] --> P(t+1).
#   Passo 4 — Equação         : P(t+1) = P(t) * (1 + a).
#   Passo 5 — Verificação     : população cresce? Nunca negativa?
#   Passo 6 — Parametrização  : dados do censo + taxa conhecida.
#   Passo 7 — Resultado       : iterar 24 anos ou usar fórmula geral.
#   Passo 8 — Sensibilidade   : o que muda se 'a' for 3% ou 7%?
#   Passo 9 — Publicação      : registrar as premissas adotadas.
#
# O roteiro é aplicado nas seções seguintes.


# ==============================================================================
# AULA 3 — CRESCIMENTO GEOMÉTRICO
# ==============================================================================

# ------------------------------------------------------------------------------
# TÓPICO 1: Crescimento com taxa CONSTANTE — modelo geométrico
# ------------------------------------------------------------------------------
# Problema: Canto Feliz tinha 5.000 pessoas em 2010 e cresce 5% ao ano.
# Qual a estimativa para 2034 (para planejar uma campanha vacinal)?

P0      <- 5000    # População inicial (censo de 2010)
a       <- 0.05    # Taxa de crescimento anual (5%)
ano_ini <- 2010
ano_fim <- 2034

anos <- ano_ini:ano_fim
n    <- 0:(length(anos) - 1)   # Contagem a partir de 0

# Método iterativo: P(t+1) = P(t) * (1 + a)
pop_iter    <- numeric(length(anos))
pop_iter[1] <- P0
for (i in 2:length(anos)) {
  pop_iter[i] <- pop_iter[i - 1] * (1 + a)
}

# Fórmula geral: P(n) = P0 * (1 + a)^n
pop_formula <- P0 * (1 + a)^n

# Os dois métodos produzem o mesmo resultado:
round(pop_iter[length(anos)])    # via iteração
round(pop_formula[length(anos)]) # via fórmula geral

# Ano em que a população dobra: n = log(2) / log(1 + a)
anos_para_dobrar <- log(2) / log(1 + a)
round(ano_ini + anos_para_dobrar)   # ano em que dobra

# Gráfico — crescimento geométrico
df_geo <- data.frame(Ano = anos, Populacao = pop_formula)

ggplot(df_geo, aes(x = Ano, y = Populacao)) +
  geom_line(color = "#2E86AB", linewidth = 1.2) +
  geom_point(color = "#2E86AB", size = 2) +
  geom_hline(yintercept = P0, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2016, y = P0 + 350,
           label = paste("P0 =", P0), color = "gray50") +
  labs(title    = "Modelo de Crescimento Geométrico — Canto Feliz",
       subtitle = paste("Taxa anual:", a * 100, "%"),
       x = "Ano", y = "População",
       caption = "Aula 3, Tópico 1 — Campus Virtual Fiocruz") +
  scale_y_continuous(labels = scales::comma_format(big.mark = ".")) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# ------------------------------------------------------------------------------
# Análise de sensibilidade: diferentes taxas de crescimento
# (Passo 8 do roteiro — exercício proposto na Aula 3)
# ------------------------------------------------------------------------------

taxas    <- c(0.01, 0.03, 0.05, 0.07)
df_taxas <- data.frame()
for (tx in taxas) {
  df_taxas <- rbind(df_taxas, data.frame(
    Ano       = anos,
    Populacao = P0 * (1 + tx)^n,
    Taxa      = paste0(tx * 100, "% ao ano")
  ))
}

ggplot(df_taxas, aes(x = Ano, y = Populacao, color = Taxa)) +
  geom_line(linewidth = 1) +
  labs(title   = "Impacto de Diferentes Taxas de Crescimento",
       x = "Ano", y = "População", color = "Taxa anual",
       caption = "Análise de sensibilidade — Aula 3") +
  scale_y_continuous(labels = scales::comma_format(big.mark = ".")) +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# ------------------------------------------------------------------------------
# TÓPICO 2: Estimando a taxa de crescimento a partir de dados censitários
# ------------------------------------------------------------------------------
# Como o IBGE calculou as taxas históricas usando o modelo geométrico.
# Exemplo: Brasil entre 1940 e 1950.
# P(n) = P0 * (1+a)^n  =>  a = (P(n)/P0)^(1/n) - 1

P_1940 <- 41e6
P_1950 <- 52e6
n_anos <- 10

a_historica <- (P_1950 / P_1940)^(1 / n_anos) - 1
round(a_historica * 100, 1)   # taxa de crescimento 1940-1950 em %


# ==============================================================================
# AULA 4 — DINÂMICA POPULACIONAL
# ==============================================================================
# Modelo com natalidade VARIÁVEL (regressão linear) e mortalidade constante.
# Problema: projeção da população brasileira de 2000 a 2030.

# Dados IBGE 2000-2015 (taxa bruta por 1000 habitantes)
dados_ibge <- data.frame(
  Ano         = 2000:2015,
  Natalidade  = c(20.86, 20.28, 19.73, 19.19, 18.66, 18.15, 17.65, 17.18,
                  16.72, 16.29, 15.88, 15.50, 15.13, 14.79, 14.47, 14.16),
  Mortalidade = c(6.67,  6.56,  6.44,  6.35,  6.27,  6.20,  6.14,  6.10,
                  6.07,  6.05,  6.03,  6.02,  6.03,  6.04,  6.06,  6.08)
)
dados_ibge$n <- dados_ibge$Ano - 2000   # n = anos desde 2000

# Regressão linear para a natalidade: b(n) = intercepto + inclinacao * n
mod_natal  <- lm(Natalidade ~ n, data = dados_ibge)
intercepto <- coef(mod_natal)[1]
inclinacao <- coef(mod_natal)[2]

dados_ibge$Natal_Modelo <- predict(mod_natal)

# Gráfico do ajuste da natalidade
ggplot(dados_ibge, aes(x = Ano)) +
  geom_point(aes(y = Natalidade), color = "#E74C3C", size = 3) +
  geom_line(aes(y = Natal_Modelo), color = "#3498DB", linewidth = 1) +
  labs(title   = "Ajuste Linear da Taxa de Natalidade (Brasil)",
       subtitle = paste0("b(n) = ", round(intercepto, 1),
                         " + (", round(inclinacao, 2), ") × n"),
       x = "Ano", y = "Taxa de natalidade (por 1000 hab.)",
       caption = "Pontos: IBGE | Linha: modelo ajustado — Aula 4") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# Função de natalidade por pessoa por ano
natal_func <- function(n) (intercepto + inclinacao * n) / 1000

# Mortalidade constante (média do período)
m <- 6.1 / 1000

# Projeção 2000–2030: P(n+1) = P(n) * (1 + b(n) - m)
P0_br  <- 170e6   # População brasileira em 2000
anos_n <- 0:30
pop_br <- numeric(length(anos_n))
pop_br[1] <- P0_br

for (i in 2:length(anos_n)) {
  n_atual   <- anos_n[i - 1]
  b_atual   <- natal_func(n_atual)
  pop_br[i] <- pop_br[i - 1] * (1 + b_atual - m)
}

df_brasil <- data.frame(
  Ano     = 2000 + anos_n,
  Pop_Mod = pop_br / 1e6
)

# Dados reais do IBGE para comparação
dados_reais <- data.frame(
  Ano      = c(2000, 2010, 2020, 2022),
  Pop_Real = c(170, 191, 213, 215)
)

# Gráfico: modelo vs. dados reais
ggplot() +
  geom_line(data = df_brasil,
            aes(x = Ano, y = Pop_Mod, color = "Modelo"),
            linewidth = 1.2) +
  geom_point(data = dados_reais,
             aes(x = Ano, y = Pop_Real, color = "Dados Reais"),
             size = 4) +
  scale_color_manual(values = c("Modelo" = "#3498DB", "Dados Reais" = "#E74C3C")) +
  labs(title   = "Projeção Populacional do Brasil — Dinâmica Populacional",
       subtitle = "Natalidade variável + mortalidade constante",
       x = "Ano", y = "População (milhões)", color = "",
       caption = "Aula 4 — Campus Virtual Fiocruz") +
  theme_minimal() +
  theme(plot.title      = element_text(face = "bold"),
        legend.position = "bottom")

# Taxa de crescimento implícita ao longo do tempo
df_brasil$Taxa_Cresc <- c(NA, diff(pop_br) / head(pop_br, -1) * 100)

ggplot(df_brasil[-1, ], aes(x = Ano, y = Taxa_Cresc)) +
  geom_line(color = "#9B59B6", linewidth = 1.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  labs(title   = "Taxa de Crescimento Populacional Implícita",
       subtitle = "A queda da natalidade reduz progressivamente o crescimento",
       x = "Ano", y = "Taxa de crescimento (%)",
       caption = "Linha vermelha = crescimento zero — Aula 4") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))


# ==============================================================================
# AULA 5 — MODELOS EPIDEMIOLÓGICOS CLÁSSICOS
# ==============================================================================
# Esta aula é predominantemente conceitual. Dois marcos históricos:
#
#   Bernoulli (1766): primeiro modelo epidemiológico formal.
#     - Dividiu a população entre Suscetíveis e Imunizados.
#     - Estimou que a inoculação contra varíola aumentaria
#       a expectativa de vida em ~3 anos.
#
#   Ross (1898): modelou a transmissão da malária.
#     - Inovação: modelou tanto a população humana quanto a de mosquitos.
#     - Pergunta central: é possível eliminar a malária
#       reduzindo a população de mosquitos?
#
# Ambos usaram a mesma estratégia:
#   dividir a população em COMPARTIMENTOS e modelar os FLUXOS entre eles
#   — base do modelo SIR construído na Aula 6.

# Demonstração: dois compartimentos (Suscetíveis → Imunizados)
# no espírito do modelo de Bernoulli (ex.: campanha de vacinação)

N_demo     <- 1000   # população total
S_demo     <- 990    # suscetíveis iniciais
Imune_demo <- 10     # imunizados iniciais
lambda     <- 0.05   # proporção de suscetíveis vacinada por dia
dias_demo  <- 60

S_vec <- I_vec <- numeric(dias_demo)
S_vec[1] <- S_demo
I_vec[1] <- Imune_demo

for (t in 1:(dias_demo - 1)) {
  novos_imunes  <- lambda * S_vec[t]
  S_vec[t + 1]  <- S_vec[t] - novos_imunes
  I_vec[t + 1]  <- I_vec[t] + novos_imunes
}

df_bern <- data.frame(
  Dia         = 1:dias_demo,
  Suscetiveis = S_vec,
  Imunizados  = I_vec
) |>
  pivot_longer(cols = c(Suscetiveis, Imunizados),
               names_to = "Grupo", values_to = "Pessoas")

ggplot(df_bern, aes(x = Dia, y = Pessoas, color = Grupo)) +
  geom_line(linewidth = 1.2) +
  scale_color_manual(values = c("Suscetiveis" = "#3498DB",
                                "Imunizados"  = "#2ECC71")) +
  labs(title   = "Modelo de Dois Compartimentos",
       subtitle = "Suscetíveis perdem o status ao ser imunizados (ex.: vacinação)",
       x = "Dias", y = "Número de pessoas", color = "",
       caption = "Aula 5 — Campus Virtual Fiocruz") +
  theme_minimal() +
  theme(plot.title      = element_text(face = "bold"),
        legend.position = "bottom")


# ==============================================================================
# AULA 6 — MODELO SIR: CASO CANTO FELIZ (TOSSE CONVULSA)
# ==============================================================================

# ------------------------------------------------------------------------------
# PARÂMETROS DA DOENÇA (do relatório epidemiológico)
# ------------------------------------------------------------------------------

p    <- 0.2    # Probabilidade de transmissão por contato (20%)
c_tx <- 2      # Taxa de contato média (2 contatos/dia)
d    <- 4      # Duração da fase infecciosa (4 dias)

N    <- 16125  # População total de Canto Feliz
S0   <- 16124  # Suscetíveis no dia 0
I0   <- 1      # Caso índice
R0_i <- 0      # Recuperados no dia 0

beta  <- p * c_tx   # Taxa de transmissão efetiva (β = p × c)
gamma <- 1 / d      # Taxa de recuperação (γ = 1/d)

# Número básico de reprodução: R0 > 1 significa que a epidemia vai crescer
R0_calc <- beta * S0 / (N * gamma)

# ------------------------------------------------------------------------------
# FUNÇÃO DO MODELO SIR (tempo discreto)
# Equações:
#   S(t+1) = S(t) - β × (I(t)/N) × S(t)
#   I(t+1) = I(t) + β × (I(t)/N) × S(t) - γ × I(t)
#   R(t+1) = R(t) + γ × I(t)
# ------------------------------------------------------------------------------

modelo_sir <- function(dias, S0, I0, R0_init, N, beta, gamma) {
  S <- numeric(dias); I <- numeric(dias); R <- numeric(dias)
  S[1] <- S0; I[1] <- I0; R[1] <- R0_init
  for (t in 1:(dias - 1)) {
    forca  <- beta * I[t] / N * S[t]
    recup  <- gamma * I[t]
    S[t+1] <- S[t] - forca
    I[t+1] <- I[t] + forca - recup
    R[t+1] <- R[t] + recup
  }
  data.frame(Dia = 1:dias, Suscetiveis = S, Infectados = I, Recuperados = R)
}

# ------------------------------------------------------------------------------
# SIMULAÇÃO — sem intervenção
# ------------------------------------------------------------------------------

dias_sim  <- 150
resultado <- modelo_sir(dias_sim, S0, I0, R0_i, N, beta, gamma)

dia_pico     <- which.max(resultado$Infectados)
infec_pico   <- max(resultado$Infectados)
total_infect <- max(resultado$Recuperados)

# Gráfico SIR completo
res_longo <- pivot_longer(resultado,
                          cols      = c(Suscetiveis, Infectados, Recuperados),
                          names_to  = "Compartimento",
                          values_to = "Populacao")
res_longo$Compartimento <- factor(res_longo$Compartimento,
                                  levels = c("Suscetiveis", "Infectados", "Recuperados"))

cores_sir <- c("Suscetiveis" = "#3498DB",
               "Infectados"  = "#E74C3C",
               "Recuperados" = "#2ECC71")

ggplot(res_longo, aes(x = Dia, y = Populacao, color = Compartimento)) +
  geom_line(linewidth = 1.2) +
  geom_vline(xintercept = dia_pico, linetype = "dashed", color = "gray50") +
  annotate("text", x = dia_pico + 4, y = N * 0.88,
           label = paste("Pico: dia", dia_pico), hjust = 0, color = "gray40") +
  scale_color_manual(values = cores_sir) +
  scale_y_continuous(labels = scales::comma_format(big.mark = ".")) +
  labs(title   = "Modelo SIR — Tosse Convulsa em Canto Feliz",
       subtitle = paste("R0 =", round(R0_calc, 2), "| Pico no dia", dia_pico),
       x = "Dias desde o caso índice", y = "Número de pessoas",
       color = "Compartimento",
       caption = "Aula 6 — Campus Virtual Fiocruz") +
  theme_minimal() +
  theme(plot.title      = element_text(face = "bold", size = 14),
        legend.position = "bottom")

# Curva epidêmica isolada (apenas infectados)
ggplot(resultado, aes(x = Dia, y = Infectados)) +
  geom_area(fill = "#E74C3C", alpha = 0.3) +
  geom_line(color = "#E74C3C", linewidth = 1.2) +
  geom_vline(xintercept = dia_pico, linetype = "dashed") +
  labs(title   = "Curva Epidêmica — Casos de Tosse Convulsa",
       subtitle = "Número de pessoas infectadas ao longo do tempo",
       x = "Dias", y = "Infectados",
       caption = "Aula 6 — Campus Virtual Fiocruz") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold"))

# ------------------------------------------------------------------------------
# IMUNIDADE DE REBANHO
# Fórmula: limiar = 1 - 1/R0
# ------------------------------------------------------------------------------

limiar_rebanho <- 1 - 1 / R0_calc
# round(limiar_rebanho * 100, 1)  # percentual necessário
# round(limiar_rebanho * N)       # número de pessoas imunes necessárias

# ------------------------------------------------------------------------------
# ANÁLISE DE INTERVENÇÕES — redução da taxa de transmissão
# Ex.: uso de máscaras, distanciamento social
# ------------------------------------------------------------------------------

reducoes <- c(0, 0.20, 0.40, 0.60)
df_int   <- data.frame()

for (red in reducoes) {
  beta_red <- beta * (1 - red)
  res_int  <- modelo_sir(dias_sim, S0, I0, R0_i, N, beta_red, gamma)
  df_int   <- rbind(df_int, data.frame(
    Dia        = res_int$Dia,
    Infectados = res_int$Infectados,
    Reducao    = paste0(red * 100, "% redução")
  ))
}

ggplot(df_int, aes(x = Dia, y = Infectados, color = Reducao)) +
  geom_line(linewidth = 1) +
  scale_color_brewer(palette = "Set1") +
  labs(title   = "Impacto de Intervenções na Curva Epidêmica",
       subtitle = "Redução da taxa de transmissão (máscaras, distanciamento...)",
       x = "Dias", y = "Infectados",
       color = "Nível de intervenção",
       caption = "Aula 6 — Campus Virtual Fiocruz") +
  theme_minimal() +
  theme(plot.title      = element_text(face = "bold"),
        legend.position = "bottom")

# ------------------------------------------------------------------------------
# SIMULAÇÃO DE VACINAÇÃO PRÉVIA
# ------------------------------------------------------------------------------
# Cobertura vacinal prévia reduz S0; vacinados entram como recuperados/imunes.

cobertura <- 0.50   # 50% da população vacinada antes da epidemia
S0_vac    <- S0 * (1 - cobertura)
R0_vac    <- S0 * cobertura

res_vac <- modelo_sir(dias_sim, S0_vac, I0, R0_vac, N, beta, gamma)

# Comparação do pico com e sem vacinação:
round(infec_pico)               # sem vacina
round(max(res_vac$Infectados))  # com 50% vacinados

# ==============================================================================
# FIM DO SCRIPT
# ==============================================================================
