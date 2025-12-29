# UI/UX — Design e Experiência do Usuário

Documentação completa do design system, componentes, fluxos e guidelines de interface do **LucroHost**.

---

## Princípios de Design

### 1. Clareza Financeira
- Informações financeiras devem ser imediatamente compreensíveis
- Uso de cores para diferenciar receitas (verde), despesas (vermelho) e lucro (azul)
- Hierarquia visual clara nos valores monetários

### 2. Simplicidade
- Interface limpa, sem elementos desnecessários
- Foco no essencial: receitas, despesas e lucro
- Navegação intuitiva com no máximo 2 níveis de profundidade

### 3. Mobile-First
- Design otimizado para mobile (375px+)
- Touch targets mínimos de 44x44px
- Formulários adaptados para teclados mobile
- Gestos nativos (swipe, pull-to-refresh)

### 4. Consistência
- Padrões visuais consistentes em toda aplicação
- Componentes reutilizáveis
- Comportamentos previsíveis

### 5. Feedback Imediato
- Loading states em todas as ações
- Confirmações visuais (toasts, modals)
- Validação inline em formulários
- Animações sutis para transições

---

## Paleta de Cores

### Cores Principais

```css
/* Primary - Azul (confiança, estabilidade) */
--primary-50: #eff6ff;
--primary-100: #dbeafe;
--primary-200: #bfdbfe;
--primary-300: #93c5fd;
--primary-400: #60a5fa;
--primary-500: #3b82f6;  /* Principal */
--primary-600: #2563eb;
--primary-700: #1d4ed8;
--primary-800: #1e40af;
--primary-900: #1e3a8a;

/* Success - Verde (receitas, sucesso) */
--success-50: #f0fdf4;
--success-100: #dcfce7;
--success-200: #bbf7d0;
--success-300: #86efac;
--success-400: #4ade80;
--success-500: #22c55e;  /* Principal */
--success-600: #16a34a;
--success-700: #15803d;
--success-800: #166534;
--success-900: #14532d;

/* Error/Danger - Vermelho (despesas, erros) */
--error-50: #fef2f2;
--error-100: #fee2e2;
--error-200: #fecaca;
--error-300: #fca5a5;
--error-400: #f87171;
--error-500: #ef4444;  /* Principal */
--error-600: #dc2626;
--error-700: #b91c1c;
--error-800: #991b1b;
--error-900: #7f1d1d;

/* Warning - Amarelo (alertas) */
--warning-50: #fffbeb;
--warning-100: #fef3c7;
--warning-200: #fde68a;
--warning-300: #fcd34d;
--warning-400: #fbbf24;
--warning-500: #f59e0b;  /* Principal */
--warning-600: #d97706;
--warning-700: #b45309;
--warning-800: #92400e;
--warning-900: #78350f;
```

### Cores Neutras

```css
/* Grays */
--gray-50: #f9fafb;
--gray-100: #f3f4f6;
--gray-200: #e5e7eb;
--gray-300: #d1d5db;
--gray-400: #9ca3af;
--gray-500: #6b7280;
--gray-600: #4b5563;
--gray-700: #374151;
--gray-800: #1f2937;
--gray-900: #111827;
```

### Semântica de Cores

- **Receitas**: Verde (success)
- **Despesas**: Vermelho (error)
- **Lucro Positivo**: Azul (primary) ou Verde
- **Lucro Negativo**: Vermelho
- **Margem**: Gradiente verde-amarelo-vermelho
- **Informativo**: Azul (primary)
- **Neutro**: Cinza (gray)

---

## Tipografia

### Font Family

```css
/* Sans-serif moderna e legível */
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 
             Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
```

**Alternativas**: System UI, Poppins, Outfit

### Font Sizes (Tailwind Scale)

```css
--text-xs: 0.75rem;    /* 12px */
--text-sm: 0.875rem;   /* 14px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.125rem;   /* 18px */
--text-xl: 1.25rem;    /* 20px */
--text-2xl: 1.5rem;    /* 24px */
--text-3xl: 1.875rem;  /* 30px */
--text-4xl: 2.25rem;   /* 36px */
--text-5xl: 3rem;      /* 48px */
```

### Font Weights

```css
--font-normal: 400;
--font-medium: 500;
--font-semibold: 600;
--font-bold: 700;
```

