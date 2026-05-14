# FAQ e Troubleshooting - Arquitetura Migratória

## ❓ Perguntas Frequentes

### 1. Por que não posso usar Firebase diretamente no Domain?
**R:** A camada Domain representa suas **regras de negócio puras**. Se você acoplar Firebase aqui, quando migrar para Laravel, precisará refatorar toda a lógica de negócio. Mantendo o Domain puro, você troca apenas a implementação do DataSource.

```dart
// ❌ ERRADO - Regra de negócio acoplada ao Firebase
class GetProducts {
  final FirebaseFirestore firestore;
  
  Future<List<Product>> call() async {
    final snapshot = await firestore.collection('products').get();
    // ... lógica de negócio misturada com Firebase
  }
}

// ✅ CORRETO - Regra de negócio independente
class GetProducts {
  final ProductRepository repository;
  
  Future<Result<List<Product>>> call() async {
    return await repository.getProducts();
    // Repository pode ser Firebase ou Laravel
  }
}
```

---

### 2. Preciso realmente criar DOIS construtores (fromFirestore E fromJson)?
**R:** SIM! Mesmo que agora só use Firebase. Isso garante que:
- Sua estrutura de dados está documentada
- A migração será trivial (já está pronta)
- Você pensa em como os dados serão serializados

```dart
// ✅ SEMPRE faça assim
class ProductModel extends Product {
  // Firebase (usando agora)
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {...}
  Map<String, dynamic> toFirestore() {...}
  
  // Laravel (preparação futura)
  factory ProductModel.fromJson(Map<String, dynamic> json) {...}
  Map<String, dynamic> toJson() {...}
}
```

---

### 3. Por que criar interface abstrata para DataSource?
**R:** Para permitir múltiplas implementações sem mudar código superior.

```dart
// Interface
abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

// Implementação 1 - Firebase (MVP)
class ProductFirebaseDataSourceImpl implements ProductRemoteDataSource {...}

// Implementação 2 - Laravel (Futuro)
class ProductApiDataSourceImpl implements ProductRemoteDataSource {...}

// Repository usa a interface, não sabe qual implementação está ativa
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource; // Interface!
  // Funciona com qualquer implementação
}
```

---

### 4. Cubit deve usar UseCase ou Repository?
**R:** SEMPRE UseCase! UseCase encapsula regras de negócio.

```dart
// ❌ ERRADO
class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository repository;
  
  void loadProducts() async {
    final result = await repository.getProducts();
    // Regra de negócio no Cubit
  }
}

// ✅ CORRETO
class ProductsCubit extends Cubit<ProductsState> {
  final GetProducts getProducts;
  
  void loadProducts() async {
    final result = await getProducts();
    // Regra de negócio no UseCase
  }
}
```

---

### 5. State deve usar Entity ou Model?
**R:** SEMPRE Entity! State é parte da camada de Features, não conhece Data.

```dart
// ❌ ERRADO
class ProductsState {
  final List<ProductModel> products; // Model da camada Data
}

// ✅ CORRETO
class ProductsState {
  final List<Product> products; // Entity da camada Domain
}
```

---

## 🐛 Problemas Comuns

### Problema 1: Firebase Auth User no State
```dart
// ❌ PROBLEMA
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user; // User do Firebase!
}
```

**Solução:**
```dart
// ✅ SOLUÇÃO
// 1. Criar Entity própria
// domain/entities/auth/auth_user.dart
class AuthUser extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  
  const AuthUser({...});
}

// 2. Criar Model que converte
// data/models/auth/auth_user_model.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthUserModel extends AuthUser {
  factory AuthUserModel.fromFirebaseUser(firebase_auth.User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
  
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'].toString(),
      email: json['email'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
    );
  }
}

// 3. State usa Entity
class AuthState {
  final AuthUser? user; // ✅ Entity própria
}
```

---

### Problema 2: Erro "Type 'ProductModel' is not a subtype of type 'Product'"
```dart
// ❌ PROBLEMA
class ProductRepositoryImpl implements ProductRepository {
  @override
  Future<Result<Product>> getProductById(String id) async {
    final productModel = await remoteDataSource.getProductById(id);
    return Success(productModel); // ProductModel where Product expected
  }
}
```

**Causa:** Model precisa estender Entity.

**Solução:**
```dart
// ✅ SOLUÇÃO
class ProductModel extends Product { // extends, não implements!
  const ProductModel({...}) : super(...);
}

// Agora ProductModel IS-A Product
// Success(productModel) funciona pois ProductModel é um Product
```

---

### Problema 3: Firestore Timestamp no Entity
```dart
// ❌ PROBLEMA
import 'package:cloud_firestore/cloud_firestore.dart';

class Product extends Equatable {
  final Timestamp createdAt; // ❌ Firestore no Domain!
}
```

**Solução:**
```dart
// ✅ SOLUÇÃO - Entity usa DateTime
class Product extends Equatable {
  final DateTime createdAt; // ✅ Tipo Dart puro
}

// Model faz conversão
class ProductModel extends Product {
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Converte!
    );
  }
  
  Map<String, dynamic> toFirestore() => {
    'createdAt': Timestamp.fromDate(createdAt), // Converte!
  };
}
```

---

