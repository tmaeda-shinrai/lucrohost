# API SPECS — Especificação da API

Documentação completa da API do **LucroHost**, baseada em Supabase (PostgREST) e funções RPC personalizadas.

---

## Arquitetura da API

* **Base URL**: `https://[PROJECT_ID].supabase.co`
* **API Type**: REST (PostgREST auto-gerada)
* **Autenticação**: Bearer Token (JWT)
* **Formato**: JSON
* **Versionamento**: Não versionado (estável via Supabase)

---

## Autenticação

### Base URL de Auth

```
https://[PROJECT_ID].supabase.co/auth/v1
```

### Headers Obrigatórios

```http
apikey: [SUPABASE_ANON_KEY]
Content-Type: application/json
```

### Headers Autenticados

```http
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [JWT_TOKEN]
Content-Type: application/json
```

---

## Endpoints de Autenticação

### 1. Signup (Cadastro)

**POST** `/auth/v1/signup`

Cria novo usuário e automaticamente cria perfil via trigger.

**Request Body:**
```json
{
  "email": "usuario@example.com",
  "password": "senha123456"
}
```

**Response Success (200):**
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.refresh_token...",
  "user": {
    "id": "uuid-do-usuario",
    "email": "usuario@example.com",
    "created_at": "2025-12-29T10:00:00Z"
  }
}
```

**Response Error (400):**
```json
{
  "error": "User already registered",
  "error_code": "user_already_exists"
}
```

---

### 2. Login (Sign In)

**POST** `/auth/v1/token?grant_type=password`

Autentica usuário e retorna JWT token.

**Request Body:**
```json
{
  "email": "usuario@example.com",
  "password": "senha123456"
}
```

**Response Success (200):**
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.refresh_token...",
  "user": {
    "id": "uuid-do-usuario",
    "email": "usuario@example.com"
  }
}
```

**Response Error (400):**
```json
{
  "error": "Invalid login credentials",
  "error_code": "invalid_grant"
}
```

---

### 3. Logout (Sign Out)

**POST** `/auth/v1/logout`

Invalida o token atual.

**Headers:**
```http
Authorization: Bearer [JWT_TOKEN]
```

**Response Success (204):**
```
No Content
```

---

### 4. Recuperar Senha

**POST** `/auth/v1/recover`

Envia email com link de recuperação.

**Request Body:**
```json
{
  "email": "usuario@example.com"
}
```

**Response Success (200):**
```json
{}
```

---

### 5. Atualizar Senha

**PUT** `/auth/v1/user`

Atualiza senha do usuário autenticado.

**Headers:**
```http
Authorization: Bearer [JWT_TOKEN]
```

**Request Body:**
```json
{
  "password": "nova_senha_123"
}
```

**Response Success (200):**
```json
{
  "id": "uuid-do-usuario",
  "email": "usuario@example.com",
  "updated_at": "2025-12-29T10:05:00Z"
}
```

---

## Endpoints REST (PostgREST)

Base URL: `https://[PROJECT_ID].supabase.co/rest/v1`

### Headers para Requisições REST

```http
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [JWT_TOKEN]
Content-Type: application/json
Prefer: return=representation  # Para receber objeto criado/atualizado
```

---

## 1. Usuários

### GET /usuarios

Lista perfil do usuário autenticado (RLS aplicado).

**Query Params:**
- `select` - Campos a retornar
- `id` - Filtrar por ID

**Response:**
```json
[
  {
    "id": "uuid-do-usuario",
    "plano_id": "uuid-do-plano",
    "nome": "João Silva",
    "email": "joao@example.com",
    "criado_em": "2025-12-29T10:00:00Z",
    "atualizado_em": "2025-12-29T10:00:00Z",
    "planos": {
      "nome": "Essencial",
      "limite_imoveis": 1
    }
  }
]
```

**Exemplo com JOIN:**
```http
GET /usuarios?select=*,planos(nome,limite_imoveis)
```

---

### PATCH /usuarios

Atualiza perfil do usuário autenticado.

