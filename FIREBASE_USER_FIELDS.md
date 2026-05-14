# 📋 Campos do Firebase User

Este documento lista TODOS os campos disponíveis no objeto `User` retornado pelo Firebase Authentication.

## 🔍 Onde Ver os Campos em Tempo Real

Após adicionar os prints de debug, execute o app e faça login. Você verá no console:

```bash
flutter run
# Faça login com Google
# Veja o console com todos os campos
```

---

## 📦 Campos Principais do Firebase User

### Objeto: `firebase_auth.User`

```dart
final user = FirebaseAuth.instance.currentUser;
// ou
final user = userCredential.user;
```

### Campos Básicos

| Campo | Tipo | Descrição | Exemplo |
|-------|------|-----------|---------|
| `uid` | `String` | ID único do usuário no Firebase | `"abc123xyz456"` |
| `email` | `String?` | Email do usuário | `"usuario@gmail.com"` |
| `displayName` | `String?` | Nome de exibição | `"João Silva"` |
| `photoURL` | `String?` | URL da foto de perfil | `"https://..."` |
| `phoneNumber` | `String?` | Número de telefone | `"+5511999999999"` |
| `emailVerified` | `bool` | Se o email foi verificado | `true` / `false` |
| `isAnonymous` | `bool` | Se é usuário anônimo | `true` / `false` |

### Metadata (Metadados)

```dart
user.metadata
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `creationTime` | `DateTime?` | Quando a conta foi criada |
| `lastSignInTime` | `DateTime?` | Último login |

### Tokens e Refresh

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `refreshToken` | `String?` | Token para renovar sessão |
| `tenantId` | `String?` | ID do tenant (multi-tenancy) |

### Provider Data (Dados dos Provedores)

```dart
user.providerData  // List<UserInfo>
```

Para cada provedor (Google, Facebook, Email, etc):

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `providerId` | `String` | ID do provedor (`"google.com"`) |
| `uid` | `String` | ID do usuário no provedor |
| `email` | `String?` | Email no provedor |
| `displayName` | `String?` | Nome no provedor |
| `photoURL` | `String?` | Foto no provedor |
| `phoneNumber` | `String?` | Telefone no provedor |

---

## 🎯 Exemplo Real de Output

Quando você fizer login com Google, verá algo assim no console:

```
================================================================================
🔍 TODOS OS CAMPOS DO FIREBASE USER:
================================================================================
uid: abc123xyz456def789
email: joao.silva@gmail.com
displayName: João Silva
photoURL: https://lh3.googleusercontent.com/a/ACg8ocK...
phoneNumber: null
emailVerified: true
isAnonymous: false
creationTime: 2026-05-06 10:30:45.123
lastSignInTime: 2026-05-06 15:22:10.456
tenantId: null
refreshToken: eyJhbGciOiJSUzI1NiIsImtpZCI6...
providerData: [Instance of 'UserInfo']
================================================================================
🔍 DADOS DO USER NO AUTH_CUBIT:
================================================================================
uid: abc123xyz456def789
email: joao.silva@gmail.com
displayName: João Silva
photoURL: https://lh3.googleusercontent.com/a/ACg8ocK...
phoneNumber: null
emailVerified: true
isAnonymous: false
metadata.creationTime: 2026-05-06 10:30:45.123
metadata.lastSignInTime: 2026-05-06 15:22:10.456
providerData length: 1
  Provider [0]:
    providerId: google.com
    uid: 123456789012345678901
    email: joao.silva@gmail.com
    displayName: João Silva
    photoURL: https://lh3.googleusercontent.com/a/ACg8ocK...
    phoneNumber: null
================================================================================
```

---

## 🔄 Mapeamento Firebase → Supabase

Use esta tabela para mapear os campos do Firebase para o Supabase:

| Firebase | Supabase (schema) | Tipo no Supabase |
|----------|-------------------|------------------|
| `uid` | `uid_google` | `text` |
| `email` | `email` | `text` |
| `displayName` | `display_name` | `text` |
| `photoURL` | `photo_url` | `text` |
| `phoneNumber` | `phone_number` | `text` |
| `emailVerified` | `email_verified` | `boolean` |
| `isAnonymous` | `is_anonymous` | `boolean` |
| `metadata.creationTime` | `created_at` | `timestamptz` |

---

## 💡 Como Usar os Dados

### 1. Salvar no Supabase após Login

```dart
// No AuthService ou AuthCubit
final user = userCredential.user!;

await supabase.from('users').upsert({
  'uid_google': user.uid,
  'email': user.email,
  'display_name': user.displayName,
  'photo_url': user.photoURL,
  'phone_number': user.phoneNumber,
  'email_verified': user.emailVerified,
  'is_anonymous': user.isAnonymous,
  'created_at': user.metadata.creationTime?.toIso8601String(),
});
```

### 2. Atualizar UserModel

```dart
// fromFirebase() - converter User do Firebase para UserModel
factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
  return UserModel(
    id: firebaseUser.uid,
    name: firebaseUser.displayName ?? '',
    email: firebaseUser.email ?? '',
    avatarUrl: firebaseUser.photoURL,
    phone: firebaseUser.phoneNumber,
    createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    // Campos do Supabase
    uidGoogle: firebaseUser.uid,
    displayName: firebaseUser.displayName,
    photoUrl: firebaseUser.photoURL,
    isAnonymous: firebaseUser.isAnonymous,
    emailVerified: firebaseUser.emailVerified,
    phoneNumber: firebaseUser.phoneNumber,
  );
}
```

---

## 🔒 Campos Sensíveis (Não Salvar)

❌ **NÃO salve estes campos no banco:**
- `refreshToken` - Token de segurança, não persistir
- `tenantId` - Geralmente null, uso específico

---

## 📚 Documentação Oficial

- [Firebase User API](https://firebase.google.com/docs/reference/android/com/google/firebase/auth/FirebaseUser)
- [Google Sign-In](https://firebase.google.com/docs/auth/flutter/federated-auth#google)

---

## 🧪 Testar

1. Execute o app:
   ```bash
   flutter run
   ```

2. Faça login com Google

3. Veja o console - todos os campos serão mostrados!

4. Copie os valores e use para atualizar:
   - Entity User
   - UserModel
   - Schema do Supabase

---

**Última atualização:** Maio 2026
