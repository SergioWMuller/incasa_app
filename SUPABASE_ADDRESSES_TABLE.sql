-- ============================================
-- TABELA: address
-- Descrição: Endereços dos usuários
-- Referência: users.uid (Firebase UID String)
-- STATUS: ✅ TABELA JÁ EXISTE NO SUPABASE
-- ============================================

-- ⚠️ NÃO EXECUTAR ESTE SCRIPT!
-- A tabela 'address' já está criada no Supabase.
-- Este arquivo serve apenas como documentação do schema.

-- Schema real da tabela (já existente):
/*
CREATE TABLE public.address (
  address_id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,
  street VARCHAR(255) NOT NULL,
  number VARCHAR(50),
  complement VARCHAR(255),
  neighborhood VARCHAR(255),
  city VARCHAR(100) NOT NULL,
  state VARCHAR(50) NOT NULL,
  zip_code VARCHAR(20),
  address_type public.address_type_enum NOT NULL,
  label VARCHAR(100),
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  country_code TEXT CHECK (country_code IS NULL OR LENGTH(country_code) BETWEEN 1 AND 2)
);
*/

-- Valores do ENUM address_type_enum (verificar no Supabase):
-- Esperado: 'home', 'work', 'billing', 'shipping', 'other'

-- Índices existentes:
-- CREATE INDEX IF NOT EXISTS idx_address_user_id ON address(user_id);
-- CREATE INDEX IF NOT EXISTS idx_address_is_primary ON address(is_primary);

-- Constraint para apenas um endereço principal por usuário:
-- CREATE UNIQUE INDEX IF NOT EXISTS idx_address_one_primary_per_user 
-- ON address(user_id, is_primary) WHERE is_primary = TRUE;

-- ============================================
-- COMPATIBILIDADE COM O CÓDIGO FLUTTER
-- ============================================

-- ✅ Mapeamento de campos (Supabase ↔ Dart):
-- address_id (SERIAL)      → addressId (int?)
-- user_id (TEXT)           → userId (String)
-- is_primary (BOOLEAN)     → isPrimary (bool)
-- street (VARCHAR)         → street (String)
-- number (VARCHAR)         → number (String?)
-- complement (VARCHAR)     → complement (String?)
-- neighborhood (VARCHAR)   → neighborhood (String?)
-- city (VARCHAR)           → city (String)
-- state (VARCHAR)          → state (String)
-- zip_code (VARCHAR)       → zipCode (String?)
-- address_type (ENUM)      → addressType (AddressType enum)
-- label (VARCHAR)          → label (String?)
-- latitude (DOUBLE)        → latitude (double?)
-- longitude (DOUBLE)       → longitude (double?)
-- created_at (TIMESTAMPTZ) → createdAt (DateTime?)
-- updated_at (TIMESTAMPTZ) → updatedAt (DateTime?)
-- country_code (TEXT)      → countryCode (String?)

-- ✅ ENUM Dart → Supabase:
-- AddressType.home      → 'home'
-- AddressType.work      → 'work'
-- AddressType.billing   → 'billing'
-- AddressType.shipping  → 'shipping'
-- AddressType.other     → 'other'