**Query Param:**
```
?id=eq.uuid-do-usuario
```

**Request Body:**
```json
{
  "nome": "João Silva Atualizado"
}
```

**Response (200):**
```json
{
  "id": "uuid-do-usuario",
  "plano_id": "uuid-do-plano",
  "nome": "João Silva Atualizado",
  "email": "joao@example.com",
  "atualizado_em": "2025-12-29T10:10:00Z"
}
```

---

## 2. Planos

### GET /planos

Lista todos os planos disponíveis (read-only).

**Response:**
```json
[
  {
    "id": "uuid-plano-1",
    "nome": "Essencial",
    "limite_imoveis": 1,
    "preco_mensal": 0.00,
    "descricao": "Controle completo para um imóvel",
    "ativo": true,
    "criado_em": "2025-12-29T00:00:00Z"
  },
  {
    "id": "uuid-plano-2",
    "nome": "Anfitrião",
    "limite_imoveis": 3,
    "preco_mensal": 29.90,
    "descricao": "Plano foco do produto - até 3 imóveis",
    "ativo": true,
    "criado_em": "2025-12-29T00:00:00Z"
  }
]
```

---

## 3. Plataformas

### GET /plataformas

Lista todas as plataformas disponíveis (read-only).

**Response:**
```json
[
  {
    "id": "uuid-plataforma-1",
    "nome": "Airbnb",
    "ativo": true,
    "criado_em": "2025-12-29T00:00:00Z"
  },
  {
    "id": "uuid-plataforma-2",
    "nome": "Booking",
    "ativo": true,
    "criado_em": "2025-12-29T00:00:00Z"
  }
]
```

---

## 4. Imóveis

### GET /imoveis

Lista imóveis do usuário autenticado.

**Query Params:**
- `status=eq.ativo` - Filtrar por status
- `order=criado_em.desc` - Ordenação
- `limit=50` - Limite de resultados

**Response:**
```json
[
  {
    "id": "uuid-imovel-1",
    "usuario_id": "uuid-usuario",
    "nome": "Apartamento Centro",
    "status": "ativo",
    "criado_em": "2025-12-29T10:00:00Z",
    "atualizado_em": "2025-12-29T10:00:00Z"
  }
]
```

**Exemplo com filtro:**
```http
GET /imoveis?status=eq.ativo&order=criado_em.desc
```

---

### POST /imoveis

Cria novo imóvel (valida limite do plano no frontend).

**Request Body:**
```json
{
  "nome": "Casa Praia"
}
```

**Response (201):**
```json
{
  "id": "uuid-novo-imovel",
  "usuario_id": "uuid-usuario",
  "nome": "Casa Praia",
  "status": "ativo",
  "criado_em": "2025-12-29T10:15:00Z",
  "atualizado_em": "2025-12-29T10:15:00Z"
}
```

**Error (limite excedido - deve ser validado antes):**
```json
{
  "code": "PGRST116",
  "details": null,
  "hint": null,
  "message": "Limite de imóveis atingido"
}
```

---

### PATCH /imoveis

Atualiza imóvel existente.

**Query Param:**
```
?id=eq.uuid-do-imovel
```

**Request Body:**
```json
{
  "nome": "Casa Praia - Atualizada",
  "status": "inativo"
}
```

**Response (200):**
```json
{
  "id": "uuid-do-imovel",
  "nome": "Casa Praia - Atualizada",
  "status": "inativo",
  "atualizado_em": "2025-12-29T10:20:00Z"
}
```

---

### DELETE /imoveis

Exclui imóvel (soft delete via PATCH recomendado).

**Query Param:**
```
?id=eq.uuid-do-imovel
```

**Response (204):**
```
No Content
```

---

## 5. Categorias de Despesa

### GET /categorias_despesa

Lista categorias do usuário autenticado.

**Query Params:**
- `status=eq.ativo` - Apenas ativas
- `order=nome.asc` - Ordenar por nome

