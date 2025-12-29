# Configuração do Supabase - LucroHost

Este guia complementa o script `supabase_script.sql` com configurações que devem ser feitas via Dashboard do Supabase.

---

## 1. Executar o Script SQL Principal

No **SQL Editor** do Supabase Dashboard:

```sql
-- Cole e execute todo o conteúdo de supabase_script.sql
```

Isso criará:
- ✅ Todas as tabelas
- ✅ Indexes
- ✅ Funções RPC
- ✅ RLS Policies
- ✅ Seed data (planos e plataformas)
- ✅ Função `handle_new_user()`

---

## 2. Configurar Trigger para Criação Automática de Perfil

Como não podemos criar triggers em `auth.users` via SQL comum, escolha uma das opções:

### Opção A: Database Webhooks (RECOMENDADO)

1. Acesse: **Database** → **Database Webhooks**
2. Clique em **Enable Webhooks** (se necessário)
3. Clique em **Create a new hook**
4. Configure:
   - **Name**: `create_user_profile`
   - **Table**: `auth.users`
   - **Events**: Marque apenas `INSERT`
   - **Type**: Selecione `HTTP Request` 
   - **Method**: `POST`
   - **URL**: Use o endpoint da sua própria API ou leave blank
   
   **OU configure Database Function:**
   - **Type**: Selecione `Database Function`
   - **Function**: `public.handle_new_user`

5. Salve

### Opção B: Via SQL com Privilégios de Superusuário

Se você tiver acesso ao usuário `postgres` (proprietário do schema `auth`):

```sql
-- Execute como postgres/superuser no SQL Editor
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### Opção C: Manualmente na Aplicação (Fallback)

Se as opções acima não funcionarem, crie o perfil manualmente no frontend após signup:

```typescript
// No seu composable useAuth.ts
const signUp = async (email: string, password: string) => {
  const { data, error } = await supabase.auth.signUp({ email, password })
  if (error) throw error
  
  // Criar perfil manualmente
  if (data.user) {
    // Buscar plano Essencial
    const { data: plano } = await supabase
      .from('planos')
      .select('id')
      .eq('nome', 'Essencial')
      .single()
    
    // Criar perfil do usuário
    await supabase.from('usuarios').insert({
      id: data.user.id,
      plano_id: plano?.id,
      email: data.user.email
    })
    
    // Criar categorias iniciais
    await supabase.rpc('criar_categorias_iniciais')
  }
  
  return data
}
```

---

## 3. Configurar Autenticação por Email

1. Acesse: **Authentication** → **Providers**
2. Certifique-se que **Email** está habilitado
3. Configure as opções:
   - ✅ Enable email signup
   - ✅ Enable email confirmations (recomendado para produção)
   - ⚠️ Disable email confirmations (apenas para desenvolvimento)

4. Configure os **Email Templates** em **Authentication** → **Email Templates**

---

## 4. Configurar Variáveis de Ambiente

No seu projeto Nuxt, crie/atualize o arquivo `.env`:

```env
# Supabase Configuration
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=seu-anon-key-aqui
```

Para obter essas informações:
1. Acesse: **Settings** → **API**
2. Copie:
   - **Project URL** → `SUPABASE_URL`
   - **anon public** key → `SUPABASE_ANON_KEY`

---

## 5. Testar a Configuração

### 5.1 Verificar Tabelas

```sql
-- No SQL Editor
SELECT tablename FROM pg_tables WHERE schemaname = 'public';
```

Deve retornar: `planos`, `usuarios`, `plataformas`, `imoveis`, `categorias_despesa`, `receitas`, `despesas`

### 5.2 Verificar Funções RPC

```sql
-- No SQL Editor
SELECT proname FROM pg_proc 
WHERE pronamespace = 'public'::regnamespace 
  AND proname LIKE '%obter%' OR proname LIKE '%validar%' OR proname LIKE '%criar%';
```

Deve retornar as 6 funções criadas.

### 5.3 Verificar RLS Policies

```sql
-- No SQL Editor
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public';
```

Deve retornar todas as policies criadas (21 no total).

### 5.4 Verificar Seed Data

```sql
-- Verificar planos
SELECT * FROM planos;

-- Verificar plataformas
SELECT * FROM plataformas;
```

Deve retornar 3 planos e 4 plataformas.

---

## 6. Testar Criação de Usuário

### Via Supabase Dashboard

1. Acesse: **Authentication** → **Users**
2. Clique em **Add user**
3. Preencha email e senha
4. Clique em **Create user**
5. Verifique se o perfil foi criado em `usuarios`:

```sql
SELECT u.*, p.nome as plano_nome 
FROM usuarios u 
JOIN planos p ON p.id = u.plano_id;
```

### Via Aplicação Frontend

```typescript
// Teste de signup
const { data, error } = await supabase.auth.signUp({
  email: 'teste@example.com',
  password: 'senha123'
})

if (!error) {
  console.log('Usuário criado:', data.user)
  
  // Verificar se perfil foi criado
  const { data: perfil } = await supabase
    .from('usuarios')
    .select('*, planos(nome)')
    .eq('id', data.user.id)
    .single()
  
  console.log('Perfil criado:', perfil)
}
```

---

## 7. Troubleshooting

### Erro: "new row violates row-level security policy"

**Solução**: Verifique se as RLS policies estão aplicadas corretamente e se o usuário está autenticado.

### Erro: "relation auth.users does not exist"

**Solução**: Você está no projeto correto do Supabase? Verifique a URL.

### Perfil não é criado automaticamente

**Soluções**:
1. Verifique se o Database Webhook foi configurado corretamente
2. Tente a Opção B (trigger via superuser)
3. Use a Opção C (criação manual no frontend)

### Erro: "function public.handle_new_user() does not exist"

**Solução**: Execute novamente a seção 4.1 do `supabase_script.sql`:

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
-- ... (copie a função completa do script)
```

---

## 8. Próximos Passos

Após a configuração bem-sucedida:

1. ✅ Implementar autenticação no frontend (Nuxt)
2. ✅ Criar composables (useAuth, useImoveis, etc)
3. ✅ Implementar páginas de cadastro e login
4. ✅ Implementar dashboard e CRUD de receitas/despesas
5. ✅ Testar fluxo completo de onboarding

---

## Referências

- [Supabase Database Webhooks](https://supabase.com/docs/guides/database/webhooks)
- [Supabase Auth Triggers](https://supabase.com/docs/guides/auth/auth-hooks)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
