# inCasa App 🏠

Marketplace de móveis e decoração com foco em sustentabilidade e economia circular.

---

## 📋 Sobre o Projeto

**inCasa** é uma plataforma que conecta vendedores e compradores de móveis e itens de decoração, promovendo a reutilização e economia consciente.

### 🎯 Estratégia de Desenvolvimento

**MVP (Atual):**
- Backend: Firebase (Auth + Firestore)
- Infraestrutura: Firebase Cloud

**Produção (Futuro):**
- Backend: Laravel + PostgreSQL
- Infraestrutura: VPS próprio

**Objetivo:** Arquitetura que permite migração do Firebase para Laravel **sem refatoração** das camadas superiores.

---

## 🏗️ Arquitetura

O projeto segue a **arquitetura recomendada pelo Flutter** baseada em Clean Architecture:

```
lib/
├── domain/              # Regras de negócio puras (sem dependências externas)
│   ├── entities/       # Modelos de negócio
│   ├── repositories/   # Interfaces (contratos)
│   └── usecases/       # Casos de uso
│
├── data/               # Implementações concretas (única camada que conhece Firebase/Laravel)
│   ├── models/         # DTOs com conversores Firebase + JSON
│   ├── datasources/    # Firebase/API implementations
│   └── repositories/   # Implementação dos contratos
│
├── features/           # UI e State Management
│   └── [feature]/
│       ├── view/       # Widgets UI
│       ├── cubit/      # Estado (BLoC pattern)
│       └── widgets/    # Componentes
│
└── core/               # Código compartilhado
    ├── di/             # Injeção de dependências
    ├── router/         # Navegação (GoRouter)
    ├── theme/          # Tema e estilos
    └── utils/          # Utilidades
```

### 🔑 Princípios Fundamentais

1. **Domain Layer:** Zero dependências externas (apenas Dart puro + Equatable)
2. **Data Layer:** Única camada que conhece Firebase/Laravel
3. **Models:** Sempre com construtores `fromFirestore()` + `fromJson()`
4. **DataSources:** Sempre abstratos + implementações (Firebase + API)
5. **Migração:** Trocar apenas registro DI (5 minutos por módulo)

---

## 📚 Documentação

### 📖 Guias Principais

- **[MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md)** - Estratégia completa de migração Firebase → Laravel
- **[QUICK_GUIDE.md](./QUICK_GUIDE.md)** - Guia rápido para desenvolvimento diário
- **[EXAMPLE_MODULE_MIGRATION.md](./EXAMPLE_MODULE_MIGRATION.md)** - Exemplo completo de módulo preparado
- **[FIREBASE_SETUP.md](./FIREBASE_SETUP.md)** - Configuração Firebase e dependências

### 📝 Documentação Técnica

- **[arquitetura.md](./lib/arquitetura.md)** - Requisitos iniciais da arquitetura
- **[FIREBASE_AUTH_SETUP.md](./FIREBASE_AUTH_SETUP.md)** - Configuração de autenticação
- **[LOCAL_PERSISTENCE.md](./LOCAL_PERSISTENCE.md)** - Persistência local

---

## 🚀 Começando

### Pré-requisitos

- Flutter SDK 3.9.0+
- Dart 3.9.0+
- Android Studio / Xcode
- Conta Firebase configurada

### Instalação

```bash
# 1. Clonar repositório
git clone <repository-url>
cd incasa_app

# 2. Instalar dependências
flutter pub get

# 3. Instalar Firestore (OBRIGATÓRIO para MVP)
flutter pub add cloud_firestore

# 4. Configurar Firebase
# - Adicionar google-services.json (Android)
# - Adicionar GoogleService-Info.plist (iOS)

# 5. Executar
flutter run
```

### Dependências Principais

