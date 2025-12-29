# FEATURES — Escopo Funcional

Documento de referência das funcionalidades do produto, alinhado aos princípios de simplicidade, clareza financeira e LGPD by design. Este arquivo detalha o escopo do MVP e extensões por plano.

---

## Regras de Plano e Limites

Planos por quantidade de imóveis:

| Plano     | Limite de imóveis | Observação                       |
| --------- | ----------------- | -------------------------------- |
| Essencial | 1                 | Controle completo para um imóvel |
| Anfitrião | Até 3             | Plano foco do produto            |
| Pro       | Até 6             | Recursos de análise avançada     |

**Princípio fundamental**: todos os planos oferecem controle financeiro completo (receitas, despesas, categorias). O único bloqueio ocorre ao tentar cadastrar imóveis acima do limite do plano.

**Plano padrão inicial**: Essencial (1 imóvel) — upgrade pode ser feito a qualquer momento.

---

## 1) Autenticação e Usuário

### Funcionalidades:

* **Cadastro** via Supabase Auth (email + senha)
* **Login** com email e senha
* **Criação automática de perfil** após primeiro cadastro
* **Associação automática** ao plano Essencial
* **Recuperação de senha** (password reset via email)
* **Logout** com limpeza de sessão

### Validações:

* Email: formato válido, único no sistema
* Senha: mínimo 8 caracteres (recomendado pelo Supabase)
* Todos os campos obrigatórios

### Critérios de aceite (MVP):

* Usuário consegue se cadastrar, logar e sair sem erros
* Perfil inicial gerado automaticamente com plano Essencial
* RLS garante que usuário só acessa seus próprios dados
* Mensagens de erro claras para credenciais inválidas
* Link de recuperação de senha enviado por email funciona corretamente

---

## 2) Gestão de Imóveis

### Funcionalidades:

* **Criar** novo imóvel
* **Editar** nome e dados do imóvel
* **Desativar** imóvel (soft delete — não exclui dados)
* **Reativar** imóvel desativado
* **Listagem** com filtro por status (ativo/inativo/todos)
* **Validação de limite** conforme plano (via RPC no Supabase)

### Campos:

* **Nome/Apelido** (obrigatório, max 100 caracteres)
* **Status** (ativo/inativo — padrão: ativo)
* **Data de criação** (automático)
* **Usuário** (automático via `auth.uid()`)

### Validações:

* Nome não pode ser vazio
* Não permite criar imóvel acima do limite do plano
* Validação no backend via função RPC antes de insert

### Critérios de aceite (MVP):

* Usuário cria o primeiro imóvel durante o onboarding
* Ao exceder o limite do plano, sistema bloqueia o cadastro e exibe modal com sugestão de upgrade
* Desativação não remove dados associados (receitas/despesas permanecem visíveis)
* Listagem mostra claramente status de cada imóvel

---

## 3) Gestão de Receitas

### Funcionalidades:

* **Criar** receita manual
* **Editar** receita existente
* **Excluir** receita (exclusão permanente)
* **Listagem** paginada com ordenação por data
* **Filtros**: período, imóvel, plataforma
* **Sumários**: total de receita no período selecionado

### Campos:

* **Data de recebimento** (obrigatório, tipo date)
* **Imóvel** (obrigatório, select dos imóveis ativos do usuário)
* **Plataforma** (obrigatório, select: Airbnb / Booking / Direto / Outro)
* **Valor** (obrigatório, decimal, min: 0.01, formato monetário R$)
* **Observação** (opcional, max 500 caracteres)
* **Data de criação** (automático)

### Validações:

* Data não pode ser futura
* Valor deve ser positivo e maior que zero
* Imóvel deve pertencer ao usuário e estar ativo
* Confirmação antes de excluir

### Restrições (LGPD by design):

* **Sem dados de hóspedes** (nome, email, telefone, documento)
* **Sem número de reserva** ou códigos identificadores externos

### Critérios de aceite (MVP):

* Formulário funciona perfeitamente em mobile (inputs otimizados)
* Totais por período refletem filtros aplicados em tempo real
* Listagem carrega com performance aceitável (<2s)
* Exclusão solicita confirmação

---

## 4) Gestão de Despesas

### Funcionalidades:

* **Criar** despesa manual
* **Editar** despesa existente
* **Excluir** despesa (exclusão permanente)
* **Listagem** paginada com ordenação por data
* **Filtros**: período, imóvel, categoria, tipo (fixa/variável)
* **Sumários**: total de despesa no período selecionado

### Campos:

