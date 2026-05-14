# 🔍 Checklist de Debug - Supabase não está salvando

## ✅ Passos para identificar o problema:

### 1. **Verificar arquivo .env**

Abra o arquivo `.env` na raiz do projeto e confirme:

```env
SUPABASE_URL=https://rhmmjsjbvfivtathuviv.supabase.co
SUPABASE_ANON_KEY=sua-chave-real-aqui  # ⬅️ Verifique se está correto!
```

**⚠️ A chave não pode estar como:**
- `SUA_CHAVE_ANON_AQUI`
- `sb_publishable_...` (formato incorreto)

**✅ Deve ser um JWT começando com:**
- `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

---

### 2. **Obter a chave correta do Supabase**

1. Acesse: https://app.supabase.com/project/rhmmjsjbvfivtathuviv/settings/api
2. Copie a chave **anon public** (seção Project API keys)
3. Cole no `.env` em `SUPABASE_ANON_KEY`

---

### 3. **Verificar se a tabela `users` existe**

1. Acesse: https://app.supabase.com/project/rhmmjsjbvfivtathuviv/editor
2. Verifique se a tabela `users` existe
3. Confirme que tem os campos: `uid`, `email`, `full_name`, `creation_time`, etc

Se não existir, crie com:

```sql
CREATE TABLE users (
  uid VARCHAR PRIMARY KEY,
  email VARCHAR,
  full_name VARCHAR,
  display_name VARCHAR,
  photo_url TEXT,
  phone_number VARCHAR,
  cpf VARCHAR,
  creation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_sign_in_time TIMESTAMP,
  seller_rating NUMERIC DEFAULT 0.00,
  is_seller BOOLEAN DEFAULT false,
  default_shipping_street VARCHAR,
  default_shipping_number VARCHAR,
  default_shipping_complement VARCHAR,
  default_shipping_neighborhood VARCHAR,
  default_shipping_city VARCHAR,
  default_shipping_state VARCHAR,
  default_shipping_zip_code VARCHAR,
  email_verified BOOLEAN DEFAULT false,
  phone_verified BOOLEAN DEFAULT false
);
```

---

### 4. **Verificar RLS (Row Level Security)**

A tabela pode ter RLS habilitado bloqueando inserções.

Execute no SQL Editor:

```sql
-- Desabilitar RLS temporariamente para testar
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
```

Ou configure políticas corretas:

```sql
-- Permitir inserção sem autenticação (apenas para teste!)
CREATE POLICY "Allow insert for all" ON users
FOR INSERT WITH CHECK (true);

-- Permitir leitura sem autenticação
CREATE POLICY "Allow read for all" ON users
FOR SELECT USING (true);
```

⚠️ **Em produção**, configure RLS adequado depois!

---

### 5. **Executar o app em Debug e verificar logs**

Com os logs que adicionamos, execute:

```bash
flutter run
```

Faça login com Google e observe os logs no terminal:

```
🔄 Iniciando sincronização com Supabase...
📋 UID: abc123...
📋 Email: usuario@gmail.com
🔍 Verificando se usuário existe no Supabase...
📋 [Supabase] Tabela: users
✨ Usuário não existe. Criando novo...
📤 Enviando dados para Supabase...
📋 [Supabase] Tabela: users
📤 [Supabase] Dados a serem inseridos:
   uid: abc123...
   email: usuario@gmail.com
   ...
✅ [Supabase] Usuário criado com sucesso!
```

Se aparecer **❌ ERRO**, copie a mensagem completa!

---

### 6. **Erros Comuns e Soluções**

#### Erro: "Invalid API key"
**Causa:** Chave do `.env` está errada ou não foi carregada  
**Solução:** 
- Verifique se a chave no `.env` está correta
- Execute `flutter clean && flutter pub get`
- Reinicie o app

#### Erro: "new row violates row-level security policy"
**Causa:** RLS está bloqueando inserções  
**Solução:** Configure políticas RLS (passo 4)

#### Erro: "duplicate key value violates unique constraint"
**Causa:** Usuário já existe mas `getUserByUid()` não o encontrou  
**Solução:** Verifique se o campo `uid` na tabela é do tipo correto (VARCHAR/TEXT)

#### Erro: "relation 'users' does not exist"
**Causa:** Tabela não existe  
**Solução:** Crie a tabela (passo 3)

#### Erro: "column 'xxx' does not exist"
**Causa:** Campo faltando na tabela  
**Solução:** Adicione o campo com `ALTER TABLE users ADD COLUMN xxx VARCHAR;`

---

### 7. **Teste direto no Supabase Dashboard**

Execute no SQL Editor:

```sql
-- Inserir usuário manualmente para testar
INSERT INTO users (uid, email, full_name, creation_time)
VALUES ('test-123', 'test@example.com', 'Test User', NOW());

-- Verificar se foi inserido
SELECT * FROM users WHERE uid = 'test-123';
```

Se funcionar manualmente mas não pelo app, o problema está na autenticação/chave.

---

### 8. **Verificar conectividade**

Teste se o app consegue conectar ao Supabase:

```dart
// Adicione temporariamente no main.dart após inicializar Supabase
final testResponse = await Supabase.instance.client
    .from('users')
    .select()
    .limit(1);
print('✅ Conexão Supabase OK: $testResponse');
```

---

## 🆘 Se nada funcionar:

1. Copie **TODOS os logs** do terminal
2. Tire screenshot do Supabase Dashboard (tabela users)
3. Confirme que o arquivo `.env` tem a chave correta
4. Me envie essas informações

---

## ⚡ Quick Fix (Teste Rápido):

Execute este SQL para remover todas as restrições temporariamente:

```sql
-- ATENÇÃO: Apenas para DEBUG! Remove segurança!
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
GRANT ALL ON users TO anon;
GRANT ALL ON users TO authenticated;
```

Depois teste o login novamente.