```yaml
dependencies:
  # State Management
  bloc: ^9.1.0
  flutter_bloc: ^9.1.1
  
  # Navigation
  go_router: ^14.6.2
  
  # HTTP Client (preparação Laravel)
  dio: ^5.7.0
  
  # Dependency Injection
  get_it: ^8.0.2
  
  # Firebase (MVP)
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.3
  cloud_firestore: ^5.5.1  # ← Instalar!
  
  # Auth
  google_sign_in: ^6.0.0
  
  # Local Storage
  shared_preferences: ^2.5.5
  
  # Utils
  equatable: ^2.0.7
```

---

## 🛠️ Desenvolvimento

### Criar Nova Feature

1. **Leia primeiro:** [QUICK_GUIDE.md](./QUICK_GUIDE.md)
2. Siga o template em 6 passos
3. Sempre implemente Firebase E Laravel nos Models
4. Registre no DI com implementação Firebase comentada

### Checklist Antes de Commitar

```bash
# Verificar que Domain não tem Firebase/Dio
grep -r "firebase\|dio\|http" lib/domain/  # Deve retornar vazio

# Verificar lint
flutter analyze

# Formatar código
flutter format .

# Testar
flutter test
```

---

## 📦 Features Implementadas

### ✅ Autenticação
- Login com Google
- Gerenciamento de sessão Firebase
- **⚠️ TODO:** Refatorar para arquitetura em camadas (ver [MIGRATION_STRATEGY.md](./MIGRATION_STRATEGY.md#-problemas-identificados))

### 🚧 Em Desenvolvimento
- Profile (parcial)
- Marketplace (estrutura)
- My Store (estrutura)

### 📋 Planejadas
- Listagem de produtos
- Detalhes do produto
- Carrinho de compras
- Sistema de favoritos
- Chat entre usuários
- Avaliações e reviews

---

## 🔄 Processo de Migração (Futuro)

Quando migrar do Firebase para Laravel:

1. Implementar DataSource API (já preparado)
2. Trocar registro DI em `service_locator.dart`
3. **Pronto!** Nenhuma mudança em Domain/Features

**Tempo estimado:** ~5 minutos por módulo (se arquitetura correta)

Veja: [MIGRATION_STRATEGY.md - Processo de Migração](./MIGRATION_STRATEGY.md#-processo-de-migração-futuro)

---

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Executar com coverage
flutter test --coverage

# Ver coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📱 Build

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

---

## 🤝 Contribuindo

1. Leia [QUICK_GUIDE.md](./QUICK_GUIDE.md)
2. Crie uma branch: `git checkout -b feature/nova-feature`
3. Siga a arquitetura em camadas
4. Garanta que Models têm Firebase + JSON
5. Commit: `git commit -m 'feat: adiciona nova feature'`
6. Push: `git push origin feature/nova-feature`
7. Abra um Pull Request

---

## 📞 Suporte

- Documentação: Ver arquivos `*.md` na raiz do projeto
- Issues: Abrir issue no repositório
- Email: contato@incasa.com.br

---

## 📄 Licença

Este projeto é proprietário. Todos os direitos reservados.

---

## 🎯 Roadmap

### Fase 1 - MVP (Firebase) - Q2 2026
- [x] Autenticação Google
- [x] Estrutura base de arquitetura
- [ ] Refatorar Auth para camadas
- [ ] CRUD de produtos
- [ ] Listagem de marketplace
- [ ] Perfil de usuário
- [ ] Minha loja

### Fase 2 - Melhorias MVP - Q3 2026
- [ ] Chat entre usuários
- [ ] Sistema de favoritos
- [ ] Avaliações e reviews
- [ ] Busca e filtros avançados
- [ ] Notificações push

### Fase 3 - Migração para Produção - Q4 2026
- [ ] Implementar backend Laravel
- [ ] Migrar dados Firebase → PostgreSQL
- [ ] Trocar implementações DI
- [ ] Testes de integração
- [ ] Deploy VPS

---

**Desenvolvido com ❤️ pela equipe inCasa**

---

## 📚 Links Úteis

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture/concepts)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
