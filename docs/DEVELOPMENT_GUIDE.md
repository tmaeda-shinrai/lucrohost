# DEVELOPMENT GUIDE — Guia de Desenvolvimento

Guia completo para configuração, desenvolvimento e deploy da aplicação **LucroHost**.

---

## Índice

1. [Requisitos](#requisitos)
2. [Setup Inicial](#setup-inicial)
3. [Configuração do Supabase](#configuração-do-supabase)
4. [Estrutura do Projeto](#estrutura-do-projeto)
5. [Convenções de Código](#convenções-de-código)
6. [Git Workflow](#git-workflow)
7. [Desenvolvimento](#desenvolvimento)
8. [Testes](#testes)
9. [Build e Deploy](#build-e-deploy)
10. [Troubleshooting](#troubleshooting)

---

## Requisitos

### Obrigatórios

- **Node.js**: v18.0.0 ou superior
- **npm**: v9.0.0 ou superior (ou yarn/pnpm)
- **Git**: v2.30.0 ou superior

### Recomendados

- **VS Code**: Editor com extensões recomendadas
- **Docker**: Para desenvolvimento local (opcional)
- **Supabase CLI**: Para gerenciar banco de dados

### Verificar Versões

```bash
node --version   # v18.0.0+
npm --version    # v9.0.0+
git --version    # v2.30.0+
```

---

## Setup Inicial

### 1. Clonar Repositório

```bash
git clone https://github.com/tmaeda-shinrai/lucrohost.git
cd lucrohost
```

### 2. Instalar Dependências

```bash
npm install
```

**Dependências principais**:
- `nuxt` - Framework
- `@nuxtjs/supabase` - Integração Supabase
- `@nuxtjs/tailwindcss` - Estilização
- `typescript` - Tipagem
- `vue` - Framework base

### 3. Configurar Variáveis de Ambiente

Copiar arquivo de exemplo:

```bash
cp .env.example .env
```

Editar `.env`:

```env
# Supabase Configuration
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=seu-anon-key-aqui

# App Configuration
BASE_URL=http://localhost:3000
NODE_ENV=development
```

**Obter credenciais do Supabase**:
1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Selecione seu projeto
3. Vá em **Settings** → **API**
4. Copie **Project URL** e **anon public key**

### 4. Iniciar Servidor de Desenvolvimento

```bash
npm run dev
```

Aplicação estará disponível em: `http://localhost:3000`

---

## Configuração do Supabase

### 1. Criar Projeto no Supabase

1. Acesse [https://app.supabase.com](https://app.supabase.com)
2. Clique em **New Project**
3. Preencha:
   - **Name**: lucrohost
   - **Database Password**: gere uma senha forte
   - **Region**: escolha mais próxima (ex: South America)
4. Aguarde criação (~2 minutos)

### 2. Executar Script SQL

1. No Supabase Dashboard, vá em **SQL Editor**
2. Abra o arquivo `supabase_script.sql` do projeto
3. Copie todo o conteúdo
4. Cole no SQL Editor
5. Clique em **Run** ou pressione `Ctrl+Enter`

Isso criará:
- ✅ Todas as tabelas
- ✅ Indexes
- ✅ Funções RPC
- ✅ RLS Policies
- ✅ Triggers
- ✅ Seed data (planos e plataformas)

### 3. Configurar Autenticação

1. Vá em **Authentication** → **Providers**
2. Certifique-se que **Email** está habilitado
3. Para desenvolvimento, desabilite confirmação de email:
   - **Enable email confirmations**: OFF
4. Para produção, mantenha **ON** e configure SMTP

### 4. Configurar Database Webhook (Criação de Perfil)

**Opção A - Via Dashboard (RECOMENDADO)**:

1. Vá em **Database** → **Webhooks**
2. Clique em **Create a new hook**
3. Configure:
   - **Name**: create_user_profile
   - **Table**: auth.users
   - **Events**: INSERT
   - **Type**: Database Function
   - **Function**: public.handle_new_user
4. Salve

**Opção B - Via SQL (se tiver acesso superuser)**:

No SQL Editor como postgres:

```sql
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### 5. Instalar Supabase CLI (Opcional)

Para gerenciar migrações localmente:

```bash
npm install -g supabase
supabase login
supabase init
```

---

## Estrutura do Projeto

```
lucrohost/
├── app/                          # Código da aplicação Nuxt 4
│   ├── app.vue                   # Root component
│   ├── assets/
│   │   └── css/
│   │       └── main.css          # TailwindCSS + estilos globais
│   ├── components/
│   │   ├── ui/                   # Componentes base (Button, Input, Card)
│   │   ├── layout/               # Header, Sidebar, Footer
│   │   ├── dashboard/            # Componentes do dashboard
│   │   ├── forms/                # Formulários (receitas, despesas)
│   │   └── charts/               # Gráficos (Chart.js/ECharts)
│   ├── composables/
│   │   ├── useAuth.ts            # Autenticação
│   │   ├── useImoveis.ts         # CRUD de imóveis
│   │   ├── useReceitas.ts        # CRUD de receitas
│   │   ├── useDespesas.ts        # CRUD de despesas
│   │   ├── useCategorias.ts      # CRUD de categorias
│   │   ├── useDashboard.ts       # Dados do dashboard
│   │   └── useSupabase.ts        # Cliente Supabase
│   ├── layouts/
│   │   ├── default.vue           # Layout autenticado
│   │   ├── auth.vue              # Layout de autenticação
│   │   └── onboarding.vue        # Layout de onboarding
│   ├── middleware/
│   │   ├── auth.ts               # Guard de autenticação
│   │   └── guest.ts              # Guard para não autenticados
│   ├── pages/
│   │   ├── index.vue             # Home/redirect
│   │   ├── auth/                 # Páginas de auth
│   │   ├── onboarding/           # Fluxo de onboarding
│   │   ├── dashboard/            # Dashboard principal
│   │   ├── imoveis/              # CRUD de imóveis
│   │   ├── receitas/             # CRUD de receitas
│   │   ├── despesas/             # CRUD de despesas
│   │   ├── categorias/           # Gestão de categorias
│   │   ├── relatorios/           # Relatórios
│   │   └── configuracoes/        # Configurações
│   ├── plugins/
│   │   └── supabase.client.ts    # Inicialização do Supabase
│   ├── types/
│   │   ├── database.types.ts     # Tipos gerados do Supabase
│   │   ├── models.ts             # Models da aplicação
│   │   └── enums.ts              # Enums
│   └── utils/
│       ├── date.ts               # Helpers de data
│       ├── currency.ts           # Formatação de moeda
│       ├── validators.ts         # Validações
│       └── constants.ts          # Constantes
├── docs/                         # Documentação
│   ├── PROJECT_PLAN.md
│   ├── FEATURES.md
│   ├── ARCHITECTURE.md
│   ├── API_SPECS.md
│   ├── UI_UX.md
│   └── DEVELOPMENT_GUIDE.md
├── public/                       # Arquivos estáticos
│   ├── favicon.ico
│   └── logo.svg
├── supabase_script.sql           # Script de criação do banco
├── SUPABASE_SETUP.md             # Guia de setup do Supabase
├── .env.example                  # Exemplo de variáveis de ambiente
├── .gitignore
├── nuxt.config.ts                # Configuração do Nuxt
├── package.json
├── tailwind.config.ts            # Configuração do TailwindCSS
└── tsconfig.json                 # Configuração do TypeScript
```

---

## Convenções de Código

### TypeScript

- ✅ Sempre usar TypeScript
- ✅ Tipos explícitos em funções públicas
- ✅ Evitar `any`, usar `unknown` quando necessário
- ✅ Interfaces para objetos complexos

```typescript
// ✅ Bom
interface Usuario {
  id: string
  nome: string
  email: string
}

const obterUsuario = async (id: string): Promise<Usuario | null> => {
  // ...
}

// ❌ Evitar
const obterUsuario = async (id) => {
  // ...
}
```

### Nomenclatura

**Arquivos**:
- Componentes: `PascalCase.vue` (ex: `ButtonPrimary.vue`)
- Composables: `camelCase.ts` (ex: `useReceitas.ts`)
- Utils: `camelCase.ts` (ex: `formatCurrency.ts`)
- Types: `camelCase.ts` (ex: `database.types.ts`)

**Variáveis e Funções**:
- Variáveis: `camelCase`
- Constantes: `UPPER_SNAKE_CASE`
- Funções: `camelCase`
- Componentes: `PascalCase`

```typescript
// ✅ Bom
const userName = 'João'
const MAX_IMOVEIS = 6
const fetchUsuario = async () => {}

// ❌ Evitar
const user_name = 'João'
const max_imoveis = 6
const FetchUsuario = async () => {}
```

### Componentes Vue

**Estrutura padrão**:

```vue
<script setup lang="ts">
// 1. Imports
import { ref } from 'vue'

// 2. Props e Emits
interface Props {
  title: string
  subtitle?: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  click: [value: string]
}>()

// 3. Composables
const supabase = useSupabaseClient()

// 4. State
const isLoading = ref(false)

// 5. Computed
const displayTitle = computed(() => props.title.toUpperCase())

// 6. Methods
const handleClick = () => {
  emit('click', 'value')
}

// 7. Lifecycle
onMounted(() => {
  // ...
})
</script>

<template>
  <div class="component">
    <h2>{{ displayTitle }}</h2>
    <button @click="handleClick">Click</button>
  </div>
</template>

<style scoped>
.component {
  @apply p-4 bg-white rounded-lg;
}
</style>
```

### Composables

**Padrão de composable**:

```typescript
// composables/useReceitas.ts
import type { Database } from '~/types/database.types'

type Receita = Database['public']['Tables']['receitas']['Row']
type ReceitaInsert = Database['public']['Tables']['receitas']['Insert']

export const useReceitas = () => {
  const supabase = useSupabaseClient<Database>()
  
  const listar = async () => {
    const { data, error } = await supabase
      .from('receitas')
      .select('*')
      .order('data_recebimento', { ascending: false })
    
    if (error) throw error
    return data
  }
  
  const criar = async (receita: ReceitaInsert) => {
    const { data, error } = await supabase
      .from('receitas')
      .insert(receita)
      .select()
      .single()
    
    if (error) throw error
    return data
  }
  
  return {
    listar,
    criar
  }
}
```

### Estilização (TailwindCSS)

- ✅ Usar classes do Tailwind sempre que possível
- ✅ Criar componentes para padrões repetidos
- ✅ Usar `@apply` apenas para casos complexos

```vue
<!-- ✅ Bom -->
<button class="px-4 py-2 bg-primary-500 text-white rounded-lg hover:bg-primary-600">
  Salvar
</button>

<!-- ❌ Evitar CSS customizado desnecessário -->
<button class="custom-button">Salvar</button>

<style>
.custom-button {
  padding: 0.5rem 1rem;
  background: blue;
  /* ... */
}
</style>
```

### Comentários

- ✅ Comentar "por quê", não "o quê"
- ✅ Usar JSDoc para funções públicas
- ✅ Comentários em português

```typescript
// ✅ Bom
/**
 * Valida se o usuário pode adicionar mais imóveis
 * baseado no limite do plano atual
 */
const validarLimiteImoveis = async (): Promise<boolean> => {
  // Usamos RPC porque a validação envolve JOIN com tabela de planos
  const { data } = await supabase.rpc('validar_limite_imoveis')
  return data ?? false
}

// ❌ Evitar
// Chama a função de validar limite
const validarLimiteImoveis = async () => {
  const { data } = await supabase.rpc('validar_limite_imoveis')
  return data
}
```

---

## Git Workflow

### Branches

```
main              # Branch principal (produção)
├── develop       # Branch de desenvolvimento
│   ├── feature/nome-da-feature
│   ├── fix/nome-do-fix
│   └── refactor/nome-do-refactor
```

### Padrão de Commits (Conventional Commits)

```
feat: adiciona autenticação via Supabase
fix: corrige validação de data em receitas
docs: atualiza README com instruções de setup
style: formata código com Prettier
refactor: reorganiza estrutura de composables
test: adiciona testes para useReceitas
chore: atualiza dependências
```

**Exemplos**:

```bash
git commit -m "feat: implementa CRUD de imóveis"
git commit -m "fix: corrige cálculo de margem no dashboard"
git commit -m "docs: adiciona documentação da API"
git commit -m "refactor: move validações para utils"
```

### Fluxo de Trabalho

**1. Criar branch para nova feature**:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/dashboard-mensal
```

**2. Desenvolver e commitar**:

```bash
git add .
git commit -m "feat: implementa dashboard mensal"
```

**3. Push e Pull Request**:

```bash
git push origin feature/dashboard-mensal
```

Abrir PR no GitHub para `develop`

**4. Code Review e Merge**:

Após aprovação, merge para `develop`

**5. Release para produção**:

```bash
git checkout main
git merge develop
git push origin main
```

---

## Desenvolvimento

### Comandos Úteis

```bash
# Iniciar dev server
npm run dev

# Build para produção
npm run build

# Preview do build
npm run preview

# Lint (ESLint)
npm run lint

# Lint e fix
npm run lint:fix

# Type check
npm run type-check

# Formatar código (Prettier)
npm run format

# Gerar tipos do Supabase
npm run generate:types
```

### Gerar Tipos do Supabase

```bash
# Instalar CLI
npm install -g supabase

# Login
supabase login

# Gerar tipos
supabase gen types typescript --project-id SEU_PROJECT_ID > app/types/database.types.ts
```

Ou via npx:

```bash
npx supabase gen types typescript --project-id SEU_PROJECT_ID > app/types/database.types.ts
```

### Hot Reload

Nuxt 4 tem hot reload automático. Alterações em:
- Componentes (.vue)
- Composables (.ts)
- Pages (.vue)
- Layouts (.vue)

Serão recarregadas automaticamente.

### Debug

**Browser DevTools**:
- Vue DevTools (extensão do Chrome/Firefox)
- Network tab para requisições Supabase
- Console para logs

**VS Code**:

Criar `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Nuxt: Chrome",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}"
    }
  ]
}
```

---

## Testes

### Setup de Testes

```bash
npm install -D vitest @vue/test-utils happy-dom
```

Criar `vitest.config.ts`:

```typescript
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'happy-dom',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html']
    }
  }
})
```

### Exemplo de Teste

```typescript
// composables/__tests__/useReceitas.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { useReceitas } from '../useReceitas'

describe('useReceitas', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })
  
  it('deve listar receitas', async () => {
    const { listar } = useReceitas()
    const receitas = await listar()
    
    expect(receitas).toBeDefined()
    expect(Array.isArray(receitas)).toBe(true)
  })
  
  it('deve criar receita', async () => {
    const { criar } = useReceitas()
    const novaReceita = {
      imovel_id: 'uuid',
      plataforma_id: 'uuid',
      data_recebimento: '2025-12-29',
      valor: 1500.00
    }
    
    const receita = await criar(novaReceita)
    
    expect(receita).toBeDefined()
    expect(receita.valor).toBe(1500.00)
  })
})
```

### Executar Testes

```bash
# Todos os testes
npm run test

# Watch mode
npm run test:watch

# Coverage
npm run test:coverage
```

---

## Build e Deploy

### Build Local

```bash
# Build para produção
npm run build

# Preview do build
npm run preview
```

Output em `.output/`

### Deploy na Vercel

**1. Via GitHub (Recomendado)**:

1. Push código para GitHub
2. Acesse [vercel.com](https://vercel.com)
3. Clique em **New Project**
4. Importe repositório do GitHub
5. Configure:
   - **Framework Preset**: Nuxt.js
   - **Build Command**: `npm run build`
   - **Output Directory**: `.output`
6. Adicione variáveis de ambiente:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
7. Deploy

**2. Via CLI**:

```bash
# Instalar Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel

# Deploy para produção
vercel --prod
```

### Deploy na Netlify

**1. Via GitHub**:

1. Acesse [netlify.com](https://netlify.com)
2. **New site from Git**
3. Selecione repositório
4. Configure:
   - **Build command**: `npm run build`
   - **Publish directory**: `.output/public`
5. Adicione variáveis de ambiente
6. Deploy

**2. Via CLI**:

```bash
# Instalar Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy
netlify deploy

# Deploy para produção
netlify deploy --prod
```

### Variáveis de Ambiente (Produção)

No dashboard da plataforma (Vercel/Netlify):

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=seu-anon-key-aqui
BASE_URL=https://lucrohost.com
NODE_ENV=production
```

### CI/CD (GitHub Actions)

Criar `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: 18
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm run test
        
      - name: Build
        run: npm run build
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
          
      - name: Deploy to Vercel
        run: vercel --prod --token=${{ secrets.VERCEL_TOKEN }}
```

---

## Troubleshooting

### Erro: "Module not found"

**Solução**:

```bash
# Limpar node_modules e reinstalar
rm -rf node_modules package-lock.json
npm install
```

### Erro: "Supabase client not initialized"

**Solução**:

Verificar se variáveis de ambiente estão configuradas:

```bash
# .env
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...
```

Reiniciar servidor:

```bash
npm run dev
```

### Erro: "JWT expired"

**Solução**:

Token expirou. Fazer logout e login novamente:

```typescript
await supabase.auth.signOut()
// Redirecionar para login
```

### Erro: "Row level security policy violation"

**Solução**:

Usuário tentando acessar dados que não pertencem a ele.

Verificar:
1. RLS policies estão aplicadas corretamente
2. `usuario_id` está sendo enviado corretamente
3. Usuário está autenticado

### Build falha com "Out of memory"

**Solução**:

Aumentar memória do Node:

```bash
NODE_OPTIONS=--max_old_space_size=4096 npm run build
```

### Hot reload não funciona

**Solução**:

1. Reiniciar servidor
2. Limpar `.nuxt`:

```bash
rm -rf .nuxt
npm run dev
```

### TypeScript não reconhece tipos do Supabase

**Solução**:

Regenerar tipos:

```bash
npx supabase gen types typescript --project-id SEU_PROJECT_ID > app/types/database.types.ts
```

---

## Extensões do VS Code Recomendadas

Criar `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "vue.volar",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "bradlc.vscode-tailwindcss",
    "formulahendry.auto-rename-tag",
    "christian-kohler.path-intellisense",
    "usernamehw.errorlens"
  ]
}
```

---

## Configurações do VS Code

Criar `.vscode/settings.json`:

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.tsdk": "node_modules/typescript/lib",
  "typescript.enablePromptUseWorkspaceTsdk": true,
  "tailwindCSS.experimental.classRegex": [
    ["class:\\s*?[\"'`]([^\"'`]*).*?[\"'`]", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
```

---

## Performance

### Otimizações

**1. Lazy Loading de Componentes**:

```vue
<script setup>
// Componente pesado carregado apenas quando necessário
const HeavyChart = defineAsyncComponent(() =>
  import('~/components/charts/HeavyChart.vue')
)
</script>
```

**2. Paginação**:

```typescript
// Sempre paginar listagens
const { data } = await supabase
  .from('receitas')
  .select('*')
  .range(0, 49) // 50 registros por vez
```

**3. Seleção de Campos**:

```typescript
// Selecionar apenas campos necessários
const { data } = await supabase
  .from('receitas')
  .select('id, valor, data_recebimento')
  // Não: .select('*')
```

**4. Imagens Otimizadas**:

```vue
<NuxtImg
  src="/logo.png"
  width="200"
  height="200"
  format="webp"
  loading="lazy"
/>
```

---

## Segurança

### Checklist

- [ ] Variáveis de ambiente não commitadas (.env no .gitignore)
- [ ] RLS habilitado em todas as tabelas
- [ ] Validação de dados no frontend e backend
- [ ] Sanitização de inputs
- [ ] HTTPS em produção
- [ ] Headers de segurança configurados
- [ ] Rate limiting (via Supabase)
- [ ] Logs de auditoria (futuro)

### Headers de Segurança

Adicionar em `nuxt.config.ts`:

```typescript
export default defineNuxtConfig({
  nitro: {
    routeRules: {
      '/**': {
        headers: {
          'X-Frame-Options': 'DENY',
          'X-Content-Type-Options': 'nosniff',
          'Referrer-Policy': 'strict-origin-when-cross-origin',
          'Permissions-Policy': 'geolocation=(), microphone=(), camera=()'
        }
      }
    }
  }
})
```

---

## Recursos Adicionais

### Documentação

- [Nuxt 4 Docs](https://nuxt.com)
- [Supabase Docs](https://supabase.com/docs)
- [TailwindCSS Docs](https://tailwindcss.com)
- [Vue 3 Docs](https://vuejs.org)
- [TypeScript Docs](https://www.typescriptlang.org)

### Comunidade

- [Nuxt Discord](https://discord.com/invite/ps2h6QT)
- [Supabase Discord](https://discord.supabase.com)
- [Vue Discord](https://discord.com/invite/vue)

### Ferramentas

- [Supabase Studio](https://app.supabase.com) - Dashboard
- [Vue DevTools](https://devtools.vuejs.org) - Debug
- [Postman](https://www.postman.com) - Testar API
- [TablePlus](https://tableplus.com) - Cliente SQL

---

## Próximos Passos

1. ✅ Configurar ambiente de desenvolvimento
2. ✅ Criar projeto no Supabase
3. ✅ Executar script SQL
4. ✅ Configurar variáveis de ambiente
5. ⏳ Implementar autenticação
6. ⏳ Criar componentes base
7. ⏳ Implementar CRUD de imóveis
8. ⏳ Implementar CRUD de receitas/despesas
9. ⏳ Desenvolver dashboard
10. ⏳ Testes e ajustes
11. ⏳ Deploy em staging
12. ⏳ Deploy em produção

---

## Suporte

Para dúvidas ou problemas:

1. Consulte a documentação em `/docs`
2. Verifique issues no GitHub
3. Abra uma nova issue com:
   - Descrição do problema
   - Passos para reproduzir
   - Logs de erro
   - Versões (Node, npm, etc)

---

**Última atualização**: 29 de dezembro de 2025