### Hierarquia Tipográfica

- **H1 (Page Title)**: 2xl/3xl, semibold, gray-900
- **H2 (Section Title)**: xl/2xl, semibold, gray-800
- **H3 (Subsection)**: lg/xl, medium, gray-700
- **Body**: base, normal, gray-600
- **Caption**: sm, normal, gray-500
- **Small**: xs, normal, gray-400

### Valores Monetários

```css
/* Grandes (Dashboard) */
font-size: 2xl/3xl;
font-weight: bold;
font-variant-numeric: tabular-nums;

/* Médios (Cards) */
font-size: xl/2xl;
font-weight: semibold;
font-variant-numeric: tabular-nums;

/* Pequenos (Tabelas) */
font-size: base/lg;
font-weight: medium;
font-variant-numeric: tabular-nums;
```

**Importante**: Usar `tabular-nums` para alinhar dígitos em colunas.

---

## Espaçamento

### Sistema de Espaçamento (Tailwind)

```css
--spacing-0: 0;
--spacing-1: 0.25rem;  /* 4px */
--spacing-2: 0.5rem;   /* 8px */
--spacing-3: 0.75rem;  /* 12px */
--spacing-4: 1rem;     /* 16px */
--spacing-5: 1.25rem;  /* 20px */
--spacing-6: 1.5rem;   /* 24px */
--spacing-8: 2rem;     /* 32px */
--spacing-10: 2.5rem;  /* 40px */
--spacing-12: 3rem;    /* 48px */
--spacing-16: 4rem;    /* 64px */
```

### Guidelines

- **Padding de Cards**: 16px (mobile), 24px (desktop)
- **Gap entre elementos**: 8px-16px
- **Margens de seção**: 24px-32px
- **Espaçamento entre campos de form**: 16px-20px

---

## Componentes Base

### 1. Buttons

#### Primary Button
```html
<button class="btn btn-primary">
  Criar Receita
</button>
```

**Specs:**
- Height: 44px (mobile), 40px (desktop)
- Padding: 12px 24px
- Border-radius: 8px
- Font: medium, base
- Transition: 150ms ease
- States: default, hover, active, disabled, loading

**Variantes:**
- `btn-primary` - Azul, ações principais
- `btn-secondary` - Cinza, ações secundárias
- `btn-success` - Verde, confirmações
- `btn-danger` - Vermelho, exclusões
- `btn-ghost` - Transparente, ações terciárias
- `btn-outline` - Borda apenas

#### Icon Button
```html
<button class="btn-icon">
  <icon-trash />
</button>
```

**Specs:**
- Size: 40x40px (mobile), 36x36px (desktop)
- Border-radius: 8px
- Icon size: 20px

---

### 2. Input Fields

#### Text Input
```html
<div class="input-group">
  <label for="nome" class="input-label">Nome do Imóvel</label>
  <input 
    id="nome" 
    type="text" 
    class="input" 
    placeholder="Ex: Apartamento Centro"
  />
  <span class="input-error">Campo obrigatório</span>
</div>
```

**Specs:**
- Height: 48px (mobile), 44px (desktop)
- Padding: 12px 16px
- Border: 1px solid gray-300
- Border-radius: 8px
- Font: base, normal
- Focus: ring primary-500

**States:**
- Default, Focus, Error, Disabled, Success

#### Number Input (Valores Monetários)
```html
<div class="input-group">
  <label for="valor" class="input-label">Valor</label>
  <div class="input-prefix">
    <span class="input-prefix-text">R$</span>
    <input 
      id="valor" 
      type="number" 
      class="input input-with-prefix" 
      placeholder="0,00"
      step="0.01"
      min="0"
    />
  </div>
</div>
```

#### Date Input
```html
<input 
  type="date" 
  class="input" 
  max="2025-12-29"
/>
```

**Importante**: Usar `max="today"` para impedir datas futuras.

#### Select
```html
<select class="input">
  <option value="">Selecione...</option>
  <option value="uuid-1">Apartamento Centro</option>
</select>
```

---

### 3. Cards

#### Basic Card
```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Receita Total</h3>
  </div>
  <div class="card-body">
    <p class="card-value text-success">R$ 12.500,00</p>
    <p class="card-subtitle">+12% vs mês anterior</p>
  </div>
</div>
```

