# ARCHITECTURE — Arquitetura Técnica

Documentação técnica da arquitetura da aplicação **LucroHost**, detalhando stack, estrutura de código, banco de dados, segurança e deployment.

---

## Stack Tecnológica

### Frontend

* **Framework**: Nuxt 4 (Vue 3 + Composition API)
* **Linguagem**: TypeScript
* **Estilização**: TailwindCSS
* **UI Components**: shadcn-vue ou Headless UI (a definir)
* **Gráficos**: Chart.js ou Apache ECharts
* **Validação**: Vee-Validate ou Zod
* **Data Fetching**: Nuxt useAsyncData / useFetch

### Backend & Infraestrutura

* **BaaS**: Supabase
* **Autenticação**: Supabase Auth (JWT)
* **Banco de Dados**: PostgreSQL (via Supabase)
* **Storage**: Supabase Storage (futuro: para PDFs)
* **API**: Supabase PostgREST (auto-gerada)
* **Realtime**: Supabase Realtime (opcional MVP)

### Segurança

* **RLS**: Row Level Security (Postgres)
* **Autenticação**: JWT tokens via Supabase
* **Policies**: Baseadas em `auth.uid()`

### DevOps

* **Hosting Frontend**: Vercel ou Netlify
* **Hosting Backend**: Supabase Cloud
* **CI/CD**: GitHub Actions
* **Ambiente**: Development + Production

---

## Estrutura do Projeto (Nuxt 4)

```
lucrohost/
├── app/
│   ├── app.vue                    # Root component
│   ├── assets/
│   │   └── css/
│   │       └── main.css           # TailwindCSS imports
│   ├── components/
│   │   ├── ui/                    # UI primitives (buttons, inputs, cards)
│   │   ├── layout/                # Layout components (header, sidebar, footer)
│   │   ├── dashboard/             # Dashboard-specific components
│   │   ├── forms/                 # Form components (receitas, despesas, imoveis)
│   │   └── charts/                # Chart components
│   ├── composables/
│   │   ├── useAuth.ts             # Auth helper
│   │   ├── useImoveis.ts          # Imóveis CRUD
│   │   ├── useReceitas.ts         # Receitas CRUD
│   │   ├── useDespesas.ts         # Despesas CRUD
│   │   ├── useCategorias.ts       # Categorias CRUD
│   │   ├── useDashboard.ts        # Dashboard data aggregation
│   │   └── useSupabase.ts         # Supabase client
│   ├── layouts/
│   │   ├── default.vue            # Authenticated layout (sidebar + header)
│   │   ├── auth.vue               # Auth pages layout (login, signup)
│   │   └── onboarding.vue         # Onboarding flow layout
│   ├── middleware/
│   │   ├── auth.ts                # Auth guard (redirect if not logged in)
│   │   └── guest.ts               # Guest guard (redirect if logged in)
│   ├── pages/
│   │   ├── index.vue              # Home/Landing (redirect to dashboard or login)
│   │   ├── auth/
│   │   │   ├── login.vue          # Login page
│   │   │   ├── signup.vue         # Signup page
│   │   │   ├── forgot-password.vue
│   │   │   └── reset-password.vue
│   │   ├── onboarding/
│   │   │   ├── index.vue          # Welcome
│   │   │   ├── imovel.vue         # Primeiro imóvel
│   │   │   └── primeiro-lancamento.vue # Primeira receita/despesa
│   │   ├── dashboard/
│   │   │   └── index.vue          # Dashboard principal
│   │   ├── imoveis/
│   │   │   ├── index.vue          # Lista de imóveis
│   │   │   ├── criar.vue          # Criar imóvel
│   │   │   └── [id]/
│   │   │       └── editar.vue     # Editar imóvel
│   │   ├── receitas/
│   │   │   ├── index.vue          # Lista de receitas
│   │   │   ├── criar.vue          # Criar receita
│   │   │   └── [id]/
│   │   │       └── editar.vue     # Editar receita
│   │   ├── despesas/
│   │   │   ├── index.vue          # Lista de despesas
│   │   │   ├── criar.vue          # Criar despesa
│   │   │   └── [id]/
│   │   │       └── editar.vue     # Editar despesa
│   │   ├── categorias/
│   │   │   └── index.vue          # Gestão de categorias
│   │   ├── relatorios/
│   │   │   ├── index.vue          # Relatórios disponíveis
│   │   │   └── anual.vue          # Relatório anual (Plano Pro)
│   │   └── configuracoes/
│   │       ├── index.vue          # Configurações gerais
│   │       ├── perfil.vue         # Editar perfil
│   │       └── plano.vue          # Gestão de plano
│   ├── plugins/
│   │   ├── supabase.client.ts     # Supabase client initialization
│   │   └── tailwind.css           # Import TailwindCSS
│   ├── types/
│   │   ├── database.types.ts      # Supabase generated types
│   │   ├── models.ts              # Application models
│   │   └── enums.ts               # Enums (PlanoTipo, StatusImovel, etc)
│   └── utils/
│       ├── date.ts                # Date helpers
│       ├── currency.ts            # Currency formatting
│       ├── validators.ts          # Custom validators
│       └── constants.ts           # App constants
├── nuxt.config.ts                 # Nuxt configuration
├── tailwind.config.ts             # Tailwind configuration
├── tsconfig.json                  # TypeScript configuration
├── package.json
└── .env.example                   # Environment variables example
```

