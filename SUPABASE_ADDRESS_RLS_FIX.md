# 🔒 Corrigir Row Level Security (RLS) da Tabela `address`

## ❌ Erro Atual

```
PostgrestException(message: new row violates row-level security policy for table "address", 
code: 42501, details: Unauthorized)
```

**Causa:** A tabela `address` tem RLS habilitado, mas **não tem políticas** permitindo INSERT/UPDATE/DELETE.

---

## 🎯 Solução 1: Criar Políticas RLS (RECOMENDADO)

Vá ao Supabase SQL Editor e execute:

```sql
-- ============================================
-- POLÍTICAS RLS PARA TABELA address
-- ============================================

-- 1️⃣ PERMITIR SELECT (Ler próprios endereços)
CREATE POLICY "Usuários podem ver seus próprios endereços"
ON public.address
FOR SELECT
USING (user_id = auth.uid()::text);

-- 2️⃣ PERMITIR INSERT (Criar próprios endereços)
CREATE POLICY "Usuários podem criar seus próprios endereços"
ON public.address
FOR INSERT
WITH CHECK (user_id = auth.uid()::text);

-- 3️⃣ PERMITIR UPDATE (Atualizar próprios endereços)
CREATE POLICY "Usuários podem atualizar seus próprios endereços"
ON public.address
FOR UPDATE
USING (user_id = auth.uid()::text)
WITH CHECK (user_id = auth.uid()::text);

-- 4️⃣ PERMITIR DELETE (Deletar próprios endereços)
CREATE POLICY "Usuários podem deletar seus próprios endereços"
ON public.address
FOR DELETE
USING (user_id = auth.uid()::text);
```

**Explicação:**
- `auth.uid()::text` retorna o Firebase UID do usuário autenticado
- Cada usuário só pode acessar/modificar seus próprios endereços
- O `::text` converte UUID para TEXT (tipo usado em `user_id`)

---

## ⚠️ Solução 2: Desabilitar RLS (APENAS PARA DESENVOLVIMENTO)

Se estiver **testando localmente** e quiser desabilitar RLS temporariamente:

```sql
-- ⚠️ CUIDADO: Isso remove a segurança!
ALTER TABLE public.address DISABLE ROW LEVEL SECURITY;
```

**NÃO USE EM PRODUÇÃO!** Qualquer usuário poderá acessar/modificar todos os endereços.

---

## 🔍 Verificar Estado Atual

### Verificar se RLS está habilitado:

```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename = 'address';
```

Resultado esperado:
```
tablename | rowsecurity
----------|------------
address   | t          <- true = RLS habilitado
```

### Verificar políticas existentes:

```sql
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'address';
```

Se retornar **vazio**, significa que **não há políticas** (por isso o erro).

---

## ✅ Após Aplicar a Solução 1

Execute novamente a verificação de políticas. Você deve ver:

```
policyname                                      | cmd    
------------------------------------------------|--------
Usuários podem ver seus próprios endereços      | SELECT
Usuários podem criar seus próprios endereços    | INSERT
Usuários podem atualizar seus próprios endereços| UPDATE
Usuários podem deletar seus próprios endereços  | DELETE
```

---

## 🚨 Importante sobre `auth.uid()`

O Supabase usa `auth.uid()` para pegar o UID do usuário **autenticado via Supabase Auth**.

**Problema:** Você está usando **Firebase Auth**, não Supabase Auth!

### Soluções:

#### **Opção A: Usar Service Role Key (Bypass RLS)**

No código Flutter, configure o Supabase com **service_role key** (chave de admin):

```dart
// ⚠️ NUNCA EXPONHA service_role no código!
// Use apenas em backend seguro
await Supabase.initialize(
  url: 'https://rhmmjsjbvfivtathuviv.supabase.co',
  anonKey: 'sua-service-role-key', // Bypass RLS
);
```

**CUIDADO:** Service role bypassa RLS. Use apenas se confiar 100% no client-side.

#### **Opção B: Desabilitar RLS (Desenvolvimento)**

```sql
ALTER TABLE public.address DISABLE ROW LEVEL SECURITY;
```

#### **Opção C: Política Permissiva (Qualquer Usuário)**

Se não estiver usando Supabase Auth, crie política que permite tudo:

```sql
-- ⚠️ Permite qualquer operação (não seguro!)
CREATE POLICY "Permitir todas operações"
ON public.address
FOR ALL
USING (true)
WITH CHECK (true);
```

---

## 🎯 Recomendação para o Projeto

Como você está usando **Firebase Auth** (não Supabase Auth), escolha:

1. **Para MVP/Desenvolvimento:** Desabilitar RLS
   ```sql
   ALTER TABLE public.address DISABLE ROW LEVEL SECURITY;
   ```

2. **Para Produção:** Migrar para Supabase Auth ou implementar backend próprio

3. **Alternativa:** Usar políticas permissivas temporariamente:
   ```sql
   CREATE POLICY "Permitir todas operações temporariamente"
   ON public.address
   FOR ALL
   USING (true)
   WITH CHECK (true);
   ```

---

## 📝 Checklist de Correção

- [ ] Acessar Supabase SQL Editor: https://app.supabase.com/project/rhmmjsjbvfivtathuviv/sql
- [ ] Executar script de correção escolhido
- [ ] Verificar políticas com query de verificação
- [ ] Testar criar endereço no app
- [ ] Confirmar que não há mais erro 42501

---

## 🔗 Documentação Oficial

- [Supabase RLS](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
