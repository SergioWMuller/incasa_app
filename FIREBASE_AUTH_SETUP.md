# Configuração Firebase - Guia de Uso

## ✅ Configuração Completa

A autenticação com Firebase e Google Sign-In foi replicada com sucesso no projeto `/Users/swm/Documents/workspace/flutter/incasa/incasa_app`.

## 📁 Arquivos Adicionados/Modificados

### Core
- **`lib/firebase_options.dart`** - Configurações do Firebase para Android e iOS
- **`lib/main.dart`** - Inicialização do Firebase no app

### Features - Auth
- **`lib/features/auth/services/auth_service.dart`** - Serviço de autenticação com Google Sign-In
- **`lib/features/auth/cubit/auth_cubit.dart`** - Cubit para gerenciar estado de autenticação
- **`lib/features/auth/cubit/auth_state.dart`** - Estados de autenticação (Initial, Loading, Authenticated, Unauthenticated, Error)

### Data
- **`lib/data/models/auth_result.dart`** - Modelo de resultado de autenticação

### Configuração de Plataforma
- **`android/app/google-services.json`** - Configuração Firebase para Android
- **`ios/Runner/GoogleService-Info.plist`** - Configuração Firebase para iOS

### DI (Dependency Injection)
- **`lib/core/di/injection_container.dart`** - Atualizado com AuthService e AuthCubit

## 🚀 Como Usar

### 1. Fazer Login com Google

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/auth/cubit/auth_cubit.dart';
import 'package:incasa_app/features/auth/cubit/auth_state.dart';

// No seu Widget
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return CircularProgressIndicator();
        }
        
        if (state is AuthAuthenticated) {
          // Usuário autenticado
          final user = state.user;
          return Text('Bem-vindo, ${user.displayName}');
        }
        
        if (state is AuthError) {
          return Text('Erro: ${state.message}');
        }
        
        // Usuário não autenticado
        return ElevatedButton(
          onPressed: () {
            context.read<AuthCubit>().signInWithGoogle();
          },
          child: Text('Login com Google'),
        );
      },
    );
  }
}
```

### 2. Fazer Logout

```dart
// No seu código
context.read<AuthCubit>().signOut();
```

### 3. Acessar Usuário Atual

```dart
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/auth/services/auth_service.dart';

// Obter AuthService do DI
final authService = sl<AuthService>();
final currentUser = authService.currentUser;

if (currentUser != null) {
  print('Usuário: ${currentUser.displayName}');
  print('Email: ${currentUser.email}');
  print('Foto: ${currentUser.photoURL}');
}
```

### 4. Usar AuthCubit em App Widget (para listener global)

```dart
BlocProvider<AuthCubit>(
  create: (context) => sl<AuthCubit>()..checkAuthStatus(),
  child: BlocListener<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state is AuthAuthenticated) {
        // Navegar para home
        Navigator.pushReplacementNamed(context, '/home');
      } else if (state is AuthUnauthenticated) {
        // Navegar para login
        Navigator.pushReplacementNamed(context, '/login');
      }
    },
    child: YourAppWidget(),
  ),
)
```

## 📦 Dependências Adicionadas

```yaml
firebase_core: ^3.13.0
firebase_auth: ^5.5.3
google_sign_in: ^6.0.0
```

Execute `flutter pub get` para instalar as novas dependências.

## 🔧 Configuração do Projeto Firebase

**Project ID:** `incasa-f0d5a`
**Project Number:** `289817032686`

Os arquivos de configuração para iOS e Android já foram copiados do projeto original.

## ⚠️ Próximos Passos (Opcional)

1. **Integrar com Supabase** (se necessário):
   - Criar um `supabase_service.dart` similar ao projeto original
   - Adicionar lógica para salvar dados do usuário após login

2. **Tela de Login**:
   - Criar uma página de login que use o `AuthCubit`

3. **Proteção de Rotas**:
   - Usar o estado do `AuthCubit` para redirecionar usuários não autenticados

4. **Refresh Token**:
   - Considerar adicionar lógica de renovação automática de token

---

**Configuração concluída em: 31/03/2026**
