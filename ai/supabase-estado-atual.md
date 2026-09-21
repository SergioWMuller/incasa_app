# Supabase — Estado Atual do Banco

> Referência viva do banco do projeto.  
> Stack: Supabase self-hosted em VPS (`49.13.158.137`) + Postgres 15.8.
> Exposto publicamente via HTTPS em `api.incasa.app.br` (proxy reverso Caddy,
> certificado Let's Encrypt automático — porta 8000 não fica mais exposta
> direto pra internet, só o Caddy fala com o Kong internamente).  
> Atualizado em: 28/06/2026.

---

## 1. Visão geral

O Supabase é a fonte de verdade dos dados do app. O **Firebase Auth** é usado apenas para autenticação (Google, e no futuro Apple/Facebook/etc). O elo entre os dois é a Edge Function **`auth-firebase`**, que recebe o token do Firebase do app, valida e chama o RPC `upsert_user_with_provider` no banco.

**Identidade do usuário no banco** é resolvida pela função `app_user_id()`, que mapeia o `sub` do JWT (UID do Firebase) para o `users.id` interno (UUID), via tabela `providers`.

**LGPD / PII:** o CPF nunca é armazenado em texto puro. O banco guarda:
- `cpf_hmac` — HMAC-SHA256 determinístico, usado para busca/unicidade sem descriptografar.
- `cpf_encrypted` — criptografia simétrica reversível (`pgp_sym_encrypt`, base64), para recuperação legítima futura (NF, repasses).

A chave de PII fica num GUC do banco (`app.pii_key`), configurada via `ALTER DATABASE ... SET app.pii_key = '...'`. As funções leem com `current_setting('app.pii_key', true)` e falham (fail-closed) se a chave estiver ausente.

---

## 2. Tabelas

### 2.1 `users`

| coluna | tipo | nullable | observação |
|---|---|---|---|
| `id` | uuid | não | PK, default `gen_random_uuid()` |
| `full_name` | text | não | |
| `display_name` | text | sim | |
| `photo_url` | text | sim | |
| `seller_rating` | numeric(3,2) | sim | default `0.00` |
| `created_at` | timestamptz | sim | default `now()` |
| `updated_at` | timestamptz | sim | atualizada por trigger |
| `cpf_hmac` | text | sim | índice único; preenchido na etapa 3 do onboarding |
| `cpf_encrypted` | text | sim | base64 de `pgp_sym_encrypt(...)` |

**Trigger:** `trigger_users_updated_at` (atualiza `updated_at`).  
**Índice:** `idx_users_cpf_hmac` UNIQUE → garante 1 CPF por usuário.

### 2.2 `providers`

Tabela de vínculos com provedores de autenticação externos (hoje: Firebase/Google; futuro: Apple, Facebook, etc).

| coluna | tipo | nullable | observação |
|---|---|---|---|
| `id` | uuid | não | PK |
| `user_id` | uuid | não | FK → `users.id` ON DELETE CASCADE |
| `provider` | text | não | ex.: `google`, `apple`, `facebook` |
| `provider_uid` | text | não | **UID do Firebase** (string) |
| `email` | text | sim | |
| `is_primary` | bool | sim | default `false`; garantido único via trigger |
| `is_verified` | bool | sim | default `false` |
| `created_at` | timestamptz | sim | default `now()` |
| `last_login_at` | timestamptz | sim | atualizado a cada login |

**Constraint:** `uq_provider_uid` UNIQUE `(provider, provider_uid)`.  
**Trigger:** `trigger_handle_primary_provider` — ao marcar um como `is_primary = true`, rebaixa os outros do mesmo `user_id`.

### 2.3 `phones`

Múltiplos celulares por usuário. Não há telefone fixo.

