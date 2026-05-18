# 🚧 TODO: Integração Completa de Endereços com Supabase

## ✅ O que já está pronto:

1. ✅ **AddressCubit** - Lógica de negócio completa
2. ✅ **AddressState** - Estado unificado (lista + formulário)
3. ✅ **AddressListView** - Tela de listagem de endereços
4. ✅ **AddressView** - Formulário de criação/edição
5. ✅ **AddressRepository** - Interface do repositório
6. ✅ **AddressSupabaseDataSource** - Implementação do data source
7. ✅ **SQL Schema** - Script `SUPABASE_ADDRESSES_TABLE.sql` criado
8. ✅ **Navegação** - Settings → AddressListView com `..initialize()`

---

## 🔴 O que precisa ser implementado:

### **1. Criar tabela `addresses` no Supabase**

**Executar no SQL Editor do Supabase:**
```sql
-- Abrir: https://supabase.com/dashboard/project/YOUR_PROJECT/sql
-- Executar o conteúdo do arquivo: SUPABASE_ADDRESSES_TABLE.sql
```

**O script cria:**
- Tabela `addresses` com FK para `users(id)` UUID
- Índices para performance
- Trigger para `updated_at`
- Constraint para apenas 1 endereço principal por usuário

---

### **2. Converter `userId` de `int` para `String` (UUID)**

**Problema atual:**
- `users.id` no Supabase é `UUID` (String)
- `Address.userId` e `AddressModel.userId` são `int`
- Incompatibilidade de tipos

**Arquivos para atualizar:**

#### 📁 `lib/domain/entities/profile/address.dart`
```dart
class Address extends Equatable {
  final int? addressId;
  final String userId;  // ← Mudar de int para String (UUID)
  // ...resto igual
}
```

#### 📁 `lib/data/models/profile/address_model.dart`
```dart
factory AddressModel.fromJson(Map<String, dynamic> json) {
  return AddressModel(
    addressId: json['address_id'] as int?,
    userId: json['user_id'] as String,  // ← Mudar de int para String
    // ...resto igual
  );
}

Map<String, dynamic> toJson() {
  return {
    if (addressId != null) 'address_id': addressId,
    'user_id': userId,  // ← Já retorna String
    // ...resto igual
  };
}
```

#### 📁 `lib/features/address/cubit/address_state.dart`
```dart
class AddressState extends Equatable {
  final String? userId;  // ← Mudar de int? para String?
  // ...resto igual
  
  AddressState copyWith({
    String? userId,  // ← Mudar tipo
    // ...resto igual
  }) {
    // ...resto igual
  }
}
```

#### 📁 `lib/features/address/cubit/address_cubit.dart`
```dart
// Atualizar assinaturas de métodos:
Future<void> initializeForm(String userId) async { }
Future<void> initializeAddressList(String userId) async { }
Future<void> loadAddresses(String userId) async { }

void updateField({
  String? userId,  // ← Mudar de int? para String?
  // ...resto igual
}) { }
```

#### 📁 `lib/data/datasources/remote/address_supabase_data_source.dart`
```dart
abstract class AddressSupabaseDataSource {
  Future<List<AddressModel>> getUserAddresses(String userId);  // ← int → String
  Future<int> getUserAddressCount(String userId);  // ← int → String
  // ...resto igual
}

class AddressSupabaseDataSourceImpl implements AddressSupabaseDataSource {
  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final response = await supabase
        .from('addresses')
        .select()
        .eq('user_id', userId)  // ← Agora compara com UUID String
        .order('is_primary', ascending: false)
        .order('created_at', ascending: false);
    // ...resto igual
  }
}
```

#### 📁 `lib/domain/repositories/profile/address_repository.dart`
```dart
abstract class AddressRepository {
  Future<Result<List<Address>>> getUserAddresses(String userId);  // ← int → String
  Future<Result<int>> getUserAddressCount(String userId);  // ← int → String
  // ...resto igual
  
  // Adicionar novo método:
  Future<Result<String>> getUserIdByFirebaseUid(String firebaseUid);
}
```

---

### **3. Implementar `getUserIdByFirebaseUid()` no Repository**

