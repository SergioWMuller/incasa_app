# CLAUDE.md — Incasa App

> Documento de referência e **guardrails de escopo** para o assistente.
> **Leia isto antes de qualquer alteração.** Se um pedido conflitar com a seção
> [🚧 Escopo & Guardrails](#-escopo--guardrails), **pare e confirme com o usuário
> antes de implementar.**

---

## 1. O que é o Incasa

App Flutter de **marketplace local** (MVP). O usuário faz login social, completa
um onboarding obrigatório de 4 etapas e pode **comprar** (marketplace) e **vender**
(minha loja) produtos/serviços.

**Estado:** MVP em desenvolvimento ativo. Branch de trabalho: `develop`. Branch
principal: `main`.

**Idioma:** domínio e UI em **português (pt-BR)**. Termos de negócio ficam em PT
(`produto`, `servico`, `estoque`, `prazo_*`, `disponivel_venda`). Mantenha esse
padrão — não "traduza" nomes de campos do banco.

---

## 2. Fonte de verdade do backend

O backend é **Supabase self-hosted** (Postgres 15.8) + **Firebase Auth** (apenas
autenticação). O contrato e o estado do banco são definidos por dois documentos
**fora deste repositório** — eles têm prioridade sobre suposições:

- **[ai/incasa-api.yaml](ai/incasa-api.yaml)** — OpenAPI: o **contrato REST/RPC
  oficial**. Models e Entities devem refletir **somente o que estes endpoints
  expõem**.
- **[ai/supabase-estado-atual.md](ai/supabase-estado-atual.md)** — estado vivo do
  banco (tabelas, RLS, funções, pendências, roadmap pós-MVP).

> Regra de ouro: **Models/Entities seguem o `incasa-api.yaml`, não o schema cru do
> banco.** Não replique colunas que os endpoints não retornam (ex.: tokens de SMS,
> `verify_token`). Se o YAML e o código divergirem, o YAML vence — ou pergunte.

### Arquitetura de identidade (importante)
- `users` (recurso) **não tem `email`**. E-mail vive em `providers`; na prática o
  app lê e-mail/telefone da **identidade do Firebase** (`firebase_auth.User`).
- Telefones vivem na tabela **`phones`** (1 principal por usuário).
- CPF nunca é texto puro: só `cpf_hmac` + `cpf_encrypted`, gravados via RPC
  `set_user_cpf`. **Nunca** exponha esses campos na UI.
- Identidade interna é resolvida por `app_user_id()` (mapeia o UID do Firebase →
  `users.id`). RLS depende disso.

---

## 3. Stack

| Camada | Tecnologia |
|---|---|
| Linguagem/SDK | Flutter 3.44.x (stable), Dart |
| Estado | `bloc` / `flutter_bloc` (Cubits) |
| DI | `get_it` ([lib/core/di/injection_container.dart](lib/core/di/injection_container.dart)) |
| Navegação | `go_router` + `AppShell` ([lib/core/widgets/app_shell.dart](lib/core/widgets/app_shell.dart)) |
| Backend | `supabase_flutter` (REST/RPC) |
| Auth | `firebase_auth` + `google_sign_in` (Firebase = **só auth**) |
| HTTP legado | `dio` (cliente Laravel/futuro — **não usar** no MVP) |
| Persistência local | `shared_preferences` |
| Localização | `geocoding`, `geolocator`, `brasil_fields` |
| Igualdade | `equatable` |

---

## 4. Arquitetura (Clean Architecture)

Fluxo de dependência: **UI → Cubit → UseCase → Repository (domain) →
RepositoryImpl (data) → DataSource → Model**.

```
lib/
  core/            # di, theme, network, constants, utils, widgets (AppShell)
  domain/
    entities/      # objetos puros (Equatable), sem framework
    repositories/  # contratos abstratos
    usecases/      # 1 ação por classe (call())
  data/
    models/        # extends Entity + (from/to)Json/Supabase/Entity
    repositories/  # *RepositoryImpl
    datasources/
      remote/      # Supabase (fonte de verdade) — *_supabase_data_source.dart
      local/       # SharedPreferences / mocks
  features/        # auth, onboarding, profile, marketplace, my_store,
                   # address, settings  → cada um: cubit/ + view/ + widgets/
```

### Regras de Model vs Entity
- **Entity** = recurso do `incasa-api.yaml`, campos puros, sem conversão.
- **Model** `extends` Entity e concentra a serialização:
  - `fromSupabase` / `toSupabase` → REST snake_case (fonte de verdade).
  - `toInsert` / `toUpdate` → payloads que respeitam o contrato (ex.: não enviar
    colunas GENERATED como `full_number`; PATCH só com campos editáveis).
  - `fromJson` / `toJson` → cache local e snapshots.
  - `fromEntity` → ponte do domínio.
- **Não** crie conversores Firestore/Laravel novos. Eles foram removidos do escopo.

---

## 5. Convenções de código

- **Supabase = snake_case** nos mapas; **Dart = camelCase** nos campos.
- Um Cubit por feature; estado imutável com `copyWith` + `Equatable`.
- UseCase faz uma coisa só e retorna `Result<T>` (`Success`/`Error`).
- Erros de domínio → `Failure` (`core/error`); não vaze exceptions cruas pra UI.
- Antes de finalizar qualquer mudança: **`flutter analyze lib`** deve ficar sem
  novos `error`/`warning` (os `print`/`avoid_print` são ruído pré-existente).
- Não adicione dependências novas ao `pubspec.yaml` sem confirmar.

---

## 6. 🚧 Escopo & Guardrails

> **Objetivo deste documento:** impedir que o assistente implemente coisas fora do
> escopo do MVP. **Quando em dúvida, pergunte — não amplie o escopo sozinho.**

### ✅ DENTRO do escopo (MVP)
1. **Auth social** via Firebase (Google hoje; Apple/Facebook previstos no contrato).
2. **Onboarding obrigatório de 3 etapas**, nesta ordem:
   1. **E-mail** — auto-populado do Firebase (visualmente pulado).
   2. **Telefone** — número + flag WhatsApp. **Sem validação por SMS no MVP.**
   3. **CPF** — 11 dígitos. **Sem dígito verificador no MVP.**
3. **Perfil** do usuário (`users`): ler/editar `display_name` e `photo_url`.
4. **Endereços** (`address`): CRUD, 1 principal por usuário.
5. **Telefones** (`phones`): CRUD, 1 principal, WhatsApp só no principal.
6. **Marketplace**: listar/buscar produtos (leitura pública autenticada).
7. **Minha Loja**: CRUD de produtos/serviços do próprio usuário (`owner_id`).
8. **Settings**: tema (claro/escuro + cor), preferências locais.

### ❌ FORA do escopo — **NÃO implementar** (a menos que o usuário peça explicitamente)
- **Validação de CPF** (dígito verificador). É pós-MVP.
- **Verificação de telefone por SMS** / OTP real. MVP salva sem verificar.
- **Reatribuição de WhatsApp** entre números (o banco já força "só no principal").
- **Pagamentos, checkout, carrinho, pedidos, frete** — não existem no contrato.
- **Chat / mensagens / notificações push.**
- **Avaliações/`seller_rating` editável** — é gerenciado pelo servidor, read-only.
- **Tabela `stores`** real — hoje é mock local; não construir backend de loja.
- **Firestore como banco de dados** — Firebase é **só auth**. Não criar leituras/
  escritas novas em `cloud_firestore`.
- **Cliente Laravel/`dio`** — é placeholder de futuro; não ligar no fluxo do MVP.
- **Expor PII** (`cpf_hmac`, `cpf_encrypted`) na UI ou em logs.
- **Migrations/DDL no banco** a partir do app. O banco é gerido fora do repo.
- Campos de banco que o `incasa-api.yaml` **não** expõe (não "completar" models
  com colunas internas).

### ⚠️ Pendências conhecidas de data-flow (corrigir só quando for a tarefa)
Estas divergências existem mas **não devem ser "consertadas de surpresa"** dentro
de outra tarefa — vire um item explícito antes:
1. `onboarding_cubit` grava `phone_number`/`cpf` na tabela **`users`**; o correto é
   `phones` (via `PhoneModel`) e CPF via RPC **`set_user_cpf`**.
2. `user_supabase_data_source` usa `from('user_auth_providers')` e `getUserByEmail`;
   a tabela é **`providers`** e `users` não tem `email`.
3. `profile_remote_data_source` ainda é **Firestore** (legado, gera
   `PERMISSION_DENIED`); deveria apontar para o Supabase.
4. Migração final de RLS (`DROP "Allow all operations"`) depende da Edge Function
   emitir JWT do Supabase — ver [ai/supabase-estado-atual.md](ai/supabase-estado-atual.md) §4.

---

## 7. Como trabalhar nesta base (workflow)

1. **Leia o contrato** (`incasa-api.yaml`) antes de mexer em model/datasource.
2. Confirme o escopo na seção 6. Se o pedido for "fora do escopo", **pergunte**.
3. Faça a menor mudança correta; não re-arquitete fluxos vizinhos de carona.
4. Rode `flutter analyze lib` e garanta zero novos erros/warnings.
5. Não commite/push sem o usuário pedir. Se pedir, crie branch a partir de
   `develop` (não trabalhe direto em `main`).

---

## 8. Mapa rápido de features

| Feature | Caminho | Responsabilidade |
|---|---|---|
| Auth | [lib/features/auth](lib/features/auth) | Login Google, sessão Firebase |
| Onboarding | [lib/features/onboarding](lib/features/onboarding) | 3 etapas: e-mail, telefone, CPF |
| Profile | [lib/features/profile](lib/features/profile) | Ver/editar perfil |
| Address | [lib/features/address](lib/features/address) | CRUD de endereços |
| Marketplace | [lib/features/marketplace](lib/features/marketplace) | Listar/buscar produtos |
| My Store | [lib/features/my_store](lib/features/my_store) | CRUD dos próprios produtos |
| Settings | [lib/features/settings](lib/features/settings) | Tema e preferências |