| coluna | tipo | observação |
|---|---|---|
| `id` | uuid | PK |
| `user_id` | uuid | FK → `users.id` ON DELETE CASCADE |
| `country_code` | varchar(5) | não nulo |
| `area_code` | varchar(5) | nullable |
| `number` | varchar(15) | não nulo |
| `full_number` | varchar(25) | **GENERATED** (`country_code || area_code || number`) |
| `is_primary` | bool | default `false` |
| `is_verified` | bool | default `false` (SMS futuro) |
| `is_active` | bool | default `true` |
| `verified_at`, `verify_token`, `token_expires_at` | — | suporte a SMS futuro |
| `has_whatsapp` | bool | default `false` |
| `created_at`, `updated_at` | timestamptz | |

**Regras de negócio (enforcement pelo banco):**
- 1 principal por usuário: `idx_phones_one_primary` UNIQUE parcial (`is_primary = true AND is_active = true`).
- **WhatsApp só no principal:** `CHECK phones_whatsapp_requires_primary` → `has_whatsapp = false OR is_primary = true`.

**Trigger:** `set_phones_updated_at` (moddatetime).

### 2.4 `address`

| coluna | tipo | observação |
|---|---|---|
| `address_id` | uuid | PK |
| `user_id` | uuid | FK → `users.id` ON DELETE CASCADE |
| `is_primary` | bool | default `false` |
| `street`, `number`, `complement`, `neighborhood`, `city`, `state`, `zip_code` | text/varchar | |
| `address_type` | enum `address_type_enum` | `home`, `work`, `billing`, `shipping`, `other` |
| `label` | varchar(100) | |
| `latitude`, `longitude` | double | |
| `country_code` | text | CHECK length entre 1 e 2 |
| `created_at`, `updated_at` | timestamptz | |

**1 principal por usuário:** `unique_primary_address_per_user` UNIQUE parcial.  
**Trigger:** `trigger_handle_primary_address` (rebaixa outros principais do mesmo `user_id`).

### 2.5 `products`

Marketplace: qualquer autenticado lê; só o dono modifica.

| coluna | tipo | observação |
|---|---|---|
| `id` | uuid | PK |
| `owner_id` | uuid | FK → `users.id` ON DELETE CASCADE |
| `tipo` | text | CHECK `IN ('produto', 'servico')` |
| `name`, `description`, `category` | text | |
| `price` | numeric(10,2) | CHECK `>= 0` |
| `image_url` | text | nullable |
| `estoque` | int | CHECK `>= 0` |
| `prazo_producao_dias`, `prazo_entrega_horas`, `prazo_minimo_encomenda_dias` | int | CHECK `>= 0` |
| `disponivel_venda` | bool | default `true` |
| `pronta_entrega` | bool | default `true` |
| `aceita_encomenda` | bool | default `false` |
| `created_at`, `updated_at` | timestamptz | |

**Índices:** por `owner_id`, `category`, `tipo`, `created_at DESC`, e parciais em `disponivel_venda`.  
**Trigger:** `update_products_updated_at`.

---

## 3. Funções (RPC)

### 3.1 `app_user_id() → uuid`

```sql
select user_id from public.providers
where provider_uid = auth.jwt() ->> 'sub'
limit 1
```

`SECURITY DEFINER`, `STABLE`. Devolve o `users.id` do dono do token atual. Base de **todas** as policies de RLS.

### 3.2 `upsert_user_with_provider(...) → jsonb`

Assinatura:
```
p_provider     text
p_provider_uid text
p_email        text
p_full_name    text
p_display_name text
p_photo_url    text
p_cpf          text DEFAULT NULL      -- opcional
```

Comportamento:
- **Caso A** — provider já existe: atualiza `last_login_at` + `email`.
- **Caso B** — provider novo, CPF já existe na base: anexa novo provider ao user.
- **Caso C** — tudo novo: cria `users` (CPF pode ser NULL) + `providers`.

Quando há CPF: valida 11 dígitos, calcula `cpf_hmac` (HMAC-SHA256 com `app.pii_key`) e `cpf_encrypted` (base64 de `pgp_sym_encrypt`).