**Response:**
```json
[
  {
    "id": "uuid-categoria-1",
    "usuario_id": "uuid-usuario",
    "nome": "Limpeza",
    "status": "ativo",
    "criado_em": "2025-12-29T10:00:00Z",
    "atualizado_em": "2025-12-29T10:00:00Z"
  },
  {
    "id": "uuid-categoria-2",
    "usuario_id": "uuid-usuario",
    "nome": "Manutenção",
    "status": "ativo",
    "criado_em": "2025-12-29T10:00:00Z",
    "atualizado_em": "2025-12-29T10:00:00Z"
  }
]
```

---

### POST /categorias_despesa

Cria nova categoria.

**Request Body:**
```json
{
  "nome": "Material de Limpeza"
}
```

**Response (201):**
```json
{
  "id": "uuid-nova-categoria",
  "usuario_id": "uuid-usuario",
  "nome": "Material de Limpeza",
  "status": "ativo",
  "criado_em": "2025-12-29T10:25:00Z",
  "atualizado_em": "2025-12-29T10:25:00Z"
}
```

**Error (nome duplicado):**
```json
{
  "code": "23505",
  "details": "Key (usuario_id, nome)=(uuid, Nome) already exists.",
  "message": "duplicate key value violates unique constraint"
}
```

---

### PATCH /categorias_despesa

Atualiza ou desativa categoria.

**Query Param:**
```
?id=eq.uuid-da-categoria
```

**Request Body:**
```json
{
  "status": "inativo"
}
```

**Response (200):**
```json
{
  "id": "uuid-da-categoria",
  "nome": "Material de Limpeza",
  "status": "inativo",
  "atualizado_em": "2025-12-29T10:30:00Z"
}
```

---

## 6. Receitas

### GET /receitas

Lista receitas do usuário autenticado.

**Query Params:**
- `imovel_id=eq.uuid` - Filtrar por imóvel
- `plataforma_id=eq.uuid` - Filtrar por plataforma
- `data_recebimento=gte.2025-01-01` - Filtrar por data (>=)
- `data_recebimento=lte.2025-12-31` - Filtrar por data (<=)
- `order=data_recebimento.desc` - Ordenação
- `limit=50&offset=0` - Paginação

**Response:**
```json
[
  {
    "id": "uuid-receita-1",
    "usuario_id": "uuid-usuario",
    "imovel_id": "uuid-imovel",
    "plataforma_id": "uuid-plataforma",
    "data_recebimento": "2025-12-15",
    "valor": 1500.00,
    "observacao": "Reserva de 5 dias",
    "criado_em": "2025-12-29T10:00:00Z",
    "atualizado_em": "2025-12-29T10:00:00Z",
    "imoveis": {
      "nome": "Apartamento Centro"
    },
    "plataformas": {
      "nome": "Airbnb"
    }
  }
]
```

**Exemplo com JOIN e filtros:**
```http
GET /receitas?select=*,imoveis(nome),plataformas(nome)&data_recebimento=gte.2025-12-01&data_recebimento=lte.2025-12-31&order=data_recebimento.desc
```

---

### POST /receitas

Cria nova receita.

**Request Body:**
```json
{
  "imovel_id": "uuid-imovel",
  "plataforma_id": "uuid-plataforma",
  "data_recebimento": "2025-12-29",
  "valor": 2000.50,
  "observacao": "Reserva de final de ano"
}
```

**Response (201):**
```json
{
  "id": "uuid-nova-receita",
  "usuario_id": "uuid-usuario",
  "imovel_id": "uuid-imovel",
  "plataforma_id": "uuid-plataforma",
  "data_recebimento": "2025-12-29",
  "valor": 2000.50,
  "observacao": "Reserva de final de ano",
  "criado_em": "2025-12-29T10:35:00Z",
  "atualizado_em": "2025-12-29T10:35:00Z"
}
```

**Validações:**
- `valor` deve ser > 0
- `data_recebimento` não pode ser no futuro (validar no frontend)
- `imovel_id` deve pertencer ao usuário e estar ativo

---

### PATCH /receitas