**Specs:**
- Background: white
- Border: 1px solid gray-200
- Border-radius: 12px
- Padding: 16px-24px
- Shadow: sm (subtle)

**Variantes:**
- `card-interactive` - Com hover e cursor pointer
- `card-highlight` - Background colorido
- `card-bordered` - Borda destacada

---

### 4. Tables

#### Responsive Table
```html
<div class="table-container">
  <table class="table">
    <thead>
      <tr>
        <th>Data</th>
        <th>Imóvel</th>
        <th>Plataforma</th>
        <th class="text-right">Valor</th>
        <th></th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>29/12/2025</td>
        <td>Apartamento Centro</td>
        <td>Airbnb</td>
        <td class="text-right font-semibold text-success">
          R$ 1.500,00
        </td>
        <td>
          <button class="btn-icon">
            <icon-edit />
          </button>
        </td>
      </tr>
    </tbody>
  </table>
</div>
```

**Mobile**: Transformar em cards empilháveis.

---

### 5. Modals

```html
<div class="modal-overlay">
  <div class="modal">
    <div class="modal-header">
      <h3 class="modal-title">Confirmar Exclusão</h3>
      <button class="modal-close">
        <icon-x />
      </button>
    </div>
    <div class="modal-body">
      <p>Tem certeza que deseja excluir esta receita?</p>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary">Cancelar</button>
      <button class="btn btn-danger">Excluir</button>
    </div>
  </div>
</div>
```

**Specs:**
- Overlay: backdrop-blur, bg-black/50
- Modal: max-width 500px, border-radius 16px
- Animation: fade-in + scale

---

### 6. Toast Notifications

```html
<div class="toast toast-success">
  <icon-check-circle />
  <span>Receita criada com sucesso!</span>
</div>
```

**Posicionamento**: Top-right (desktop), Top-center (mobile)

**Duração**: 3-5 segundos

**Variantes**: success, error, warning, info

---

### 7. Empty States

```html
<div class="empty-state">
  <icon-inbox class="empty-state-icon" />
  <h3 class="empty-state-title">Nenhuma receita cadastrada</h3>
  <p class="empty-state-text">
    Comece adicionando sua primeira receita
  </p>
  <button class="btn btn-primary">
    Adicionar Receita
  </button>
</div>
```

---

### 8. Loading States

#### Skeleton
```html
<div class="skeleton">
  <div class="skeleton-line w-full h-4"></div>
  <div class="skeleton-line w-3/4 h-4"></div>
  <div class="skeleton-line w-1/2 h-4"></div>
</div>
```

#### Spinner
```html
<div class="spinner"></div>
```

---

## Layouts

### 1. Authenticated Layout

```
┌─────────────────────────────────────┐
│ Header (Sidebar Toggle + User)     │
├──────────┬──────────────────────────┤
│          │                          │
│ Sidebar  │  Main Content            │
│ (Nav)    │  (Dashboard/Pages)       │
│          │                          │
│          │                          │
└──────────┴──────────────────────────┘
```

**Desktop**: Sidebar fixa à esquerda (240px)
**Mobile**: Sidebar colapsável (drawer)

---

### 2. Auth Layout (Login/Signup)

```
┌─────────────────────────────────────┐
│                                     │
│         [Logo]                      │
│                                     │
│      ┌───────────────────┐          │
│      │                   │          │
│      │   Form Card       │          │
│      │                   │          │
│      └───────────────────┘          │
│                                     │
└─────────────────────────────────────┘
```

**Background**: Gradient ou imagem sutil

---

### 3. Dashboard Layout

```
┌─────────────────────────────────────┐
│ Header: Filtros (Mês/Ano, Imóvel)  │
├─────────────────────────────────────┤
│ Cards de Métricas                   │
│ ┌────────┐ ┌────────┐ ┌────────┐   │
│ │Receita │ │Despesa │ │ Lucro  │   │
│ └────────┘ └────────┘ └────────┘   │
├─────────────────────────────────────┤
│ Gráficos e Tabelas                  │
│ ┌───────────────────────────────┐   │
│ │ Resultado por Imóvel          │   │
│ └───────────────────────────────┘   │
│ ┌──────────┐ ┌──────────────────┐   │
│ │Receita   │ │ Top Despesas     │   │
│ │Plataforma│ │                  │   │
│ └──────────┘ └──────────────────┘   │
└─────────────────────────────────────┘
```