* **Data de pagamento** (obrigatório, tipo date)
* **Imóvel** (obrigatório, select dos imóveis ativos do usuário)
* **Categoria** (obrigatório, select das categorias ativas do usuário)
* **Tipo** (obrigatório, radio: Fixa / Variável)
* **Valor** (obrigatório, decimal, min: 0.01, formato monetário R$)
* **Recorrente** (opcional, checkbox: sim/não — padrão: não)
* **Observação** (opcional, max 500 caracteres)
* **Data de criação** (automático)

### Validações:

* Data não pode ser futura
* Valor deve ser positivo e maior que zero
* Categoria deve estar ativa e pertencer ao usuário
* Imóvel deve pertencer ao usuário e estar ativo
* Confirmação antes de excluir

### Critérios de aceite (MVP):

* Formulário funciona perfeitamente em mobile (inputs otimizados)
* Totais por período refletem filtros aplicados em tempo real
* Listagem carrega com performance aceitável (<2s)
* Exclusão solicita confirmação

**Nota MVP**: o campo "recorrente" é apenas **indicador visual** no MVP (sem automação de lançamentos futuros).

---

## 5) Categorias de Despesa

### Funcionalidades:

* **Categorias personalizadas** por usuário (isolamento total)
* **Criação automática** de categorias sugeridas no primeiro acesso
* **Criar** nova categoria
* **Renomear** categoria existente
* **Desativar** categoria (soft delete — não apaga histórico)
* **Reativar** categoria desativada
* **Listagem** com filtro por status (ativa/inativa/todas)

### Categorias Iniciais Sugeridas:

* Limpeza
* Manutenção
* Condomínio
* IPTU
* Internet
* Energia
* Água
* Gás
* Móveis e Equipamentos
* Taxas e Impostos

### Campos:

* **Nome** (obrigatório, max 50 caracteres, único por usuário)
* **Status** (ativo/inativo — padrão: ativo)
* **Data de criação** (automático)

### Validações:

* Nome não pode ser vazio ou duplicado (case-insensitive)
* Categoria em uso não pode ser excluída (apenas desativada)
* Confirmação antes de desativar categoria com histórico

### Critérios de aceite (MVP):

* Usuário cria/renomeia/desativa categorias sem erros
* Listagem mostra claramente categorias ativas e inativas
* Despesas vinculadas a categorias desativadas permanecem visíveis no histórico
* Categorias desativadas não aparecem em novos lançamentos

---

## 6) Dashboards e Relatórios

**Disponibilidade**: Dashboards básicos disponíveis em **todos os planos**. Análises avançadas e relatórios completos no **plano Pro**.

### 6.1 Dashboard Mensal Consolidado (Todos os planos):

* Métricas: Receita total, Despesa total, Lucro líquido, Margem (%)
* Filtros: mês/ano e imóvel (opcional)

### 6.2 Resultado por Imóvel (Todos os planos):

* Tabela: Receita, Despesa, Lucro por imóvel no período
* Ordenação por lucro (maior para menor)

### 6.3 Receita por Plataforma (Plano Anfitrião e Pro):

* Distribuição de receita entre canais (Airbnb, Booking, Direto, Outro)
* Visualização: gráfico de pizza ou barras
* Percentual de cada canal

### 6.4 Top Despesas (Plano Anfitrião e Pro):

* Ranking das 10 maiores categorias de despesa por valor no período
* Visualização: gráfico de barras horizontais

### 6.5 Histórico Mensal (Plano Pro):

* Séries temporais de Receita, Despesa e Lucro por mês
* Visualização: gráfico de linha
* Período: últimos 12 meses ou customizado

### 6.6 Relatório Anual (Plano Pro):

* Consolidado anual completo
* Lucro por imóvel (tabela e gráfico)
* Despesas por categoria (tabela e gráfico)
* Comparativo mensal
* Exportação CSV/Excel/PDF

Critérios de aceite (MVP):

* Resumo mensal apresenta valores corretos de acordo com filtros
* Visualizações carregam em mobile com performance aceitável

---

## 7) Exportação de Dados

### Funcionalidades:

* **Exportação CSV/Excel** de receitas, despesas e relatórios
* **Plano Essencial**: período pré-definido (mês atual)
* **Plano Anfitrião/Pro**: período customizado (range de datas)
* **Download direto** do arquivo gerado

### Formatos:

* **CSV**: compatível com Excel, Google Sheets, LibreOffice
* **Excel** (.xlsx): formatação preservada, múltiplas abas
* **PDF** (somente Plano Pro): relatórios formatados para impressão