Atualiza receita existente.

**Query Param:**
```
?id=eq.uuid-da-receita
```

**Request Body:**
```json
{
  "valor": 2100.00,
  "observacao": "Valor corrigido"
}
```

**Response (200):**
```json
{
  "id": "uuid-da-receita",
  "valor": 2100.00,
  "observacao": "Valor corrigido",
  "atualizado_em": "2025-12-29T10:40:00Z"
}
```

---

### DELETE /receitas

Exclui receita permanentemente.

**Query Param:**
```
?id=eq.uuid-da-receita
```

**Response (204):**
```
No Content
```

---

## 7. Despesas

### GET /despesas

Lista despesas do usuário autenticado.

**Query Params:**
- `imovel_id=eq.uuid` - Filtrar por imóvel
- `categoria_id=eq.uuid` - Filtrar por categoria
- `tipo=eq.fixa` - Filtrar por tipo (fixa/variavel)
- `data_pagamento=gte.2025-01-01` - Filtrar por data
- `recorrente=eq.true` - Apenas recorrentes
- `order=data_pagamento.desc` - Ordenação

**Response:**
```json
[
  {
    "id": "uuid-despesa-1",
    "usuario_id": "uuid-usuario",
    "imovel_id": "uuid-imovel",
    "categoria_id": "uuid-categoria",
    "data_pagamento": "2025-12-10",
    "valor": 350.00,
    "tipo": "fixa",
    "recorrente": true,
    "observacao": "Condomínio mensal",
    "criado_em": "2025-12-29T10:00:00Z",
    "atualizado_em": "2025-12-29T10:00:00Z",
    "imoveis": {
      "nome": "Apartamento Centro"
    },
    "categorias_despesa": {
      "nome": "Condomínio"
    }
  }
]
```

**Exemplo com JOIN e filtros:**
```http
GET /despesas?select=*,imoveis(nome),categorias_despesa(nome)&tipo=eq.fixa&order=valor.desc
```

---

### POST /despesas

Cria nova despesa.

**Request Body:**
```json
{
  "imovel_id": "uuid-imovel",
  "categoria_id": "uuid-categoria",
  "data_pagamento": "2025-12-29",
  "valor": 150.00,
  "tipo": "variavel",
  "recorrente": false,
  "observacao": "Reparo de fechadura"
}
```

**Response (201):**
```json
{
  "id": "uuid-nova-despesa",
  "usuario_id": "uuid-usuario",
  "imovel_id": "uuid-imovel",
  "categoria_id": "uuid-categoria",
  "data_pagamento": "2025-12-29",
  "valor": 150.00,
  "tipo": "variavel",
  "recorrente": false,
  "observacao": "Reparo de fechadura",
  "criado_em": "2025-12-29T10:45:00Z",
  "atualizado_em": "2025-12-29T10:45:00Z"
}
```

**Validações:**
- `valor` deve ser > 0
- `tipo` deve ser 'fixa' ou 'variavel'
- `categoria_id` deve estar ativa e pertencer ao usuário

---

### PATCH /despesas

Atualiza despesa existente.

**Query Param:**
```
?id=eq.uuid-da-despesa
```

**Request Body:**
```json
{
  "valor": 175.00
}
```

**Response (200):**
```json
{
  "id": "uuid-da-despesa",
  "valor": 175.00,
  "atualizado_em": "2025-12-29T10:50:00Z"
}
```

---

### DELETE /despesas

Exclui despesa permanentemente.

**Query Param:**
```
?id=eq.uuid-da-despesa
```

**Response (204):**
```
No Content
```

---

## Funções RPC (Remote Procedure Calls)

Base URL: `https://[PROJECT_ID].supabase.co/rest/v1/rpc`

### Headers

```http
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [JWT_TOKEN]
Content-Type: application/json
```

---

### 1. validar_limite_imoveis

**POST** `/rpc/validar_limite_imoveis`

Valida se o usuário pode adicionar mais imóveis conforme seu plano.

**Request Body:**
```json
{}
```

