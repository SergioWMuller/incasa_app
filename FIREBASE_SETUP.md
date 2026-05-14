# Dependências Firebase para MVP

## 📦 Pacotes Necessários

### Já Instalados ✅
```yaml
dependencies:
  firebase_core: ^3.13.0      # Core do Firebase
  firebase_auth: ^5.5.3       # Autenticação
  google_sign_in: ^6.0.0      # Login com Google
  shared_preferences: ^2.5.5  # Cache local
  dio: ^5.7.0                 # HTTP client (preparação Laravel)
```

### A Instalar para MVP com Firebase 🔧
```yaml
dependencies:
  cloud_firestore: ^5.5.1     # ⚠️ NECESSÁRIO - Banco de dados Firestore
  firebase_storage: ^12.3.6   # (Opcional) Upload de imagens
```

---

## 🚀 Comandos de Instalação

### 1. Adicionar Firestore (OBRIGATÓRIO)
```bash
flutter pub add cloud_firestore
```

### 2. Adicionar Storage (Opcional - para imagens)
```bash
flutter pub add firebase_storage
```

### 3. Atualizar dependências
```bash
flutter pub get
```

### 4. Verificar instalação
```bash
flutter pub deps | grep firebase
```

Deve mostrar:
```
├── firebase_core 3.13.0
├── firebase_auth 5.5.3
├── cloud_firestore 5.5.1  ← DEVE APARECER
└── firebase_storage 12.3.6 (se instalado)
```

---

## 📱 Configuração Firebase

### Android (`android/app/build.gradle.kts`)
```kotlin
android {
    defaultConfig {
        minSdk = 21  // Firestore requer mínimo 21
        multiDexEnabled = true // Se app grande
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
}
```

### iOS (`ios/Podfile`)
```ruby
platform :ios, '13.0' # Firestore requer mínimo 13.0
```

---

## 🔧 Estrutura de Collections Firestore (MVP)

### Collection: `users`
```json
{
  "uid": "firebase_user_id",
  "name": "João Silva",
  "email": "joao@example.com",
  "phone": "+5511999999999",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Collection: `products`
```json
{
  "id": "auto_generated",
  "name": "Sofá 3 Lugares",
  "description": "Sofá confortável...",
  "price": 1500.00,
  "imageUrl": "https://...",
  "sellerId": "firebase_user_id",
  "category": "moveis",
  "isActive": true,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Collection: `stores`
```json
{
  "id": "auto_generated",
  "ownerId": "firebase_user_id",
  "name": "Loja do João",
  "description": "Móveis de qualidade",
  "address": {
    "street": "Rua das Flores",
    "number": "123",
    "city": "São Paulo",
    "state": "SP",
    "zipCode": "01234-567"
  },
  "isActive": true,
  "createdAt": Timestamp
}
```

---

## 🔐 Regras de Segurança Firestore (Console Firebase)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users - leitura pública, escrita apenas próprio usuário
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products - leitura pública, escrita apenas dono
    match /products/{productId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.sellerId == request.auth.uid;
    }
    
    // Stores - leitura pública, escrita apenas dono
    match /stores/{storeId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.ownerId == request.auth.uid;
    }
  }
}
```

---

## 🔄 Equivalência Firestore ↔ Laravel

| Conceito | Firestore (MVP) | Laravel (Futuro) |
|----------|-----------------|-------------------|
| Banco de dados | Cloud Firestore | PostgreSQL |
| Tabela | Collection | Table |
| Registro | Document | Row |
| Campo | Field | Column |
| ID | doc.id (auto) | id (integer) |
| Timestamp | Timestamp | DateTime |
| Query | `.where()` | `->where()` |
| Create | `.add()` | `->create()` |
| Read | `.get()` | `->get()` |
| Update | `.update()` | `->update()` |
| Delete | `.delete()` | `->delete()` |

---

## 📝 Exemplo de Uso

### Firestore (MVP)
```dart
// Create
final docRef = await firestore.collection('products').add({
  'name': 'Sofá',
  'price': 1500.00,
  'createdAt': FieldValue.serverTimestamp(),
});

// Read
final snapshot = await firestore.collection('products').get();
final products = snapshot.docs.map((doc) => 
  ProductModel.fromFirestore(doc)
).toList();

// Update
await firestore.collection('products').doc(productId).update({
  'price': 1200.00,
  'updatedAt': FieldValue.serverTimestamp(),
});

// Delete (soft)
await firestore.collection('products').doc(productId).update({
  'isActive': false,
});
```

### Laravel API (Futuro)
```dart
// Create
final response = await dioClient.post('/api/products', data: {
  'name': 'Sofá',
  'price': 1500.00,
});

// Read
final response = await dioClient.get('/api/products');
final products = (response.data['data'] as List)
  .map((json) => ProductModel.fromJson(json))
  .toList();

// Update
await dioClient.put('/api/products/$productId', data: {
  'price': 1200.00,
});

// Delete
await dioClient.delete('/api/products/$productId');
```

**Resultado:** Código idêntico na camada de repository! 🎯

---

## ⚠️ Limitações Firestore a Considerar

### Durante MVP
- **Queries complexas:** Firestore tem limitações em queries (ex: múltiplos `!=`)
- **Joins:** Não suporta joins nativos (usar subcollections ou denormalization)
- **Custo:** Cobrado por leitura/escrita (otimize queries)
- **Offline:** Cache local automático (pode causar confusão)

### Soluções
1. **Denormalização:** Duplicar dados quando necessário
2. **Batch writes:** Agrupar múltiplas escritas
3. **Pagination:** Usar `.limit()` e `.startAfter()`
4. **Indexes:** Criar indexes compostos no Console

---

## 🎯 Próximos Passos

1. [ ] Instalar `cloud_firestore`
2. [ ] Criar collections no Console Firebase
3. [ ] Configurar regras de segurança
4. [ ] Implementar DataSources Firebase conforme [EXAMPLE_MODULE_MIGRATION.md](./EXAMPLE_MODULE_MIGRATION.md)
5. [ ] Testar CRUD com Firestore
6. [ ] Documentar estrutura de dados específica do projeto

---

## 📚 Referências

- [Cloud Firestore Docs](https://firebase.google.com/docs/firestore)
- [FlutterFire Firestore](https://firebase.flutter.dev/docs/firestore/overview)
- [Firestore Data Model](https://firebase.google.com/docs/firestore/data-model)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
