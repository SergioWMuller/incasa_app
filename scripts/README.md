# Scripts de Geração Automática

Esta pasta contém scripts para automatizar a sincronização das Models com o schema do Supabase.

## 📁 Arquivos

### 1. **generate_supabase_queries.md**
Queries SQL prontas para copiar e executar no Supabase Dashboard.

**Quando usar:** Forma mais rápida - execute as queries no Supabase e copie os resultados.

**Features:**
- ✅ Query para ver estrutura da tabela
- ✅ Query que gera código Dart automaticamente
- ✅ Query para gerar constructor
- ✅ Query para gerar `fromSupabase()`
- ✅ Query para gerar `toSupabase()`
- ✅ Query para ver todas as tabelas de uma vez

---

### 2. **generate_dart_from_schema.dart**
Script Dart executável que gera código completo.

**Como usar:**
```bash
# 1. Configure o arquivo .env na raiz do projeto:
#    SUPABASE_URL=https://rhmmjsjbvfivtathuviv.supabase.co
#    SUPABASE_ANON_KEY=sua-chave-anon-aqui

# 2. Edite o script e configure:
#    - tableName (nome da tabela)
#    - className (nome da Entity/Model)

# 3. Execute:
dart run scripts/generate_dart_from_schema.dart

# 4. Copie o output do console
```

**O que ele gera:**
- ✅ Entity fields
- ✅ Constructor completo
- ✅ Equatable props
- ✅ Método `fromSupabase()`
- ✅ Método `toSupabase()`

**⚠️ Importante:**
- ✅ Usa credenciais do arquivo `.env` (não hardcoded)
- ✅ Tabela precisa ter pelo menos 1 registro de exemplo
- ✅ Detecta automaticamente tipos nullable e conversões

---

## 🚀 Qual usar?

### Use as **SQL Queries** se:
- ✅ Você quer algo super rápido
- ✅ Você já está no Supabase Dashboard
- ✅ Você quer copiar e colar direto

### Use o **Script Dart** se:
- ✅ Você prefere rodar localmente
- ✅ Você quer gerar várias tabelas em sequência
- ✅ Você quer personalizar o código gerado

---

## 💡 Workflow Recomendado

1. **Use as SQL Queries** primeiro para ver a estrutura
2. **Copie o código gerado** diretamente
3. **Cole nas suas Models**
4. **Ajuste** se necessário (tipos complexos, validações, etc)
5. **Teste** com dados reais

---

## 📋 Exemplo Completo

### Passo 1: Execute a Query SQL
```sql
-- No Supabase SQL Editor
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'products';
```

### Passo 2: Use a Query de Geração de Código
```sql
-- Gera código Dart automaticamente
-- (veja generate_supabase_queries.md)
```

### Passo 3: Copie o Output
```dart
final String id;  // id
final String storeId;  // store_id
final String name;  // name
final double price;  // price
```

### Passo 4: Cole na sua Entity/Model
```dart
class Product extends Equatable {
  final String id;
  final String storeId;
  final String name;
  final double price;
  
  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
  });
  
  @override
  List<Object?> get props => [id, storeId, name, price];
}
```

---

## ⚠️ Importante

- ✅ Sempre **revise o código gerado** antes de usar
- ✅ Ajuste **tipos complexos** manualmente
- ✅ Adicione **imports** necessários
- ✅ Teste com **dados reais**

---

## 🆘 Troubleshooting

**"Tabela vazia"**
- Adicione pelo menos um registro de teste no Supabase

**"Tipo inferido errado"**
- Ajuste manualmente após gerar o código

**"Erro de conexão"**
- Verifique suas credenciais do Supabase

---

Para mais informações, veja:
- [SUPABASE_SCHEMA_SYNC.md](../SUPABASE_SCHEMA_SYNC.md)
- [TOOLS_README.md](../TOOLS_README.md)