**Response (200):**
```json
true
```

ou

```json
false
```

**Exemplo de uso:**
```typescript
const { data, error } = await supabase.rpc('validar_limite_imoveis')
if (!data) {
  alert('Limite de imóveis atingido. Faça upgrade do plano.')
}
```

---

### 2. obter_dashboard_mensal

**POST** `/rpc/obter_dashboard_mensal`

Retorna dados agregados para o dashboard mensal.

**Request Body:**
```json
{
  "mes": 12,
  "ano": 2025,
  "imovel_uuid": null
}
```

**Parâmetros:**
- `mes` (integer, obrigatório): 1-12
- `ano` (integer, obrigatório): ex: 2025
- `imovel_uuid` (uuid, opcional): filtrar por imóvel específico

**Response (200):**
```json
{
  "receita_total": 4500.00,
  "despesa_total": 1200.50,
  "lucro_liquido": 3299.50,
  "margem": 73.32
}
```

**Exemplo de uso:**
```typescript
const { data } = await supabase.rpc('obter_dashboard_mensal', {
  mes: 12,
  ano: 2025,
  imovel_uuid: null // ou 'uuid-do-imovel'
})
```

---

### 3. criar_categorias_iniciais

**POST** `/rpc/criar_categorias_iniciais`

Cria categorias de despesa sugeridas para o usuário (executar após signup).

**Request Body:**
```json
{}
```

**Response (200):**
```json
null
```

**Categorias criadas:**
- Limpeza
- Manutenção
- Condomínio
- IPTU
- Internet
- Energia
- Água
- Gás
- Móveis e Equipamentos
- Taxas e Impostos

---

### 4. obter_resultado_por_imovel

**POST** `/rpc/obter_resultado_por_imovel`

Retorna resultado financeiro de cada imóvel no período.

**Request Body:**
```json
{
  "mes": 12,
  "ano": 2025
}
```

**Response (200):**
```json
[
  {
    "imovel_id": "uuid-imovel-1",
    "imovel_nome": "Apartamento Centro",
    "receita_total": 3000.00,
    "despesa_total": 800.00,
    "lucro_liquido": 2200.00,
    "margem": 73.33
  },
  {
    "imovel_id": "uuid-imovel-2",
    "imovel_nome": "Casa Praia",
    "receita_total": 5500.00,
    "despesa_total": 1500.00,
    "lucro_liquido": 4000.00,
    "margem": 72.73
  }
]
```

---

### 5. obter_receita_por_plataforma

**POST** `/rpc/obter_receita_por_plataforma`

Retorna distribuição de receitas por plataforma no período.

**Request Body:**
```json
{
  "mes": 12,
  "ano": 2025,
  "imovel_uuid": null
}
```

**Response (200):**
```json
[
  {
    "plataforma_nome": "Airbnb",
    "total": 6500.00,
    "percentual": 65.00
  },
  {
    "plataforma_nome": "Booking",
    "total": 2500.00,
    "percentual": 25.00
  },
  {
    "plataforma_nome": "Direto",
    "total": 1000.00,
    "percentual": 10.00
  }
]
```

---

### 6. obter_top_despesas

**POST** `/rpc/obter_top_despesas`

Retorna ranking de categorias de despesa por valor.

**Request Body:**
```json
{
  "mes": 12,
  "ano": 2025,
  "imovel_uuid": null,
  "limite_registros": 10
}
```

**Response (200):**
```json
[
  {
    "categoria_nome": "Limpeza",
    "total": 800.00,
    "quantidade": 4
  },
  {
    "categoria_nome": "Condomínio",
    "total": 700.00,
    "quantidade": 2
  },
  {
    "categoria_nome": "Manutenção",
    "total": 450.00,
    "quantidade": 3
  }
]
```

---

## Códigos de Status HTTP

### Sucesso

- **200 OK** - Requisição bem-sucedida (GET, PATCH)
- **201 Created** - Recurso criado com sucesso (POST)
- **204 No Content** - Recurso excluído ou ação sem retorno (DELETE, logout)

