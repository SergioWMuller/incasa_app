-- ========================================
-- TABELA DE PRODUTOS - MARKETPLACE INCASA
-- ========================================
-- Esta tabela armazena os produtos/serviços que os vendedores cadastram em suas lojas

-- Criar a tabela de produtos
CREATE TABLE IF NOT EXISTS public.products (
    -- Identificação
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Tipo de item
    tipo TEXT NOT NULL CHECK (tipo IN ('produto', 'servico')),
    
    -- Informações básicas
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    image_url TEXT,
    category TEXT NOT NULL,
    
    -- Estoque e prazos (opcionais)
    estoque INTEGER CHECK (estoque >= 0),
    prazo_producao_dias INTEGER CHECK (prazo_producao_dias >= 0),
    prazo_entrega_horas INTEGER CHECK (prazo_entrega_horas >= 0),
    prazo_minimo_encomenda_dias INTEGER CHECK (prazo_minimo_encomenda_dias >= 0),
    
    -- Flags de disponibilidade
    disponivel_venda BOOLEAN NOT NULL DEFAULT true,
    pronta_entrega BOOLEAN NOT NULL DEFAULT true,
    aceita_encomenda BOOLEAN NOT NULL DEFAULT false,
    
    -- Auditoria
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================================
-- ÍNDICES
-- ========================================

-- Índice para buscar produtos por vendedor
CREATE INDEX IF NOT EXISTS idx_products_seller_id 
    ON public.products(seller_id);

-- Índice para buscar produtos por categoria
CREATE INDEX IF NOT EXISTS idx_products_category 
    ON public.products(category);

-- Índice para buscar produtos disponíveis
CREATE INDEX IF NOT EXISTS idx_products_disponivel_venda 
    ON public.products(disponivel_venda) 
    WHERE disponivel_venda = true;

-- Índice para buscar por tipo
CREATE INDEX IF NOT EXISTS idx_products_tipo 
    ON public.products(tipo);

-- Índice composto para buscar produtos disponíveis por categoria
CREATE INDEX IF NOT EXISTS idx_products_disponivel_categoria 
    ON public.products(disponivel_venda, category) 
    WHERE disponivel_venda = true;

-- Índice para ordenar por data de criação
CREATE INDEX IF NOT EXISTS idx_products_created_at 
    ON public.products(created_at DESC);

-- ========================================
-- TRIGGER PARA ATUALIZAR updated_at
-- ========================================

-- Função para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que chama a função antes de cada UPDATE
DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

-- Habilitar RLS na tabela
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Policy: Qualquer usuário autenticado pode visualizar produtos disponíveis
CREATE POLICY "Produtos disponíveis são públicos"
    ON public.products
    FOR SELECT
    USING (disponivel_venda = true);

-- Policy: Vendedores podem visualizar todos os seus produtos (disponíveis ou não)
CREATE POLICY "Vendedores podem ver seus próprios produtos"
    ON public.products
    FOR SELECT
    USING (auth.uid() = seller_id);

-- Policy: Vendedores podem inserir produtos
CREATE POLICY "Vendedores podem criar produtos"
    ON public.products
    FOR INSERT
    WITH CHECK (auth.uid() = seller_id);

-- Policy: Vendedores podem atualizar apenas seus produtos
CREATE POLICY "Vendedores podem atualizar seus produtos"
    ON public.products
    FOR UPDATE
    USING (auth.uid() = seller_id)
    WITH CHECK (auth.uid() = seller_id);

-- Policy: Vendedores podem deletar apenas seus produtos
CREATE POLICY "Vendedores podem deletar seus produtos"
    ON public.products
    FOR DELETE
    USING (auth.uid() = seller_id);

-- ========================================
-- COMENTÁRIOS NA TABELA
-- ========================================

COMMENT ON TABLE public.products IS 'Armazena produtos e serviços cadastrados pelos vendedores no marketplace';
COMMENT ON COLUMN public.products.id IS 'Identificador único do produto';
COMMENT ON COLUMN public.products.seller_id IS 'ID do vendedor (dono da loja)';
COMMENT ON COLUMN public.products.tipo IS 'Tipo do item: produto ou servico';
COMMENT ON COLUMN public.products.name IS 'Nome do produto/serviço';
COMMENT ON COLUMN public.products.description IS 'Descrição detalhada';
COMMENT ON COLUMN public.products.price IS 'Preço em reais';
COMMENT ON COLUMN public.products.image_url IS 'URL da imagem principal do produto';
COMMENT ON COLUMN public.products.category IS 'Categoria do produto';
COMMENT ON COLUMN public.products.estoque IS 'Quantidade em estoque (opcional)';
COMMENT ON COLUMN public.products.prazo_producao_dias IS 'Prazo de produção em dias (opcional)';
COMMENT ON COLUMN public.products.prazo_entrega_horas IS 'Prazo de entrega em horas (opcional)';
COMMENT ON COLUMN public.products.prazo_minimo_encomenda_dias IS 'Prazo mínimo para preparar encomenda em dias';
COMMENT ON COLUMN public.products.disponivel_venda IS 'Se o produto está disponível para venda (visível)';
COMMENT ON COLUMN public.products.pronta_entrega IS 'Se o produto é comercializado a pronta entrega';
COMMENT ON COLUMN public.products.aceita_encomenda IS 'Se o produto aceita encomendas';
COMMENT ON COLUMN public.products.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN public.products.updated_at IS 'Data da última atualização';

-- ========================================
-- GRANT DE PERMISSÕES
-- ========================================

-- Conceder permissões básicas para usuários autenticados
GRANT SELECT, INSERT, UPDATE, DELETE ON public.products TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- ========================================
-- DADOS DE EXEMPLO (OPCIONAL - REMOVER EM PRODUÇÃO)
-- ========================================

-- Você pode inserir dados de teste aqui se necessário
-- Exemplo:
-- INSERT INTO public.products (
--     seller_id, tipo, name, description, price, category, 
--     image_url, estoque, disponivel_venda, pronta_entrega
-- ) VALUES (
--     'uuid-do-vendedor', 'produto', 'Bolo de Chocolate', 
--     'Delicioso bolo de chocolate artesanal', 45.00, 'Bolos',
--     'https://via.placeholder.com/300', 10, true, true
-- );
