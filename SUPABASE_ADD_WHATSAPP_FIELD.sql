-- ========================================
-- ADICIONAR CAMPO is_phone_whatsapp
-- ========================================

-- Adiciona coluna is_phone_whatsapp na tabela users
ALTER TABLE users 
ADD COLUMN is_phone_whatsapp BOOLEAN NOT NULL DEFAULT FALSE;

-- Adiciona comentário descritivo
COMMENT ON COLUMN users.is_phone_whatsapp IS 'Indica se o número de telefone do usuário possui WhatsApp';

-- Cria índice para facilitar consultas por usuários com WhatsApp
CREATE INDEX idx_users_is_phone_whatsapp ON users(is_phone_whatsapp);
