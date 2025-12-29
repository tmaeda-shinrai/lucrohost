-- ============================================================================
-- LUCROHOST - Script de Criação do Banco de Dados Supabase
-- ============================================================================
-- Descrição: Script completo para setup do banco de dados PostgreSQL no Supabase
-- Inclui: tabelas, indexes, RLS policies, funções RPC, triggers e seed data
-- Versão: 1.0
-- Data: 2025-12-29
-- ============================================================================

-- ============================================================================
-- 1. CRIAÇÃO DAS TABELAS
-- ============================================================================

-- 1.1 Tabela: planos
-- Descrição: Planos de assinatura disponíveis (seed data, read-only para usuários)
-- ============================================================================
CREATE TABLE IF NOT EXISTS planos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(50) NOT NULL UNIQUE,
  limite_imoveis INTEGER NOT NULL,
  preco_mensal DECIMAL(10, 2) DEFAULT 0.00,
  descricao TEXT,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE planos IS 'Planos de assinatura disponíveis no sistema';
COMMENT ON COLUMN planos.nome IS 'Nome do plano: Essencial, Anfitrião ou Pro';
COMMENT ON COLUMN planos.limite_imoveis IS 'Quantidade máxima de imóveis permitida no plano';

-- 1.2 Tabela: usuarios
-- Descrição: Perfil do usuário (complementa auth.users do Supabase)
-- ============================================================================
CREATE TABLE IF NOT EXISTS usuarios (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  plano_id UUID REFERENCES planos(id) NOT NULL,
  nome VARCHAR(100),
  email VARCHAR(255) NOT NULL UNIQUE,
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE usuarios IS 'Perfil dos usuários da aplicação';
COMMENT ON COLUMN usuarios.id IS 'UUID do usuário (referencia auth.users)';
COMMENT ON COLUMN usuarios.plano_id IS 'Plano atual do usuário';

-- 1.3 Tabela: plataformas
-- Descrição: Plataformas de hospedagem (seed data, read-only para usuários)
-- ============================================================================
CREATE TABLE IF NOT EXISTS plataformas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR(50) NOT NULL UNIQUE,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE plataformas IS 'Plataformas de hospedagem disponíveis (Airbnb, Booking, etc)';

-- 1.4 Tabela: imoveis
-- Descrição: Imóveis cadastrados pelos usuários
-- ============================================================================
CREATE TABLE IF NOT EXISTS imoveis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  nome VARCHAR(100) NOT NULL,
  status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE imoveis IS 'Imóveis cadastrados pelos usuários';
COMMENT ON COLUMN imoveis.status IS 'Status do imóvel: ativo ou inativo (soft delete)';

-- 1.5 Tabela: categorias_despesa
-- Descrição: Categorias de despesas personalizadas por usuário
-- ============================================================================
CREATE TABLE IF NOT EXISTS categorias_despesa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  nome VARCHAR(50) NOT NULL,
  status VARCHAR(20) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo')),
  criado_em TIMESTAMPTZ DEFAULT NOW(),
  atualizado_em TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_categoria_por_usuario UNIQUE(usuario_id, nome)
);

COMMENT ON TABLE categorias_despesa IS 'Categorias de despesas personalizadas por usuário';
COMMENT ON CONSTRAINT unique_categoria_por_usuario ON categorias_despesa IS 'Garante nome único de categoria por usuário';