---

## Database Schema (Supabase/PostgreSQL)

### Tabelas Principais

#### 1. `usuarios`

Perfil do usuário (complementa `auth.users` do Supabase).

```sql
CREATE TABLE usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plano_id UUID REFERENCES planos(id) NOT NULL,
  nome VARCHAR(100),
  email VARCHAR(255) NOT NULL UNIQUE,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_usuarios_plano ON usuarios(plano_id);
CREATE INDEX idx_usuarios_email ON usuarios(email);
```

#### 2. `planos`

Tabela de planos (seed data, read-only para usuários).

```sql
CREATE TABLE planos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(50) NOT NULL UNIQUE, -- 'Essencial', 'Anfitrião', 'Pro'
  limite_imoveis INTEGER NOT NULL,
  preco_mensal DECIMAL(10, 2),
  descricao TEXT,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Seed data (inserir via migration)
INSERT INTO planos (nome, limite_imoveis, preco_mensal, descricao) VALUES
  ('Essencial', 1, 0.00, 'Controle completo para um imóvel'),
  ('Anfitrião', 3, 29.90, 'Plano foco do produto - até 3 imóveis'),
  ('Pro', 6, 59.90, 'Recursos de análise avançada - até 6 imóveis');
```

#### 3. `imoveis`

```sql
CREATE TABLE imoveis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  nome VARCHAR(100) NOT NULL,
  status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_imoveis_usuario ON imoveis(usuario_id);
CREATE INDEX idx_imoveis_status ON imoveis(status);
```

#### 4. `plataformas`

Tabela de plataformas (seed data, read-only para usuários).

```sql
CREATE TABLE plataformas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(50) NOT NULL UNIQUE, -- 'Airbnb', 'Booking', 'Direto', 'Outro'
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Seed data
INSERT INTO plataformas (nome) VALUES
  ('Airbnb'),
  ('Booking'),
  ('Direto'),
  ('Outro');
```

#### 5. `receitas`

```sql
CREATE TABLE receitas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  imovel_id UUID REFERENCES imoveis(id) ON DELETE RESTRICT NOT NULL,
  plataforma_id UUID REFERENCES plataformas(id) NOT NULL,
  data_recebimento DATE NOT NULL,
  valor DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
  observacao TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_receitas_usuario ON receitas(usuario_id);
CREATE INDEX idx_receitas_imovel ON receitas(imovel_id);
CREATE INDEX idx_receitas_plataforma ON receitas(plataforma_id);
CREATE INDEX idx_receitas_data ON receitas(data_recebimento DESC);
```