### Problema 4: DioClient não encontrado no DataSource
```bash
Error: DioClient not registered in service locator
```

**Causa:** Esqueceu de registrar no DI.

**Solução:**
```dart
// core/di/service_locator.dart
void setupDependencies() {
  // External
  sl.registerLazySingleton(() => DioClient(
    baseUrl: 'https://api.incasa.com',
  ));
  
  // DataSource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductApiDataSourceImpl(sl()), // ✅ sl() injeta DioClient
  );
}
```

---

### Problema 5: "The method 'fromFirestore' isn't defined"
```bash
Error: The method 'fromFirestore' isn't defined for the class 'ProductModel'
```

**Causa:** Esqueceu de criar o construtor factory.

**Solução:**
```dart
class ProductModel extends Product {
  // ✅ Adicionar factory constructor
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      // ...
    );
  }
}
```

---

### Problema 6: Data não persiste no Firestore
```dart
// Código parece correto mas não salva
await firestore.collection('products').add(product.toFirestore());
```

**Possíveis causas:**
1. Regras de segurança bloqueando
2. Usuário não autenticado
3. Método `toFirestore()` retornando dados inválidos

**Debug:**
```dart
// 1. Verificar autenticação
final user = FirebaseAuth.instance.currentUser;
print('User: ${user?.uid}'); // Deve ter valor

// 2. Testar regras temporariamente (APENAS DESENVOLVIMENTO!)
// No Console Firebase > Firestore > Rules:
allow read, write: if true; // ⚠️ INSEGURO - apenas para testar

// 3. Verificar dados
final data = product.toFirestore();
print('Data to save: $data'); // Deve ser Map válido

// 4. Try-catch
try {
  await firestore.collection('products').add(data);
  print('✅ Saved!');
} catch (e) {
  print('❌ Error: $e'); // Ver erro específico
}
```

---

## 🔍 Comandos de Debug

### Verificar arquitetura
```bash
# Domain não pode ter Firebase/Dio
grep -r "firebase\|dio\|http" lib/domain/

# Data pode ter Firebase/Dio
grep -r "firebase\|dio" lib/data/

# Features não pode ter Firebase/Dio direto
grep -r "firebase\|dio" lib/features/
```

### Verificar Models
```bash
# Todos os Models devem ter fromFirestore E fromJson
find lib/data/models -name "*.dart" -exec grep -L "fromFirestore\|fromJson" {} \;
```

### Verificar DataSources
```bash
# Todos os DataSources devem ter interface abstrata
find lib/data/datasources -name "*.dart" -exec grep -L "abstract class" {} \;
```

---

## 📊 Tabela de Decisão Rápida

| Situação | Onde colocar? | Pode usar Firebase? |
|----------|---------------|---------------------|
| Modelo de negócio puro | `domain/entities/` | ❌ NÃO |
| Contrato de repositório | `domain/repositories/` | ❌ NÃO |
| Regra de negócio | `domain/usecases/` | ❌ NÃO |
| Conversão de dados | `data/models/` | ✅ SIM |
| Acesso ao Firestore | `data/datasources/` | ✅ SIM |
| Implementação do contrato | `data/repositories/` | ⚠️ Não, usa DataSource |
| Estado da tela | `features/[feature]/cubit/` | ❌ NÃO (usa Entity) |
| UI | `features/[feature]/view/` | ❌ NÃO |

---

## 🎯 Checklist de Troubleshooting

Quando algo não funcionar:

- [ ] Domain tem algum import de Firebase/Dio? → Remover
- [ ] Model tem fromFirestore E fromJson? → Adicionar ambos
- [ ] Model extends Entity? → Corrigir herança
- [ ] DataSource tem interface abstrata? → Criar interface
- [ ] Duas implementações de DataSource (Firebase + API)? → Criar ambas
- [ ] Repository usa DataSource (não Firebase direto)? → Refatorar
- [ ] Cubit usa UseCase (não Repository)? → Refatorar
- [ ] State usa Entity (não Model)? → Corrigir tipo
- [ ] DI está registrado corretamente? → Verificar service_locator
- [ ] Regras de segurança do Firestore permitem operação? → Ajustar no Console

---

## 🆘 Quando Ficar Travado

1. **Leia:** [QUICK_GUIDE.md](./QUICK_GUIDE.md) - Template completo
2. **Copie:** [EXAMPLE_MODULE_MIGRATION.md](./EXAMPLE_MODULE_MIGRATION.md) - Exemplo funcional
3. **Compare:** Seu código vs exemplo (o que está diferente?)
4. **Verifique:** Checklist acima
5. **Debug:** Comandos de verificação
6. **Pergunte:** Abra issue com código problemático

---

## 💡 Dicas Profissionais

1. **Sempre comece pelo Domain:** Entity → Repository → UseCase
2. **Depois Data:** Model (ambos construtores) → DataSource (interface + 2 impl) → Repository impl
3. **Por último Features:** Cubit → View
4. **Teste cada camada:** Não avance sem testar a anterior
5. **Use prints liberalmente:** Durante desenvolvimento, log tudo
6. **Git commit frequente:** Depois de cada camada funcionando

---

**Lembre-se:** A arquitetura parece complexa no início, mas economiza SEMANAS de refatoração futura! 🎯