### Erros do Cliente

- **400 Bad Request** - Requisição inválida (dados malformados)
- **401 Unauthorized** - Token ausente ou inválido
- **403 Forbidden** - Acesso negado (RLS bloqueou)
- **404 Not Found** - Recurso não encontrado
- **409 Conflict** - Conflito (ex: duplicação de dados únicos)
- **422 Unprocessable Entity** - Validação de dados falhou

### Erros do Servidor

- **500 Internal Server Error** - Erro interno do servidor
- **503 Service Unavailable** - Serviço temporariamente indisponível

---

## Tratamento de Erros

### Formato de Erro Padrão

```json
{
  "code": "PGRST116",
  "details": "Detailed error information",
  "hint": "Suggestion to fix the error",
  "message": "Human readable error message"
}
```

### Erros Comuns

#### Token Inválido ou Expirado

```json
{
  "code": "401",
  "message": "JWT expired"
}
```

**Solução:** Renovar token via refresh token ou fazer login novamente.

#### RLS Policy Violation

```json
{
  "code": "42501",
  "message": "new row violates row-level security policy"
}
```

**Solução:** Usuário tentou acessar dados que não pertencem a ele. Verificar lógica de RLS.

#### Constraint Violation

```json
{
  "code": "23505",
  "details": "Key (usuario_id, nome)=(uuid, 'Limpeza') already exists.",
  "message": "duplicate key value violates unique constraint"
}
```

**Solução:** Nome de categoria já existe para esse usuário.

---

## Rate Limiting

Supabase aplica rate limiting baseado no plano:

- **Free Tier**: 500 requisições/segundo
- **Pro**: 1000+ requisições/segundo

### Headers de Rate Limit

```http
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 499
X-RateLimit-Reset: 1609459200
```

---

## Paginação

### Query Params

```http
GET /receitas?limit=50&offset=0
```

- `limit` - Número de registros (máx: 1000)
- `offset` - Deslocamento (para página 2: offset=50)

### Headers de Resposta

```http
Content-Range: 0-49/150
```

Indica: registros 0-49 de um total de 150.

---

## Filtros Avançados (PostgREST)

### Operadores

- `eq` - Igual: `?status=eq.ativo`
- `neq` - Diferente: `?status=neq.inativo`
- `gt` - Maior que: `?valor=gt.100`
- `gte` - Maior ou igual: `?valor=gte.100`
- `lt` - Menor que: `?valor=lt.1000`
- `lte` - Menor ou igual: `?valor=lte.1000`
- `like` - Like: `?nome=like.*Centro*`
- `ilike` - Like case-insensitive: `?nome=ilike.*centro*`
- `in` - In: `?status=in.(ativo,inativo)`
- `is` - Is null: `?observacao=is.null`

### Exemplos

```http
# Receitas de dezembro de 2025
GET /receitas?data_recebimento=gte.2025-12-01&data_recebimento=lte.2025-12-31

# Despesas fixas acima de R$ 500
GET /despesas?tipo=eq.fixa&valor=gt.500

# Imóveis com nome contendo "Apartamento"
GET /imoveis?nome=ilike.*Apartamento*

# Receitas de múltiplas plataformas
GET /receitas?plataforma_id=in.(uuid1,uuid2,uuid3)
```

---

## Agregações e Contagem

### Contagem Total

```http
GET /receitas?select=count
Prefer: count=exact
```

**Response:**
```json
[
  {
    "count": 45
  }
]
```

### Soma de Valores

```http
GET /receitas?select=valor.sum()&data_recebimento=gte.2025-12-01
```

**Response:**
```json
[
  {
    "sum": 12500.50
  }
]
```

---

## Boas Práticas

### 1. Sempre Use Paginação

```typescript
// ✅ Bom
const { data } = await supabase
  .from('receitas')
  .select('*')
  .range(0, 49)

// ❌ Evitar (pode retornar milhares de registros)
const { data } = await supabase
  .from('receitas')
  .select('*')
```

