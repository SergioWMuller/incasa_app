# Estratégia de Migração: Firebase → Laravel + PostgreSQL

## 📋 Visão Geral

**MVP (Atual):** Firebase (Auth + Firestore)  
**Produção (Futuro):** Laravel + PostgreSQL no VPS

## 🎯 Objetivo

Desenvolver com Firebase durante o MVP mantendo a arquitetura preparada para migração futura sem grandes refatorações.

---

## 🏗️ Arquitetura Atual

O projeto segue a **arquitetura recomendada pelo Flutter** baseada em Clean Architecture:

```
lib/
├── domain/              # ❌ NUNCA deve ter dependências de Firebase
│   ├── entities/       # Modelos de negócio puros (Dart puro)
│   ├── repositories/   # Interfaces abstratas (contratos)
│   └── usecases/       # Regras de negócio
│
├── data/               # ✅ Única camada que conhece Firebase
│   ├── models/         # DTOs - conversão entre Entity e JSON/Firebase
│   ├── datasources/    # Implementações concretas
│   │   ├── remote/     # Firebase/API REST
│   │   └── local/      # SharedPreferences/SQLite
│   └── repositories/   # Implementação dos contratos do domain
│
└── features/           # UI e State Management (BLoC/Cubit)
    └── [feature]/
        ├── view/
        ├── cubit/
        └── widgets/
```

---

## ✅ Princípios para Migração Suave

### 1. **Camada de Domínio Isolada**
```dart
// ✅ CORRETO - domain/repositories/profile/profile_repository.dart
abstract class ProfileRepository {
  Future<Result<User>> getUserProfile();
  Future<Result<User>> updateUserProfile(User user);
}

// ❌ ERRADO - Nunca fazer isso no domain
import 'package:firebase_auth/firebase_auth.dart'; // ❌
import 'package:cloud_firestore/cloud_firestore.dart'; // ❌
```

### 2. **Data Sources com Abstrações**
```dart
// ✅ CORRETO - data/datasources/remote/profile_remote_data_source.dart
abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(UserModel user);
}

// Implementação Firebase (MVP)
class ProfileFirebaseDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  
  @override
  Future<UserModel> getUserProfile() async {
    final doc = await firestore.collection('users').doc(userId).get();
    return UserModel.fromFirestore(doc);
  }
}

// Implementação Laravel (Futuro)
class ProfileApiDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;
  
  @override
  Future<UserModel> getUserProfile() async {
    final response = await dioClient.get('/api/user/profile');
    return UserModel.fromJson(response.data);
  }
}
```

### 3. **Models com Múltiplos Construtores**
```dart
// ✅ CORRETO - data/models/profile/user_model.dart
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
  });

  // Para Firebase
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }
  
  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
  };

  // Para API REST (Laravel)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
  
  // Conversão de/para Entity
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email,
  );
}
```

### 4. **Injeção de Dependências Flexível**
```dart
// core/di/service_locator.dart
void setupDataSources() {
  // Durante MVP - Firebase
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileFirebaseDataSourceImpl(
      firestore: sl<FirebaseFirestore>(),
    ),
  );
  
  // Após migração - Laravel (apenas trocar o registro)
  // sl.registerLazySingleton<ProfileRemoteDataSource>(
  //   () => ProfileApiDataSourceImpl(
  //     dioClient: sl<DioClient>(),
  //   ),
  // );
}
```

---

## 🚨 Problemas Identificados

### ❌ Problema 1: Auth fora da Arquitetura Limpa
**Localização:** `features/auth/services/auth_service.dart`

**Problema:** O serviço de autenticação está diretamente acoplado ao Firebase e não segue a arquitetura em camadas.

**Solução Recomendada:**
```
lib/
├── domain/
│   ├── entities/auth/
│   │   └── auth_user.dart        # Entity pura (sem Firebase.User)
│   ├── repositories/auth/
│   │   └── auth_repository.dart  # Interface abstrata
│   └── usecases/auth/
│       ├── sign_in_with_google.dart
│       └── sign_out.dart
│
├── data/
│   ├── models/auth/
│   │   └── auth_user_model.dart  # Conversão Firebase.User → AuthUser
│   ├── datasources/remote/
│   │   └── auth_remote_data_source.dart  # Firebase Auth aqui
│   └── repositories/auth/
│       └── auth_repository_impl.dart
│
└── features/auth/
    ├── cubit/
    │   ├── auth_cubit.dart       # Usa UseCases do domain
    │   └── auth_state.dart       # Usa AuthUser (entity)
    └── view/
```

**Ação Necessária:**
- Refatorar `auth_service.dart` para seguir a arquitetura em camadas
- Criar `AuthUser` entity (sem dependência de `firebase_auth`)
- Mover lógica do Firebase para `AuthRemoteDataSource`

---

## 📝 Checklist de Desenvolvimento

Antes de implementar qualquer feature, verifique:

- [ ] **Domain Layer**
  - [ ] Entities não têm imports de packages externos (exceto `equatable`)
  - [ ] Repositories são interfaces abstratas
  - [ ] UseCases contêm apenas regras de negócio puras

- [ ] **Data Layer**
  - [ ] Models têm construtores `.fromFirestore()` e `.toFirestore()` (MVP)
  - [ ] Models têm construtores `.fromJson()` e `.toJson()` (preparação Laravel)
  - [ ] DataSources têm interfaces abstratas
  - [ ] Implementações concretas podem ser trocadas via DI

- [ ] **Features Layer**
  - [ ] Cubits/BLoCs dependem de UseCases, não de Repositories diretamente
  - [ ] States usam Entities, não Models
  - [ ] Views não conhecem Firebase/Dio/etc

---

## 🔄 Processo de Migração (Futuro)

Quando migrar para Laravel + PostgreSQL:

1. **Criar nova implementação de DataSource**
   - `ProfileApiDataSourceImpl` com `DioClient`
   - Manter interface `ProfileRemoteDataSource` intacta

2. **Ajustar Models se necessário**
   - Verificar estrutura JSON da API Laravel
   - Adaptar `.fromJson()` / `.toJson()`

3. **Trocar registro de DI**
   - Em `service_locator.dart`, trocar implementação Firebase por API

4. **Testar**
   - Domain e Features não devem precisar de alterações
   - Apenas a camada Data muda

**Tempo estimado:** Algumas horas por módulo (se arquitetura estiver correta)

---

## 📚 Referências

- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/concepts)
- [Flutter Case Study](https://docs.flutter.dev/app-architecture/case-study)
- Clean Architecture by Robert C. Martin

---

## 🎯 Próximos Passos Recomendados

1. **Refatorar Auth** para seguir arquitetura em camadas
2. **Implementar Firestore DataSources** para Profile, Marketplace, MyStore
3. **Garantir Models** têm ambos construtores (Firestore + JSON)
4. **Documentar convenções** em cada módulo

---

**Última atualização:** 4 de maio de 2026  
**Status:** 🟡 Arquitetura parcialmente correta, necessita refatoração de Auth