Retorna `{ user_id, is_new_user, is_new_provider }`.

**Chamada exclusivamente via service_role** (a partir da Edge Function `auth-firebase`).

### 3.3 `set_user_cpf(p_cpf text) → void`

Função pública para a **etapa 3 do onboarding**. Usa `app_user_id()` para identificar o dono via token — não recebe `user_id` por parâmetro (evita que alguém grave CPF na conta de outro).

Valida formato (11 dígitos), confere `app.pii_key`, grava `cpf_hmac` + `cpf_encrypted` no próprio `users`. Em conflito de unicidade: "Este CPF já está cadastrado em outra conta."

`GRANT EXECUTE TO authenticated, service_role`.

### 3.4 Triggers utilitários

- `handle_primary_address()` / `handle_primary_provider()` — rebaixam outros principais do mesmo usuário ao marcar um novo.
- `update_updated_at_column()` / `update_users_updated_at()` — atualizam `updated_at` em UPDATE.

---

## 4. RLS — estado atual

Todas as tabelas têm RLS habilitada. As policies novas usam `app_user_id()` (não `auth.uid()`, que não funciona com identidade do Firebase).

### Policies por tabela

| Tabela | Policy | Comando | Predicado |
|---|---|---|---|
| `users` | `Allow all operations` ⚠️ | ALL | `true` |
| `users` | `users: select own` | SELECT | `id = app_user_id()` |
| `users` | `users: update own` | UPDATE | `id = app_user_id()` |
| `address` | `Allow all operations` ⚠️ | ALL | `true` |
| `address` | `address: select own` | SELECT | `user_id = app_user_id()` |
| `address` | `address: insert own` | INSERT | `user_id = app_user_id()` (with check) |
| `address` | `address: update own` | UPDATE | `user_id = app_user_id()` |
| `address` | `address: delete own` | DELETE | `user_id = app_user_id()` |
| `phones` | `phones: select/insert/update/delete own` | * | `user_id = app_user_id()` |
| `products` | `Allow all operations` ⚠️ | ALL | `true` |
| `products` | `products: select all authenticated` | SELECT | `true` |
| `products` | `products: insert/update/delete own` | * | `owner_id = app_user_id()` |
| `providers` | `providers: select own` | SELECT | `user_id = app_user_id()` |

### ⚠️ As três "Allow all operations" (em `users`, `address`, `products`)

Estão **intencionalmente ativas durante a fase de transição**. Postgres soma policies permissivas com OR, então enquanto elas existirem as restritivas por `app_user_id()` ficam **inertes**. Isso permite que o app, que **hoje ainda envia o token do Firebase cru** no `Authorization` (caindo como `anon` no PostgREST), continue gravando/lendo durante o desenvolvimento.

**Remoção é o último passo da arquitetura de segurança.** Pré-requisitos para rodar `DROP POLICY "Allow all operations"`:

1. A Edge Function `auth-firebase` emitir também um **JWT do Supabase** (assinado com `JWT_SECRET`, `sub = UID do Firebase`, `role = 'authenticated'`).
2. O Flutter inicializar o `supabase_flutter` com função `accessToken` retornando esse JWT do Supabase (não o do Firebase).
3. Teste de fumaça: uma chamada autenticada via `supabase_flutter` (ex.: ler `phones`) funciona.

Só então rodar a migration final:

```sql
DROP POLICY IF EXISTS "Allow all operations" ON public.users;
DROP POLICY IF EXISTS "Allow all operations" ON public.address;
DROP POLICY IF EXISTS "Allow all operations" ON public.products;
```

---

## 5. Edge Function `auth-firebase`

Localização na VPS: `/root/supabase/docker/volumes/functions/auth-firebase/index.ts`.  
Container: `supabase-edge-functions` (Supabase edge-runtime v1.71.2).