-- 1.6 Tabela: receitas
-- Descrição: Receitas/ganhos dos imóveis
-- ============================================================================
CREATE TABLE IF NOT EXISTS receitas (
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

COMMENT ON TABLE receitas IS 'Receitas/ganhos dos imóveis dos usuários';
COMMENT ON COLUMN receitas.data_recebimento IS 'Data em que a receita foi recebida';
COMMENT ON COLUMN receitas.valor IS 'Valor da receita (deve ser maior que zero)';

-- 1.7 Tabela: despesas
-- Descrição: Despesas dos imóveis
-- ============================================================================
CREATE TABLE IF NOT EXISTS despesas (
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

COMMENT ON TABLE despesas IS 'Despesas dos imóveis dos usuários';
COMMENT ON COLUMN despesas.tipo IS 'Tipo da despesa: fixa ou variável';
COMMENT ON COLUMN despesas.recorrente IS 'Indica se é uma despesa recorrente (apenas indicador no MVP)';

-- ============================================================================
-- 2. CRIAÇÃO DE INDEXES
-- ============================================================================

-- Indexes para tabela usuarios
CREATE INDEX IF NOT EXISTS idx_usuarios_plano ON usuarios(plano_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);

-- Indexes para tabela imoveis
CREATE INDEX IF NOT EXISTS idx_imoveis_usuario ON imoveis(usuario_id);
CREATE INDEX IF NOT EXISTS idx_imoveis_status ON imoveis(status);
CREATE INDEX IF NOT EXISTS idx_imoveis_usuario_status ON imoveis(usuario_id, status);

-- Indexes para tabela categorias_despesa
CREATE INDEX IF NOT EXISTS idx_categorias_usuario ON categorias_despesa(usuario_id);
CREATE INDEX IF NOT EXISTS idx_categorias_status ON categorias_despesa(status);
CREATE INDEX IF NOT EXISTS idx_categorias_usuario_status ON categorias_despesa(usuario_id, status);

-- Indexes para tabela receitas
CREATE INDEX IF NOT EXISTS idx_receitas_usuario ON receitas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_receitas_imovel ON receitas(imovel_id);
CREATE INDEX IF NOT EXISTS idx_receitas_plataforma ON receitas(plataforma_id);
CREATE INDEX IF NOT EXISTS idx_receitas_data ON receitas(data_recebimento DESC);
CREATE INDEX IF NOT EXISTS idx_receitas_usuario_data ON receitas(usuario_id, data_recebimento DESC);

-- Indexes para tabela despesas
CREATE INDEX IF NOT EXISTS idx_despesas_usuario ON despesas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_despesas_imovel ON despesas(imovel_id);
CREATE INDEX IF NOT EXISTS idx_despesas_categoria ON despesas(categoria_id);
CREATE INDEX IF NOT EXISTS idx_despesas_data ON despesas(data_pagamento DESC);
CREATE INDEX IF NOT EXISTS idx_despesas_tipo ON despesas(tipo);
CREATE INDEX IF NOT EXISTS idx_despesas_usuario_data ON despesas(usuario_id, data_pagamento DESC);

-- ============================================================================
-- 3. FUNÇÕES RPC (Remote Procedure Calls)
-- ============================================================================

-- 3.1 Função: validar_limite_imoveis
-- Descrição: Valida se o usuário pode adicionar mais imóveis conforme seu plano
-- ============================================================================
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
  
  -- Se não encontrou o usuário, retorna false
  IF limite IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Conta imóveis ativos do usuário
  SELECT COUNT(*) INTO contagem
  FROM imoveis
  WHERE usuario_id = auth.uid() AND status = 'ativo';
  
  -- Retorna se ainda pode adicionar
  RETURN contagem < limite;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION validar_limite_imoveis IS 'Valida se usuário pode adicionar mais imóveis conforme limite do plano';

-- 3.2 Função: obter_dashboard_mensal
-- Descrição: Retorna dados agregados para o dashboard mensal
-- ============================================================================
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

COMMENT ON FUNCTION obter_dashboard_mensal IS 'Retorna dados agregados do dashboard mensal (receitas, despesas, lucro, margem)';

-- 3.3 Função: criar_categorias_iniciais
-- Descrição: Cria categorias sugeridas para novo usuário
-- ============================================================================
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
  ON CONFLICT (usuario_id, nome) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION criar_categorias_iniciais IS 'Cria categorias de despesa sugeridas para novo usuário';

-- 3.4 Função: obter_resultado_por_imovel
-- Descrição: Retorna resultado financeiro de cada imóvel no período
-- ============================================================================
CREATE OR REPLACE FUNCTION obter_resultado_por_imovel(
  mes INTEGER,
  ano INTEGER
)
RETURNS TABLE(
  imovel_id UUID,
  imovel_nome VARCHAR(100),
  receita_total DECIMAL(10, 2),
  despesa_total DECIMAL(10, 2),
  lucro_liquido DECIMAL(10, 2),
  margem DECIMAL(5, 2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    i.id AS imovel_id,
    i.nome AS imovel_nome,
    COALESCE(SUM(r.valor), 0) AS receita_total,
    COALESCE(SUM(d.valor), 0) AS despesa_total,
    COALESCE(SUM(r.valor), 0) - COALESCE(SUM(d.valor), 0) AS lucro_liquido,
    CASE 
      WHEN COALESCE(SUM(r.valor), 0) > 0 
      THEN ((COALESCE(SUM(r.valor), 0) - COALESCE(SUM(d.valor), 0)) / COALESCE(SUM(r.valor), 0)) * 100
      ELSE 0
    END AS margem
  FROM imoveis i
  LEFT JOIN receitas r ON r.imovel_id = i.id 
    AND EXTRACT(MONTH FROM r.data_recebimento) = mes
    AND EXTRACT(YEAR FROM r.data_recebimento) = ano
  LEFT JOIN despesas d ON d.imovel_id = i.id
    AND EXTRACT(MONTH FROM d.data_pagamento) = mes
    AND EXTRACT(YEAR FROM d.data_pagamento) = ano
  WHERE i.usuario_id = auth.uid()
    AND i.status = 'ativo'
  GROUP BY i.id, i.nome
  ORDER BY lucro_liquido DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION obter_resultado_por_imovel IS 'Retorna resultado financeiro detalhado de cada imóvel no período';

-- 3.5 Função: obter_receita_por_plataforma
-- Descrição: Retorna distribuição de receitas por plataforma
-- ============================================================================
CREATE OR REPLACE FUNCTION obter_receita_por_plataforma(
  mes INTEGER,
  ano INTEGER,
  imovel_uuid UUID DEFAULT NULL
)
RETURNS TABLE(
  plataforma_nome VARCHAR(50),
  total DECIMAL(10, 2),
  percentual DECIMAL(5, 2)
) AS $$
DECLARE
  total_geral DECIMAL(10, 2);
BEGIN
  -- Calcula total geral
  SELECT COALESCE(SUM(valor), 0) INTO total_geral
  FROM receitas
  WHERE usuario_id = auth.uid()
    AND EXTRACT(MONTH FROM data_recebimento) = mes
    AND EXTRACT(YEAR FROM data_recebimento) = ano
    AND (imovel_uuid IS NULL OR imovel_id = imovel_uuid);
  
  -- Retorna distribuição por plataforma
  RETURN QUERY
  SELECT 
    p.nome AS plataforma_nome,
    COALESCE(SUM(r.valor), 0) AS total,
    CASE 
      WHEN total_geral > 0 THEN (COALESCE(SUM(r.valor), 0) / total_geral) * 100
      ELSE 0
    END AS percentual
  FROM plataformas p
  LEFT JOIN receitas r ON r.plataforma_id = p.id
    AND r.usuario_id = auth.uid()
    AND EXTRACT(MONTH FROM r.data_recebimento) = mes
    AND EXTRACT(YEAR FROM r.data_recebimento) = ano
    AND (imovel_uuid IS NULL OR r.imovel_id = imovel_uuid)
  WHERE p.ativo = TRUE
  GROUP BY p.nome
  HAVING COALESCE(SUM(r.valor), 0) > 0
  ORDER BY total DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION obter_receita_por_plataforma IS 'Retorna distribuição de receitas por plataforma no período';

-- 3.6 Função: obter_top_despesas
-- Descrição: Retorna ranking de categorias de despesa por valor
-- ============================================================================
CREATE OR REPLACE FUNCTION obter_top_despesas(
  mes INTEGER,
  ano INTEGER,
  imovel_uuid UUID DEFAULT NULL,
  limite_registros INTEGER DEFAULT 10
)
RETURNS TABLE(
  categoria_nome VARCHAR(50),
  total DECIMAL(10, 2),
  quantidade INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.nome AS categoria_nome,
    COALESCE(SUM(d.valor), 0) AS total,
    COUNT(d.id)::INTEGER AS quantidade
  FROM categorias_despesa c
  LEFT JOIN despesas d ON d.categoria_id = c.id
    AND d.usuario_id = auth.uid()
    AND EXTRACT(MONTH FROM d.data_pagamento) = mes
    AND EXTRACT(YEAR FROM d.data_pagamento) = ano
    AND (imovel_uuid IS NULL OR d.imovel_id = imovel_uuid)
  WHERE c.usuario_id = auth.uid()
    AND c.status = 'ativo'
  GROUP BY c.nome
  HAVING COALESCE(SUM(d.valor), 0) > 0
  ORDER BY total DESC
  LIMIT limite_registros;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION obter_top_despesas IS 'Retorna ranking das maiores categorias de despesa no período';

-- ============================================================================
-- 4. TRIGGERS E FUNÇÕES DE TRIGGER
-- ============================================================================

-- 4.1 Função: handle_new_user
-- Descrição: Função para criar perfil do usuário (chamada via Database Webhook)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  plano_essencial_id UUID;
BEGIN
  -- Busca ID do plano Essencial
  SELECT id INTO plano_essencial_id
  FROM public.planos
  WHERE nome = 'Essencial'
  LIMIT 1;
  
  -- Cria perfil do usuário com plano Essencial
  INSERT INTO public.usuarios (id, plano_id, email)
  VALUES (NEW.id, plano_essencial_id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION public.handle_new_user IS 'Função para criar perfil automaticamente quando usuário é criado';

-- ============================================================================
-- IMPORTANTE: Configuração do Trigger para auth.users
-- ============================================================================
-- Como não podemos criar trigger diretamente em auth.users via SQL,
-- você precisa configurar isso de uma das seguintes formas:
--
-- OPÇÃO 1: Via Supabase Dashboard (RECOMENDADO)
-- 1. Acesse: Database > Database Webhooks
-- 2. Crie um novo webhook com:
--    - Table: auth.users
--    - Events: INSERT
--    - Type: pg_net webhook
--    - URL: (não necessário, use Database Function)
--    - Function: public.handle_new_user()
--
-- OPÇÃO 2: Via SQL no dashboard do Supabase (executar como postgres)
-- Se você tem acesso de superusuário, execute:
/*
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
*/
--
-- OPÇÃO 3: Via aplicação (fallback)
-- No frontend, após signup bem-sucedido, chame:
-- - supabase.from('usuarios').insert({ ... })
-- ============================================================================

-- 4.2 Função: atualizar_timestamp
-- Descrição: Atualiza automaticamente o campo atualizado_em
-- ============================================================================
CREATE OR REPLACE FUNCTION atualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.atualizado_em = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION atualizar_timestamp IS 'Atualiza automaticamente timestamp de atualização';

-- 4.3 Triggers para atualização automática de timestamp
-- ============================================================================
DROP TRIGGER IF EXISTS trigger_atualizar_usuarios ON usuarios;
CREATE TRIGGER trigger_atualizar_usuarios
  BEFORE UPDATE ON usuarios
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_timestamp();

DROP TRIGGER IF EXISTS trigger_atualizar_imoveis ON imoveis;
CREATE TRIGGER trigger_atualizar_imoveis
  BEFORE UPDATE ON imoveis
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_timestamp();

DROP TRIGGER IF EXISTS trigger_atualizar_categorias ON categorias_despesa;
CREATE TRIGGER trigger_atualizar_categorias
  BEFORE UPDATE ON categorias_despesa
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_timestamp();

DROP TRIGGER IF EXISTS trigger_atualizar_receitas ON receitas;
CREATE TRIGGER trigger_atualizar_receitas
  BEFORE UPDATE ON receitas
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_timestamp();

DROP TRIGGER IF EXISTS trigger_atualizar_despesas ON despesas;
CREATE TRIGGER trigger_atualizar_despesas
  BEFORE UPDATE ON despesas
  FOR EACH ROW
  EXECUTE FUNCTION atualizar_timestamp();

-- ============================================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- 5.1 Habilitar RLS em todas as tabelas
-- ============================================================================
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE planos ENABLE ROW LEVEL SECURITY;
ALTER TABLE plataformas ENABLE ROW LEVEL SECURITY;
ALTER TABLE imoveis ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias_despesa ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE despesas ENABLE ROW LEVEL SECURITY;

-- 5.2 Policies para tabela: usuarios
-- ============================================================================
DROP POLICY IF EXISTS "Usuários podem ver o próprio perfil" ON usuarios;
CREATE POLICY "Usuários podem ver o próprio perfil"
  ON usuarios FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Usuários podem atualizar o próprio perfil" ON usuarios;
CREATE POLICY "Usuários podem atualizar o próprio perfil"
  ON usuarios FOR UPDATE
  USING (auth.uid() = id);

-- 5.3 Policies para tabela: planos (read-only)
-- ============================================================================
DROP POLICY IF EXISTS "Usuários autenticados podem ver planos" ON planos;
CREATE POLICY "Usuários autenticados podem ver planos"
  ON planos FOR SELECT
  USING (auth.role() = 'authenticated');

-- 5.4 Policies para tabela: plataformas (read-only)
-- ============================================================================
DROP POLICY IF EXISTS "Usuários autenticados podem ver plataformas" ON plataformas;
CREATE POLICY "Usuários autenticados podem ver plataformas"
  ON plataformas FOR SELECT
  USING (auth.role() = 'authenticated');

-- 5.5 Policies para tabela: imoveis
-- ============================================================================
DROP POLICY IF EXISTS "Usuários veem apenas seus imóveis" ON imoveis;
CREATE POLICY "Usuários veem apenas seus imóveis"
  ON imoveis FOR SELECT
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem criar imóveis" ON imoveis;
CREATE POLICY "Usuários podem criar imóveis"
  ON imoveis FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus imóveis" ON imoveis;
CREATE POLICY "Usuários podem atualizar seus imóveis"
  ON imoveis FOR UPDATE
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem excluir seus imóveis" ON imoveis;
CREATE POLICY "Usuários podem excluir seus imóveis"
  ON imoveis FOR DELETE
  USING (auth.uid() = usuario_id);

-- 5.6 Policies para tabela: categorias_despesa
-- ============================================================================
DROP POLICY IF EXISTS "Usuários veem apenas suas categorias" ON categorias_despesa;
CREATE POLICY "Usuários veem apenas suas categorias"
  ON categorias_despesa FOR SELECT
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem criar categorias" ON categorias_despesa;
CREATE POLICY "Usuários podem criar categorias"
  ON categorias_despesa FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem atualizar suas categorias" ON categorias_despesa;
CREATE POLICY "Usuários podem atualizar suas categorias"
  ON categorias_despesa FOR UPDATE
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem excluir suas categorias" ON categorias_despesa;
CREATE POLICY "Usuários podem excluir suas categorias"
  ON categorias_despesa FOR DELETE
  USING (auth.uid() = usuario_id);

-- 5.7 Policies para tabela: receitas
-- ============================================================================
DROP POLICY IF EXISTS "Usuários veem apenas suas receitas" ON receitas;
CREATE POLICY "Usuários veem apenas suas receitas"
  ON receitas FOR SELECT
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem criar receitas" ON receitas;
CREATE POLICY "Usuários podem criar receitas"
  ON receitas FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem atualizar suas receitas" ON receitas;
CREATE POLICY "Usuários podem atualizar suas receitas"
  ON receitas FOR UPDATE
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem excluir suas receitas" ON receitas;
CREATE POLICY "Usuários podem excluir suas receitas"
  ON receitas FOR DELETE
  USING (auth.uid() = usuario_id);

-- 5.8 Policies para tabela: despesas
-- ============================================================================
DROP POLICY IF EXISTS "Usuários veem apenas suas despesas" ON despesas;
CREATE POLICY "Usuários veem apenas suas despesas"
  ON despesas FOR SELECT
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem criar despesas" ON despesas;
CREATE POLICY "Usuários podem criar despesas"
  ON despesas FOR INSERT
  WITH CHECK (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem atualizar suas despesas" ON despesas;
CREATE POLICY "Usuários podem atualizar suas despesas"
  ON despesas FOR UPDATE
  USING (auth.uid() = usuario_id);

DROP POLICY IF EXISTS "Usuários podem excluir suas despesas" ON despesas;
CREATE POLICY "Usuários podem excluir suas despesas"
  ON despesas FOR DELETE
  USING (auth.uid() = usuario_id);

-- ============================================================================
-- 6. SEED DATA (Dados Iniciais)
-- ============================================================================

-- 6.1 Inserir Planos
-- ============================================================================
INSERT INTO planos (nome, limite_imoveis, preco_mensal, descricao) VALUES
  ('Essencial', 1, 0.00, 'Controle completo para um imóvel'),
  ('Anfitrião', 3, 29.90, 'Plano foco do produto - até 3 imóveis'),
  ('Pro', 6, 59.90, 'Recursos de análise avançada - até 6 imóveis')
ON CONFLICT (nome) DO NOTHING;

-- 6.2 Inserir Plataformas
-- ============================================================================
INSERT INTO plataformas (nome) VALUES
  ('Airbnb'),
  ('Booking'),
  ('Direto'),
  ('Outro')
ON CONFLICT (nome) DO NOTHING;

-- ============================================================================
-- 7. GRANTS E PERMISSÕES
-- ============================================================================

-- Garantir que funções RPC estão acessíveis para authenticated users
GRANT EXECUTE ON FUNCTION validar_limite_imoveis() TO authenticated;
GRANT EXECUTE ON FUNCTION obter_dashboard_mensal(INTEGER, INTEGER, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION criar_categorias_iniciais() TO authenticated;
GRANT EXECUTE ON FUNCTION obter_resultado_por_imovel(INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION obter_receita_por_plataforma(INTEGER, INTEGER, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION obter_top_despesas(INTEGER, INTEGER, UUID, INTEGER) TO authenticated;

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================

-- Para verificar se tudo foi criado corretamente, execute:
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public';
-- SELECT proname FROM pg_proc WHERE pronamespace = 'public'::regnamespace;