#### 6. `categorias_despesa`

```sql
CREATE TABLE categorias_despesa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  nome VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(usuario_id, nome) -- Nome único por usuário
);

-- Indexes
CREATE INDEX idx_categorias_usuario ON categorias_despesa(usuario_id);
CREATE INDEX idx_categorias_status ON categorias_despesa(status);
```

#### 7. `despesas`

```sql
CREATE TABLE despesas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  imovel_id UUID REFERENCES imoveis(id) ON DELETE RESTRICT NOT NULL,
  categoria_id UUID REFERENCES categorias_despesa(id) ON DELETE RESTRICT NOT NULL,
  data_pagamento DATE NOT NULL,
  valor DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
  tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('fixa', 'variavel')),
  recorrente BOOLEAN DEFAULT FALSE,
  observacao TEXT,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_despesas_usuario ON despesas(usuario_id);
CREATE INDEX idx_despesas_imovel ON despesas(imovel_id);
CREATE INDEX idx_despesas_categoria ON despesas(categoria_id);
CREATE INDEX idx_despesas_data ON despesas(data_pagamento DESC);
CREATE INDEX idx_despesas_tipo ON despesas(tipo);
```

---

## Row Level Security (RLS)

Todas as tabelas de usuário devem ter RLS habilitado.

### Princípios RLS

1. **Isolamento por usuário**: cada usuário acessa apenas seus próprios dados
2. **Baseado em `auth.uid()`**: policies usam `auth.uid() = usuario_id`
3. **Tabelas globais read-only**: planos e plataformas são somente leitura
4. **Validações no backend**: limite de imóveis via RPC

### Exemplo de Policies

#### `usuarios`

```sql
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;

-- SELECT: usuário vê apenas seu próprio perfil
CREATE POLICY "Usuários podem ver o próprio perfil"
  ON usuarios FOR SELECT
  USING (auth.uid() = id);

-- UPDATE: usuário atualiza apenas seu próprio perfil
CREATE POLICY "Usuários podem atualizar o próprio perfil"
  ON usuarios FOR UPDATE
  USING (auth.uid() = id);
```

#### `imoveis`

```sql
ALTER TABLE imoveis ENABLE ROW LEVEL SECURITY;

-- SELECT
CREATE POLICY "Usuários veem apenas seus imóveis"
  ON imoveis FOR SELECT
  USING (auth.uid() = usuario_id);

-- INSERT (com validação de limite via trigger ou RPC)
CREATE POLICY "Usuários podem criar imóveis"
  ON imoveis FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

-- UPDATE
CREATE POLICY "Usuários podem atualizar seus imóveis"
  ON imoveis FOR UPDATE
  USING (auth.uid() = usuario_id);

-- DELETE (soft delete via UPDATE de status)
CREATE POLICY "Usuários podem desativar seus imóveis"
  ON imoveis FOR DELETE
  USING (auth.uid() = usuario_id);
```

#### `receitas`

```sql
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários veem apenas suas receitas"
  ON receitas FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar receitas"
  ON receitas FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas receitas"
  ON receitas FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem excluir suas receitas"
  ON receitas FOR DELETE
  USING (auth.uid() = usuario_id);
```

#### `despesas`

```sql
ALTER TABLE despesas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários veem apenas suas despesas"
  ON despesas FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar despesas"
  ON despesas FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas despesas"
  ON despesas FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem excluir suas despesas"
  ON despesas FOR DELETE
  USING (auth.uid() = usuario_id);
```

#### `categorias_despesa`

```sql
ALTER TABLE categorias_despesa ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários veem apenas suas categorias"
  ON categorias_despesa FOR SELECT
  USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem criar categorias"
  ON categorias_despesa FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem atualizar suas categorias"
  ON categorias_despesa FOR UPDATE
  USING (auth.uid() = usuario_id);

CREATE POLICY "Usuários podem excluir suas categorias"
  ON categorias_despesa FOR DELETE
  USING (auth.uid() = usuario_id);
```