**Fluxo atual:**
1. Recebe `{ id_token, cpf? }` em POST.
2. Decodifica o JWT do Firebase (não valida assinatura ainda — pendência de segurança).
3. Confere `iss = https://securetoken.google.com/incasa-f0d5a`, `aud = incasa-f0d5a`, `exp > now`.
4. Identifica provider (`google` / `apple` / etc) via `firebase.sign_in_provider`.
5. Chama `rpc('upsert_user_with_provider', { ... })` com service_role.
6. Devolve `{ success, user_id, is_new_user, is_new_provider, firebase_uid, email, display_name, photo_url, provider }`.

**Variáveis de ambiente disponíveis no container:** `JWT_SECRET`, `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `VERIFY_JWT` (global = `true`).

**Project ID do Firebase:** `incasa-f0d5a`.

---

## 6. Onboarding (3 etapas obrigatórias)

1. **Email** — auto-populado do Firebase (visualmente pulado).
2. **Telefone** — número + flag WhatsApp. Sem validação SMS no MVP.
3. **CPF** — 11 dígitos. Sem validação de dígito verificador no MVP.

O usuário é criado na **primeira chamada à `auth-firebase`**, sem CPF. CPF entra depois via `set_user_cpf(p_cpf)`.

---

## 7. Pendências conhecidas

### No Supabase (este projeto)
- **Migration final (`DROP "Allow all"`)** — aguardando pré-requisitos da Edge Function + Flutter.
- **Validação de assinatura do token Firebase via JWKS** na `auth-firebase` (hoje só decodifica). Faz parte do mesmo passo acima.
- **Emissão de JWT do Supabase pela `auth-firebase`** (mesmo passo).

### No Flutter (chat separado)
- Corrigir `from('user_auth_providers')` → `from('providers')` (nome de tabela errado no app).
- Remover chamada legada ao Firestore em `users/<uid>` (gera `PERMISSION_DENIED`).
- Inicializar `supabase_flutter` com função `accessToken` apontando para o JWT do Supabase (após a Edge Function passar a emiti-lo).

### Futuro (pós-MVP)
- Validação de dígito verificador do CPF.
- Validação de telefone por SMS.
- Reatribuição de WhatsApp para outro número (lógica no app, já que o banco força "WhatsApp só no principal").

---

## 8. Comandos úteis de verificação

```sql
-- estado das funções
SELECT proname, pg_get_function_arguments(oid)
FROM pg_proc WHERE pronamespace = 'public'::regnamespace
ORDER BY proname;

-- todas as policies
SELECT tablename, policyname, cmd, qual, with_check
FROM pg_policies WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- chave de PII configurada?
SELECT length(current_setting('app.pii_key', true)) > 0 AS pii_key_ok;

-- round-trip de criptografia
DO $$
DECLARE v_key text := current_setting('app.pii_key', true);
        v_enc text; v_dec text;
BEGIN
  v_enc := encode(extensions.pgp_sym_encrypt('12345678901', v_key), 'base64');
  v_dec := extensions.pgp_sym_decrypt(decode(v_enc, 'base64')::bytea, v_key);
  RAISE NOTICE 'round-trip: %', v_dec;
END $$;
```

---

## 9. Migrations aplicadas (histórico)

| # | Descrição | Status |
|---|---|---|
| 001 | Corrige `upsert_user_with_provider` para schema novo (cpf_hmac/cpf_encrypted, email só em providers) | substituída pela 003 |
| 002 | `CHECK phones_whatsapp_requires_primary` | ✅ aplicada |
| 003 | `upsert_user_with_provider` com CPF opcional + encriptação em base64 | ✅ aplicada |
| 004 | Policies por-usuário com `app_user_id()` (inertes enquanto "Allow all" existirem) | ✅ aplicada |
| 005 | Função `set_user_cpf` para etapa 3 do onboarding | ✅ aplicada |
| 006 | DROP "Allow all" — passo final de segurança | ⏳ pendente |