---

## Fluxos de Usuário

### 1. Onboarding (Primeira Experiência)

**Passo 1: Cadastro**
- Formulário simples: email + senha
- Validação em tempo real
- CTA claro: "Começar agora"

**Passo 2: Boas-vindas**
- Mensagem de boas-vindas
- Explicação breve do produto
- Informação do plano atual

**Passo 3: Primeiro Imóvel**
- Modal ou página dedicada
- Campo único: nome do imóvel
- Sugestão de exemplo
- Botão: "Continuar"

**Passo 4: Primeira Receita/Despesa**
- Escolha: "O que deseja adicionar primeiro?"
- Formulário simplificado (apenas campos essenciais)
- Feedback positivo ao salvar

**Passo 5: Dashboard**
- Redirecionamento automático
- Tour opcional com tooltips
- Incentivo para adicionar mais dados

---

### 2. Adicionar Receita

1. Click no botão "Adicionar Receita"
2. Modal/página com formulário:
   - Data (padrão: hoje)
   - Imóvel (select)
   - Plataforma (select)
   - Valor (input numérico com R$)
   - Observação (textarea opcional)
3. Validação inline
4. Botão "Salvar" com loading
5. Toast de sucesso
6. Listagem atualizada

---

### 3. Editar/Excluir Receita

**Editar**:
1. Click no ícone de edição
2. Modal pré-preenchido
3. Alterações
4. Salvar com confirmação

**Excluir**:
1. Click no ícone de excluir
2. Modal de confirmação: "Tem certeza?"
3. Confirmar ou Cancelar
4. Toast de confirmação

---

### 4. Trocar Plano

1. Página de Configurações > Plano
2. Cards com planos disponíveis
3. Destacar plano atual
4. Mostrar benefícios de cada plano
5. Botão de upgrade
6. Confirmação
7. Atualização imediata

---

## Navegação

### Menu Principal (Sidebar/Bottom Nav)

**Desktop (Sidebar):**
- Dashboard
- Imóveis
- Receitas
- Despesas
- Relatórios
- Configurações

**Mobile (Bottom Navigation):**
- Dashboard (home icon)
- Receitas (plus/arrow-up icon)
- Despesas (minus/arrow-down icon)
- Menu (hamburger)

---

### Breadcrumbs

```
Dashboard / Receitas / Editar
```

Usar em páginas profundas para orientação.

---

## Responsividade

### Breakpoints

```css
/* Mobile First */
xs: 0px      /* 375px+ */
sm: 640px    /* Tablet pequeno */
md: 768px    /* Tablet */
lg: 1024px   /* Desktop pequeno */
xl: 1280px   /* Desktop */
2xl: 1536px  /* Desktop grande */
```

### Adaptações por Tamanho

**Mobile (< 768px)**:
- Sidebar vira drawer
- Tabelas viram cards
- Colunas empilham
- Bottom navigation
- Formulários full-width

**Tablet (768px - 1023px)**:
- Layout híbrido
- 2 colunas para cards
- Sidebar colapsável

**Desktop (1024px+)**:
- Sidebar fixa
- 3+ colunas para cards
- Mais densidade de informação

---

## Acessibilidade

### WCAG 2.1 AA

1. **Contraste**: Mínimo 4.5:1 para texto normal
2. **Touch Targets**: Mínimo 44x44px
3. **Focus Visible**: Ring em todos os elementos interativos
4. **Labels**: Todos os inputs com labels associados
5. **ARIA**: Roles e attributes apropriados
6. **Teclado**: Navegação completa via tab

### Testes

- [x] Navegação por teclado
- [x] Screen reader (NVDA/VoiceOver)
- [x] Zoom até 200%
- [x] Cores com contraste adequado

---

## Animações e Transições

### Princípios

- Sutis e rápidas (150-300ms)
- Feedback, não decoração
- Podem ser desativadas (prefers-reduced-motion)

### Exemplos

