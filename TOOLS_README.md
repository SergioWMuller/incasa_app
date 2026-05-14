# 🔧 Ferramentas de Sincronização - Supabase Schema

Este diretório contém ferramentas para inspecionar e sincronizar suas Models do Flutter com o schema real do Supabase.

## 📁 Arquivos Criados

### 1. **[SUPABASE_SCHEMA_SYNC.md](SUPABASE_SCHEMA_SYNC.md)** 📚
Documentação completa com todas as estratégias de sincronização:
- Como inspecionar via Dashboard
- Queries SQL úteis
- Scripts de geração
- Exemplos completos de código
- Checklist de sincronização

**Quando usar:** Leia primeiro para entender todo o processo

---

### 2. **[lib/core/utils/supabase_inspector.dart](lib/core/utils/supabase_inspector.dart)** 🔍
Classe utilitária que inspeciona tabelas e gera código automaticamente.

**Métodos principais:**
- `inspectTable(String tableName)` - Inspeciona uma tabela específica
- `inspectAllTables()` - Inspeciona múltiplas tabelas
- `compareModelWithSchema(...)` - Compara Model atual com schema real

**Como usar:**
```dart
// Em qualquer lugar do código onde você tenha acesso ao DI
final inspector = SupabaseInspector(sl<SupabaseClientWrapper>());

// Inspecionar uma tabela
await inspector.inspectTable('products');

// Ver output detalhado no console
```

---

### 3. **[lib/core/widgets/supabase_schema_debug_screen.dart](lib/core/widgets/supabase_schema_debug_screen.dart)** 📱
Widget de debug com interface visual para inspecionar tabelas.

**Como usar:**
```dart
// Adicione temporariamente em alguma tela (ex: perfil, settings)
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupabaseSchemaDebugScreen(),
      ),
    );
  },
  child: Text('Debug Supabase Schema'),
)
```

**Features:**
- ✅ Botões para tabelas comuns (users, products, etc)
- ✅ Input para tabelas personalizadas
- ✅ Botão "Inspecionar Todas"
- ✅ Interface amigável
- ⚠️ Output completo aparece no console/debug

---

### 4. **[test/tools/inspect_supabase_schema_test.dart](test/tools/inspect_supabase_schema_test.dart)** 🧪
Arquivo de teste que funciona como ferramenta de inspeção.

**Como executar:**
```bash
# Inspecionar todas as tabelas
flutter test test/tools/inspect_supabase_schema_test.dart

# Inspecionar apenas uma tabela específica
flutter test test/tools/inspect_supabase_schema_test.dart --name "users"
```

**O que faz:**
- ✅ Inicializa Supabase automaticamente
- ✅ Inspeciona cada tabela em um teste separado
- ✅ Gera código para `fromSupabase()` e `toSupabase()`
- ✅ Mostra JSON de exemplo
- ✅ Compara Models existentes com schema real

---

## 🚀 Workflow Recomendado

### Opção 1: Via Teste (Mais Rápido) ⚡
```bash
# 1. Execute o teste
flutter test test/tools/inspect_supabase_schema_test.dart

# 2. Veja o output no terminal

# 3. Copie o código gerado para suas Models
```

### Opção 2: Via Widget de Debug (Visual) 📱
```dart
// 1. Adicione o botão em alguma tela
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SupabaseSchemaDebugScreen()),
    );
  },
  child: Text('Debug Schema'),
)

// 2. Execute o app: flutter run

// 3. Clique no botão e nas tabelas que quer inspecionar

// 4. Veja o output detalhado no console do terminal
```

### Opção 3: Código Direto (Personalizado) 💻
```dart
// Em qualquer lugar do código
final inspector = SupabaseInspector(sl<SupabaseClientWrapper>());

// Inspecionar
await inspector.inspectTable('products');

// Comparar com Model existente
await inspector.compareModelWithSchema('products', {
  'id': String,
  'name': String,
  'price': double,
  // ... seus campos atuais
});
```

---

## 📋 Exemplo de Output

Quando você executar qualquer ferramenta, verá algo assim no console:

