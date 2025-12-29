# Visão Geral do Projeto

Aplicação web para **gestão de custos e receitas de anfitriões** de plataformas como Airbnb e Booking, com foco em simplicidade, clareza financeira e conformidade com LGPD.

O sistema **não realiza integrações com APIs externas** das plataformas de hospedagem. Todos os dados são inseridos manualmente pelo usuário, reduzindo riscos legais, complexidade técnica e custo operacional.

Stack principal:

* Frontend: **Nuxt 4**
* Backend / Auth / DB: **Supabase**
* Banco de dados: **PostgreSQL (Supabase)**

---

# Objetivo do Produto

Fornecer ao anfitrião uma visão clara e confiável de:

* Receita
* Despesa
* Lucro líquido

Por imóvel e por período, com **mínimo esforço operacional**.

---

# Público-Alvo

Anfitriões de curta temporada que administram:

* 1 a 3 imóveis (foco principal)
* Gestão individual ou familiar
* Pouca ou nenhuma estrutura administrativa

Usuários com mais de 5–6 imóveis não são o público central do MVP.

---

# Modelo de Planos

A precificação é baseada **exclusivamente na quantidade de imóveis**.

## Planos

| Plano     | Limite de imóveis | Observação                       |
| --------- | ----------------- | -------------------------------- |
| Essencial | 1                 | Controle completo para um imóvel |
| Anfitrião | Até 3             | **Plano foco do produto**        |
| Pro       | Até 6             | Recursos de análise avançada     |

Princípio fundamental:

> Todos os planos oferecem controle financeiro completo. O que muda é apenas escala e sofisticação.

---

# Princípios de Produto

* Simplicidade acima de tudo
* Sem bloqueios artificiais de recursos essenciais
* Upgrade apenas quando o usuário tenta crescer
* Transparência total dos dados
* LGPD by design (sem dados de hóspedes)

---

# Funcionalidades (Features)

## 1. Autenticação e Usuário

* Cadastro e login via Supabase Auth
* Criação automática de perfil do usuário
* Associação do usuário a um plano

---

## 2. Gestão de Imóveis

* Cadastro de imóveis
* Nome/apelido do imóvel
* Ativação/desativação (soft delete)
* Validação de limite de imóveis conforme plano

Regra:

> O único bloqueio por plano ocorre na tentativa de adicionar imóveis acima do limite.

---

## 3. Gestão de Receitas

Cadastro manual de receitas:

* Data de recebimento
* Imóvel
* Plataforma (Airbnb, Booking, Direto)
* Valor
* Observação opcional

Características:

* Sem dados de hóspedes
* Sem número de reserva

---

## 4. Gestão de Despesas

Cadastro manual de despesas:

* Data de pagamento
* Imóvel
* Categoria da despesa
* Tipo: fixa ou variável
* Valor
* Recorrente (sim/não)
* Observação opcional

---

## 5. Categorias de Despesa

* Categorias personalizadas por usuário
* Exemplos:

	* Limpeza
	* Manutenção
	* Condomínio
	* IPTU
	* Internet
	* Energia

---

## 6. Dashboards e Relatórios (Plano Anfitrião)

### 6.1 Dashboard Mensal Consolidado

* Receita total
* Despesa total
* Lucro líquido
* Margem (%)

Filtro por:

* Mês / Ano
* Imóvel (opcional)

---

### 6.2 Resultado por Imóvel

Tabela com:

* Receita
* Despesa
* Lucro

---

### 6.3 Receita por Plataforma

* Distribuição de receita por canal

---

### 6.4 Top Despesas

* Ranking de categorias por valor

---

### 6.5 Histórico Mensal

* Receita, despesa e lucro por mês

---

### 6.6 Relatório Anual

* Consolidado anual
* Lucro por imóvel
* Despesas por categoria
* Exportação em CSV/Excel

---

## 7. Exportação de Dados

* Exportação CSV / Excel disponível em todos os planos
* Exportação por período customizado no plano Anfitrião

---

# Estrutura de Dados (Resumo)

Tabelas principais:

* usuarios
* planos
* imoveis
* receitas
* despesas
* categorias_despesa
* plataformas

Todas as tabelas financeiras possuem:

* usuario_id
* RLS baseada em auth.uid()

---

# Regras de Segurança (RLS)

* Usuário acessa apenas seus próprios dados
* Tabelas globais (planos, plataformas): somente leitura
* Validação de limite de imóveis feita por função RPC

---

# Arquitetura Frontend (Nuxt 4)

Sugestão de módulos:

* /auth
* /onboarding
* /dashboard
* /imoveis
* /receitas
* /despesas
* /relatorios
* /configuracoes

Características desejadas:

* Mobile-first
* Formulários rápidos
* Pouca navegação profunda

---

# Onboarding do Usuário

Fluxo inicial:

1. Cadastro
2. Escolha do plano
3. Cadastro do primeiro imóvel
4. Cadastro da primeira receita ou despesa
5. Visualização do primeiro dashboard

Objetivo:

> Fazer o usuário enxergar valor em menos de 5 minutos.

---

# Limites Deliberados do MVP

Fora do escopo inicial:

* Integrações com Airbnb/Booking
* Dados de hóspedes
* Automação bancária
* Multiusuário
* Contabilidade integrada

---

# Evoluções Futuras (Roadmap)

* Relatórios em PDF
* Projeções financeiras
* Comparativo ano contra ano
* Alertas de custos recorrentes
* Múltiplos usuários por conta

---

# Métricas de Sucesso

* Tempo para primeiro lançamento
* Retenção mensal
* Taxa de upgrade por limite de imóveis
* Uso recorrente dos dashboards

---

# Posicionamento Final

Este produto não é um PMS.

Ele é uma **ferramenta de clareza financeira**, simples, honesta e focada em pequenos anfitriões.