#### Tabelas Globais (read-only)

```sql
-- planos
ALTER TABLE planos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer usuário autenticado pode ver planos"
  ON planos FOR SELECT
  USING (auth.role() = 'authenticated');

-- plataformas
ALTER TABLE plataformas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer usuário autenticado pode ver plataformas"
  ON plataformas FOR SELECT
  USING (auth.role() = 'authenticated');
```

---

## Funções RPC (Remote Procedure Calls)

Funções PostgreSQL expostas via Supabase para lógica de negócio.

### 1. `validar_limite_imoveis`

Valida se o usuário pode adicionar mais imóveis conforme seu plano.

```sql
CREATE OR REPLACE FUNCTION validar_limite_imoveis()
RETURNS BOOLEAN AS $$
DECLARE
  limite INTEGER;
  contagem INTEGER;
BEGIN
  -- Busca limite do plano do usuário
  SELECT p.limite_imoveis INTO limite
  FROM usuarios u
  JOIN planos p ON p.id = u.plano_id
  WHERE u.id = auth.uid();
  
  -- Conta imóveis ativos do usuário
  SELECT COUNT(*) INTO contagem
  FROM imoveis
  WHERE usuario_id = auth.uid() AND status = 'ativo';
  
  -- Retorna se ainda pode adicionar
  RETURN contagem < limite;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2. `obter_dashboard_mensal`

Retorna dados agregados para o dashboard mensal.

```sql
CREATE OR REPLACE FUNCTION obter_dashboard_mensal(
  mes INTEGER,
  ano INTEGER,
  imovel_uuid UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  receita_total DECIMAL(10, 2);
  despesa_total DECIMAL(10, 2);
  lucro_liquido DECIMAL(10, 2);
  margem DECIMAL(5, 2);
BEGIN
  -- Receita total
  SELECT COALESCE(SUM(valor), 0) INTO receita_total
  FROM receitas
  WHERE usuario_id = auth.uid()
    AND EXTRACT(MONTH FROM data_recebimento) = mes
    AND EXTRACT(YEAR FROM data_recebimento) = ano
    AND (imovel_uuid IS NULL OR imovel_id = imovel_uuid);
  
  -- Despesa total
  SELECT COALESCE(SUM(valor), 0) INTO despesa_total
  FROM despesas
  WHERE usuario_id = auth.uid()
    AND EXTRACT(MONTH FROM data_pagamento) = mes
    AND EXTRACT(YEAR FROM data_pagamento) = ano
    AND (imovel_uuid IS NULL OR imovel_id = imovel_uuid);
  
  -- Lucro e margem
  lucro_liquido := receita_total - despesa_total;
  margem := CASE 
    WHEN receita_total > 0 THEN (lucro_liquido / receita_total) * 100
    ELSE 0
  END;
  
  RETURN json_build_object(
    'receita_total', receita_total,
    'despesa_total', despesa_total,
    'lucro_liquido', lucro_liquido,
    'margem', margem
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 3. `criar_categorias_iniciais`

Cria categorias sugeridas para novo usuário.

```sql
CREATE OR REPLACE FUNCTION criar_categorias_iniciais()
RETURNS VOID AS $$
BEGIN
  INSERT INTO categorias_despesa (usuario_id, nome)
  VALUES
    (auth.uid(), 'Limpeza'),
    (auth.uid(), 'Manutenção'),
    (auth.uid(), 'Condomínio'),
    (auth.uid(), 'IPTU'),
    (auth.uid(), 'Internet'),
    (auth.uid(), 'Energia'),
    (auth.uid(), 'Água'),
    (auth.uid(), 'Gás'),
    (auth.uid(), 'Móveis e Equipamentos'),
    (auth.uid(), 'Taxas e Impostos')
  ON CONFLICT DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Autenticação (Supabase Auth)

### Fluxo de Autenticação

1. **Signup**: `supabase.auth.signUp({ email, password })`
   - Cria usuário em `auth.users`
   - Trigger cria registro em `usuarios` automaticamente
   - Associa plano padrão (Essencial)
   - Chama `criar_categorias_iniciais()`

2. **Login**: `supabase.auth.signInWithPassword({ email, password })`
   - Retorna JWT token
   - Token armazenado em localStorage (gerenciado pelo Supabase)

3. **Logout**: `supabase.auth.signOut()`
   - Limpa token e sessão

4. **Password Reset**:
   - `supabase.auth.resetPasswordForEmail(email)`
   - Envia email com link de reset
   - `supabase.auth.updateUser({ password })`

### Trigger para Criar Perfil

```sql
-- Função trigger
CREATE OR REPLACE FUNCTION criar_perfil_usuario()
RETURNS TRIGGER AS $$
DECLARE
  plano_essencial_id UUID;
BEGIN
  -- Busca ID do plano Essencial
  SELECT id INTO plano_essencial_id
  FROM planos
  WHERE nome = 'Essencial'
  LIMIT 1;
  
  -- Cria perfil do usuário
  INSERT INTO usuarios (id, plano_id, email)
  VALUES (NEW.id, plano_essencial_id, NEW.email);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION criar_perfil_usuario();
```

---

## Composables (Frontend)

### `useAuth.ts`

```typescript
export const useAuth = () => {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  
  const signUp = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signUp({ email, password })
    if (error) throw error
    return data
  }
  
  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    return data
  }
  
  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }
  
  return { user, signUp, signIn, signOut }
}
```

### `useImoveis.ts`

```typescript
export const useImoveis = () => {
  const supabase = useSupabaseClient()
  
  const listarImoveis = async (status?: 'ativo' | 'inativo') => {
    let query = supabase.from('imoveis').select('*').order('criado_em', { ascending: false })
    if (status) query = query.eq('status', status)
    const { data, error } = await query
    if (error) throw error
    return data
  }
  
  const criarImovel = async (nome: string) => {
    // Validar limite
    const { data: podeAdicionar } = await supabase.rpc('validar_limite_imoveis')
    if (!podeAdicionar) throw new Error('Limite de imóveis atingido')
    
    const { data, error } = await supabase.from('imoveis').insert({ nome }).select().single()
    if (error) throw error
    return data
  }
  
  return { listarImoveis, criarImovel }
}
```

---

## Deployment

### Frontend (Vercel)

1. Conectar repositório GitHub
2. Configurar variáveis de ambiente:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Build command: `npm run build`
4. Deploy automático em push para `main`

### Backend (Supabase)

1. Criar projeto no Supabase
2. Aplicar migrations via Supabase CLI ou Dashboard
3. Configurar RLS policies
4. Seed data inicial (planos, plataformas)
5. Habilitar Email Auth

### Migrations

Usar Supabase CLI para versionamento:

```bash
supabase init
supabase migration new create_schema
supabase db push
```

---

## Considerações de Performance

### Frontend

* **Code splitting**: Lazy loading de rotas
* **Caching**: Nuxt data caching para listagens
* **Debounce**: Filtros com debounce (300ms)
* **Paginação**: Listagens paginadas (50 itens por página)

### Backend

* **Indexes**: Todos os campos de filtro/ordenação indexados
* **Aggregations**: Funções RPC para agregações complexas
* **Connection pooling**: Gerenciado pelo Supabase
* **Query optimization**: SELECT apenas campos necessários

---

## Próximos Passos Técnicos

1. Setup inicial Nuxt 4 + Supabase
2. Criar schema completo no Supabase
3. Implementar RLS policies
4. Implementar autenticação e middleware
5. Criar composables base (useAuth, useImoveis, etc)
6. Desenvolver componentes UI (design system)
7. Implementar páginas core (dashboard, receitas, despesas)
8. Testes e otimizações
9. Deploy em staging
10. Deploy em production