```
============================================================
🔍 INSPECIONANDO TABELA: products
============================================================

📊 CAMPOS ENCONTRADOS:
------------------------------------------------------------
  ✓ id
    → Dart type: String
    → camelCase: id
    → Exemplo: 550e8400-e29b-41d4-a716-446655440000

  ✓ store_id
    → Dart type: String
    → camelCase: storeId
    → Exemplo: 123e4567-e89b-12d3-a456-426614174000

  ✓ name
    → Dart type: String
    → camelCase: name
    → Exemplo: Produto Exemplo

  ✓ price
    → Dart type: double
    → camelCase: price
    → Exemplo: 29.99

  ✓ created_at
    → Dart type: DateTime
    → camelCase: createdAt
    → Exemplo: 2026-05-06T10:30:00Z

📝 CÓDIGO SUGERIDO PARA fromSupabase():
------------------------------------------------------------
factory ProductModel.fromSupabase(Map<String, dynamic> map) {
  return ProductModel(
    id: map['id'] as String,
    storeId: map['store_id'] as String,
    name: map['name'] as String,
    price: map['price'] as double,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

📝 CÓDIGO SUGERIDO PARA toSupabase():
------------------------------------------------------------
Map<String, dynamic> toSupabase() {
  return {
    'id': id,
    'store_id': storeId,
    'name': name,
    'price': price,
    'created_at': createdAt.toIso8601String(),
  };
}

📋 JSON COMPLETO (primeiro registro):
------------------------------------------------------------
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "store_id": "123e4567-e89b-12d3-a456-426614174000",
  "name": "Produto Exemplo",
  "price": 29.99,
  "created_at": "2026-05-06T10:30:00Z"
}
```

---

## ⚠️ Importante

### Antes de Executar:

1. ✅ Configure suas credenciais do Supabase em:
   ```
   lib/core/constants/supabase_constants.dart
   ```

2. ✅ Certifique-se de que as tabelas existem no Supabase

3. ✅ Verifique as permissões RLS (Row Level Security):
   - Se as tabelas estiverem vazias no output, pode ser problema de RLS
   - Temporariamente, você pode desabilitar RLS para testes

### Depois de Inspecionar:

1. ✅ **Atualize a Entity** primeiro (domain layer)
2. ✅ **Atualize a Model** depois (data layer)
3. ✅ **Adicione** os métodos `.fromSupabase()` e `.toSupabase()`
4. ✅ **Mantenha** os métodos `.fromJson()` e `.toJson()` (futuro Laravel)
5. ✅ **Teste** fazendo uma query real

---

## 🗑️ Limpeza (Após Sincronização)

Estas ferramentas são para **desenvolvimento** apenas. Após sincronizar suas Models:

### Pode Remover (Opcional):
- ❌ `lib/core/widgets/supabase_schema_debug_screen.dart`
- ❌ `test/tools/inspect_supabase_schema_test.dart`
- ⚠️ Botões de debug que você adicionou temporariamente

### Deve Manter:
- ✅ `lib/core/utils/supabase_inspector.dart` - útil para futuras alterações
- ✅ `SUPABASE_SCHEMA_SYNC.md` - documentação de referência
- ✅ Este arquivo (TOOLS_README.md)

---

## 🆘 Troubleshooting

### "Tabela vazia ou não existe"
- Verifique o nome da tabela (case-sensitive)
- Verifique se há dados na tabela
- Verifique as políticas RLS do Supabase

### "Erro ao conectar"
- Verifique as credenciais em `supabase_constants.dart`
- Verifique sua conexão com a internet
- Verifique se o projeto Supabase está ativo

### "Campos estão null"
- Normal se a tabela não tem dados
- Adicione alguns dados de teste no Supabase primeiro

### Output não aparece
- Certifique-se de executar com `flutter run` ou `flutter test`
- Veja o terminal/console, não apenas a tela do app

---

## 📚 Mais Informações

Consulte [SUPABASE_SCHEMA_SYNC.md](SUPABASE_SCHEMA_SYNC.md) para:
- Estratégias alternativas
- Queries SQL úteis
- Mapeamento de tipos SQL → Dart
- Exemplos completos de sincronização
- Checklist detalhado

---

**Criado em: Maio 2026**
**Última atualização: Maio 2026**