### Colunas Exportadas:

**Receitas**:
* Data, Imóvel, Plataforma, Valor, Observação

**Despesas**:
* Data, Imóvel, Categoria, Tipo, Valor, Recorrente, Observação

**Relatório Consolidado**:
* Período, Imóvel, Receita Total, Despesa Total, Lucro Líquido, Margem %

### Validações e Segurança:

* Exportação respeita filtros aplicados pelo usuário
* RLS garante que apenas dados do usuário logado são exportados
* Limite de 10.000 registros por exportação (MVP)
* Arquivo gerado com nome padronizado: `lucrohost_[tipo]_[data].csv`

### Critérios de aceite (MVP):

* Arquivo CSV é gerado corretamente e abre sem erros
* Dados exportados correspondem exatamente aos filtros aplicados
* Exportação funciona em mobile (download otimizado)
* Usuário recebe feedback visual durante geração (loading)

---

## 8) Onboarding do Usuário

### Objetivo:

**"Valor em menos de 5 minutos"** — fazer o usuário visualizar seus primeiros dados financeiros rapidamente.

### Fluxo Detalhado:

**Passo 1: Cadastro**
* Formulário simples: email + senha
* Confirmação por email (opcional no MVP)
* Criação automática de perfil e plano Essencial

**Passo 2: Bem-vindo**
* Tela de boas-vindas explicando o produto
* Informação sobre plano atual (Essencial - 1 imóvel)
* CTA: "Começar agora"

**Passo 3: Primeiro Imóvel**
* Modal ou página dedicada
* Campo: nome do imóvel (ex: "Apartamento Centro")
* Mensagem: "Você pode adicionar mais imóveis depois"
* CTA: "Continuar"

**Passo 4: Primeira Receita ou Despesa**
* Escolha: "O que deseja adicionar primeiro?"
* Opções: Receita / Despesa / Pular por enquanto
* Formulário simplificado (apenas campos essenciais)
* Feedback positivo ao salvar

**Passo 5: Dashboard Inicial**
* Redirecionamento automático para dashboard
* Exibição dos primeiros dados (mesmo que parciais)
* Tour opcional: "Conheça as funcionalidades" (tooltips)
* Incentivo: "Adicione mais dados para análises completas"

### Estados de Vazio (Empty States):

* **Sem imóveis**: "Cadastre seu primeiro imóvel para começar"
* **Sem receitas**: "Adicione receitas para acompanhar ganhos"
* **Sem despesas**: "Registre despesas para controlar custos"
* **Dashboard vazio**: Cards com CTAs para primeiros lançamentos

### Critérios de Sucesso (MVP):

* Onboarding completo em menos de 5 minutos
* Taxa de conclusão > 70%
* Usuário visualiza primeiro dado no dashboard
* Fluxo funciona perfeitamente em mobile

---

## 9) Notificações e Feedback do Sistema

### Tipos de Feedback:

**Sucesso**:
* Receita/despesa criada com sucesso
* Imóvel criado/editado
* Categoria criada/atualizada
* Exportação concluída
* Dados salvos

**Erro**:
* Falha na validação (campo obrigatório, formato inválido)
* Limite de plano atingido
* Erro de conexão
* Erro ao salvar dados

**Informação**:
* Dicas de uso
* Avisos sobre plano (próximo ao limite)
* Confirmações (antes de excluir)

**Carregamento**:
* Spinners em botões de ação
* Skeleton screens em listagens
* Progress bars em exportação

### Implementação (MVP):

* **Toast notifications**: mensagens temporárias no topo/canto da tela
* **Modais de confirmação**: antes de ações destrutivas (excluir)
* **Inline validation**: feedback em tempo real nos formulários
* **Estados de loading**: indicadores visuais durante requisições

### Critérios de UX:

* Mensagens claras e em português
* Feedback imediato (<300ms)
* Não bloquear a interface desnecessariamente
* Permitir desfazer quando possível

---

## Roadmap (Evoluções Futuras)

* Relatórios em PDF
* Projeções financeiras
* Comparativo ano a ano
* Alertas de custos recorrentes
* Múltiplos usuários por conta

---

## Requisitos Não Funcionais (Resumo)

* LGPD by design: não coletar dados de hóspedes
* Segurança: RLS por `auth.uid()`; tabelas globais (planos, plataformas) somente leitura
* Mobile-first: formulários rápidos e navegação rasa
* Desempenho: filtros e sumários responsivos para faixa de 1–6 imóveis