```css
/* Hover em botões */
transition: all 150ms ease-in-out;
transform: scale(1.02);

/* Fade-in de modais */
animation: fadeIn 200ms ease-out;

/* Skeleton loading */
animation: pulse 2s infinite;

/* Toast slide-in */
animation: slideInRight 300ms ease-out;
```

---

## Ícones

### Biblioteca Recomendada

- **Heroicons** (v2) - clean, moderno
- **Lucide Icons** - alternativa
- **Phosphor Icons** - alternativa

### Tamanhos

- Small: 16px
- Medium: 20px (padrão)
- Large: 24px
- XLarge: 32px (empty states)

### Guidelines

- Usar outline style (stroke) para navegação
- Usar solid style (fill) para estados ativos
- Cores: inherit do texto ou específica

---

## Tratamento de Estados

### Loading

```
┌────────────────────────┐
│  ████████  (skeleton)  │
│  ████      (skeleton)  │
│  ██████    (skeleton)  │
└────────────────────────┘
```

### Empty State

```
┌────────────────────────┐
│        [Icon]          │
│                        │
│    Nenhum dado         │
│  Comece adicionando... │
│                        │
│    [CTA Button]        │
└────────────────────────┘
```

### Error State

```
┌────────────────────────┐
│    [Icon Alert]        │
│                        │
│    Algo deu errado     │
│  Tente novamente       │
│                        │
│   [Retry Button]       │
└────────────────────────┘
```

---

## Formatação de Dados

### Valores Monetários

```
R$ 1.234,56     ✅ Correto
R$ 1234.56      ❌ Errado
$ 1,234.56      ❌ Errado (PT-BR)
```

**Regra**: Formato brasileiro (BRL)

### Datas

```
29/12/2025      ✅ Listagens
29 dez 2025     ✅ Cards/Dashboard
29 de dezembro  ✅ Relatórios
```

### Percentuais

```
73,5%          ✅ Com vírgula
73.5%          ❌ Errado (PT-BR)
```

---

## Dark Mode (Futuro)

Preparar variáveis CSS para suporte futuro:

```css
:root {
  --bg-primary: white;
  --bg-secondary: gray-50;
  --text-primary: gray-900;
  --text-secondary: gray-600;
}

[data-theme="dark"] {
  --bg-primary: gray-900;
  --bg-secondary: gray-800;
  --text-primary: gray-50;
  --text-secondary: gray-300;
}
```

---

## Checklist de Implementação

### Componentes Base
- [ ] Button (primary, secondary, ghost, outline)
- [ ] Input (text, number, date, select)
- [ ] Card
- [ ] Table responsiva
- [ ] Modal
- [ ] Toast
- [ ] Empty state
- [ ] Skeleton loader

### Layouts
- [ ] Auth layout
- [ ] Default layout (authenticated)
- [ ] Dashboard layout

### Páginas
- [ ] Login
- [ ] Signup
- [ ] Dashboard
- [ ] Imóveis (lista, criar, editar)
- [ ] Receitas (lista, criar, editar)
- [ ] Despesas (lista, criar, editar)
- [ ] Categorias
- [ ] Relatórios
- [ ] Configurações

### Responsividade
- [ ] Mobile (375px+)
- [ ] Tablet (768px+)
- [ ] Desktop (1024px+)

### Acessibilidade
- [ ] Navegação por teclado
- [ ] Screen reader friendly
- [ ] Contraste adequado
- [ ] Focus visible

---

## Referências e Inspirações

### Design Systems
- [Tailwind UI](https://tailwindui.com/)
- [shadcn/ui](https://ui.shadcn.com/)
- [Material Design](https://m3.material.io/)
- [Ant Design](https://ant.design/)

### Exemplos de Dashboards Financeiros
- Stripe Dashboard
- Nubank App
- Conta Azul
- QuickBooks

### Ferramentas
- **Design**: Figma
- **Prototipação**: Figma, Framer
- **Ícones**: Heroicons, Lucide
- **Cores**: Coolors, Adobe Color
- **Contraste**: WebAIM Contrast Checker

---

## Próximos Passos

2. Implementar design system base (Tailwind + componentes)
3. Desenvolver páginas de autenticação
4. Implementar dashboard principal
5. Testar responsividade em dispositivos reais
6. Realizar testes de usabilidade com usuários
7. Iterar com base no feedback