### 2. Selecione Apenas Campos Necessários

```typescript
// ✅ Bom
const { data } = await supabase
  .from('receitas')
  .select('id, valor, data_recebimento')

// ❌ Evitar (pode trazer dados desnecessários)
const { data } = await supabase
  .from('receitas')
  .select('*')
```

### 3. Use JOINs para Reduzir Requisições

```typescript
// ✅ Bom (1 requisição)
const { data } = await supabase
  .from('receitas')
  .select('*, imoveis(nome), plataformas(nome)')

// ❌ Evitar (múltiplas requisições)
const receitas = await supabase.from('receitas').select('*')
const imoveis = await supabase.from('imoveis').select('*')
```

### 4. Valide Dados no Frontend

```typescript
// Validar antes de enviar
if (valor <= 0) {
  throw new Error('Valor deve ser maior que zero')
}

if (new Date(data) > new Date()) {
  throw new Error('Data não pode ser no futuro')
}
```

### 5. Trate Erros Adequadamente

```typescript
try {
  const { data, error } = await supabase
    .from('imoveis')
    .insert({ nome })
  
  if (error) throw error
  
  return data
} catch (error) {
  if (error.code === '23505') {
    // Duplicação
    toast.error('Nome já existe')
  } else if (error.code === '42501') {
    // RLS violation
    toast.error('Você não tem permissão')
  } else {
    toast.error('Erro ao salvar')
  }
}
```

---

## Exemplo de Implementação Completa

### Composable: useReceitas.ts

```typescript
import type { Database } from '~/types/database.types'

type Receita = Database['public']['Tables']['receitas']['Row']
type ReceitaInsert = Database['public']['Tables']['receitas']['Insert']
type ReceitaUpdate = Database['public']['Tables']['receitas']['Update']

export const useReceitas = () => {
  const supabase = useSupabaseClient<Database>()
  
  const listar = async (filtros?: {
    imovelId?: string
    plataformaId?: string
    dataInicio?: string
    dataFim?: string
    limit?: number
    offset?: number
  }) => {
    let query = supabase
      .from('receitas')
      .select('*, imoveis(nome), plataformas(nome)', { count: 'exact' })
      .order('data_recebimento', { ascending: false })
    
    if (filtros?.imovelId) {
      query = query.eq('imovel_id', filtros.imovelId)
    }
    
    if (filtros?.plataformaId) {
      query = query.eq('plataforma_id', filtros.plataformaId)
    }
    
    if (filtros?.dataInicio) {
      query = query.gte('data_recebimento', filtros.dataInicio)
    }
    
    if (filtros?.dataFim) {
      query = query.lte('data_recebimento', filtros.dataFim)
    }
    
    if (filtros?.limit) {
      query = query.range(
        filtros.offset || 0,
        (filtros.offset || 0) + filtros.limit - 1
      )
    }
    
    const { data, error, count } = await query
    
    if (error) throw error
    
    return { data, count }
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
  
  const atualizar = async (id: string, receita: ReceitaUpdate) => {
    const { data, error } = await supabase
      .from('receitas')
      .update(receita)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return data
  }
  
  const excluir = async (id: string) => {
    const { error } = await supabase
      .from('receitas')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }
  
  const obterTotal = async (mes: number, ano: number, imovelId?: string) => {
    let query = supabase
      .from('receitas')
      .select('valor.sum()')
    
    query = query
      .gte('data_recebimento', `${ano}-${mes.toString().padStart(2, '0')}-01`)
      .lt('data_recebimento', `${ano}-${(mes + 1).toString().padStart(2, '0')}-01`)
    
    if (imovelId) {
      query = query.eq('imovel_id', imovelId)
    }
    
    const { data, error } = await query.single()
    
    if (error) throw error
    return data.sum || 0
  }
  
  return {
    listar,
    criar,
    atualizar,
    excluir,
    obterTotal
  }
}
```

---

## Referências

- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript)
- [PostgREST API](https://postgrest.org/en/stable/api.html)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