#### 📁 `lib/data/repositories/profile/address_repository_impl.dart`
```dart
@override
Future<Result<String>> getUserIdByFirebaseUid(String firebaseUid) async {
  try {
    final response = await supabase
        .from('users')
        .select('id')
        .eq('uid', firebaseUid)  // Assumindo que users tem coluna 'uid'
        .single();
    
    final String userId = response['id'] as String;
    return Success(userId);
  } catch (e) {
    return Error(Failure(message: 'Erro ao buscar userId: $e'));
  }
}
```

---

### **4. Implementar `initialize()` completo no AddressCubit**

#### 📁 `lib/features/address/cubit/address_cubit.dart`
```dart
Future<void> initialize() async {
  try {
    // 1. Busca Firebase UID
    final userDataJson = _prefs.getString('userGoogleAccount');
    if (userDataJson == null) {
      emit(state.copyWith(
        status: AddressStatus.error,
        errorMessage: 'Usuário não autenticado',
      ));
      return;
    }

    final userData = json.decode(userDataJson) as Map<String, dynamic>;
    final String firebaseUid = userData['uid'] as String;

    // 2. Busca userId (UUID) do Supabase
    final userResult = await _repository.getUserIdByFirebaseUid(firebaseUid);
    
    switch (userResult) {
      case Success(:final data):
        final String userId = data;
        emit(state.copyWith(userId: userId));
        await initializeAddressList(userId);
      case Error(:final failure):
        emit(state.copyWith(
          status: AddressStatus.error,
          errorMessage: 'Erro ao buscar usuário: ${failure.message}',
        ));
    }
  } catch (e) {
    emit(state.copyWith(
      status: AddressStatus.error,
      errorMessage: 'Erro ao inicializar: $e',
    ));
  }
}
```

---

### **5. Verificar schema da tabela `users`**

Confirmar que a tabela `users` tem a coluna para mapear Firebase UID:

```sql
-- Verificar estrutura
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'users';
```

**Deve ter:**
- `id` (UUID) - Primary Key
- `uid` ou `firebase_uid` (TEXT) - Firebase Auth UID
- `email`, `display_name`, etc.

**Se não tiver coluna de mapeamento, adicionar:**
```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS uid TEXT UNIQUE;
CREATE INDEX IF NOT EXISTS idx_users_uid ON users(uid);
```

---

## 📋 Checklist de Implementação

- [ ] 1. Executar `SUPABASE_ADDRESSES_TABLE.sql` no Supabase
- [ ] 2. Verificar/criar coluna `uid` na tabela `users`
- [ ] 3. Converter `userId` de `int` para `String` em todos os arquivos listados
- [ ] 4. Adicionar método `getUserIdByFirebaseUid()` no AddressRepository
- [ ] 5. Implementar `getUserIdByFirebaseUid()` no AddressRepositoryImpl
- [ ] 6. Atualizar `initialize()` no AddressCubit com código completo
- [ ] 7. Testar navegação Settings → Endereços
- [ ] 8. Verificar se breakpoint em `getUserAddresses()` é atingido
- [ ] 9. Testar CRUD completo: criar, editar, deletar endereço
- [ ] 10. Validar que apenas 1 endereço pode ser principal

---

## 🧪 Como Testar

1. **Criar tabela no Supabase**
   ```bash
   # Copiar conteúdo de SUPABASE_ADDRESSES_TABLE.sql
   # Colar no SQL Editor do Supabase
   # Executar
   ```

2. **Fazer login no app**
   ```dart
   // Login com Google para ter Firebase UID
   ```

3. **Navegar para Endereços**
   ```dart
   // Settings → Endereços
   // Verificar se inicializa sem erro
   ```

4. **Colocar breakpoint**
   ```dart
   // address_supabase_data_source.dart linha 30
   // Verificar se breakpoint é atingido
   ```

5. **Criar endereço**
   ```dart
   // Testar formulário completo
   // Salvar e verificar no Supabase
   ```

---

## ⚠️ Status Atual

**Estado: 🟡 Parcialmente Implementado**

- ✅ Toda arquitetura criada
- ✅ SQL schema definido
- ✅ Navegação funcionando
- 🔴 Tabela `addresses` não existe no Supabase
- 🔴 Incompatibilidade de tipos (int vs UUID)
- 🔴 Método `getUserIdByFirebaseUid()` não implementado

**Próximo passo:** Executar checklist acima na ordem.
