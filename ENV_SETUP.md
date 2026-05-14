# 🔐 Configuração de Variáveis de Ambiente (.env)

Este projeto utiliza `flutter_dotenv` para gerenciar credenciais sensíveis de forma segura.

## 📋 Setup Inicial

### 1. Copiar o arquivo de exemplo

```bash
cp .env.example .env
```

### 2. Obter as credenciais do Supabase

1. Acesse o [Supabase Dashboard](https://app.supabase.com/project/rhmmjsjbvfivtathuviv/settings/api)
2. Vá em **Settings** → **API**
3. Copie as seguintes informações:
   - **URL** (Project URL)
   - **anon public** key (API Keys)

### 3. Preencher o arquivo `.env`

Edite o arquivo `.env` e preencha com suas credenciais:

```env
# Supabase Configuration
SUPABASE_URL=https://rhmmjsjbvfivtathuviv.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-real-aqui
```

**Exemplo de chave válida:**
```env
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJobW1qc2pidmZpdnRhdGh1dml2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyNDE2MzEsImV4cCI6MjA1OTgxNzYzMX0.Vxb6G5CSkJKk16NFZTRk_3-gzVhMxE7o1zRKdTz3Ey4
```

## ⚠️ IMPORTANTE

- ✅ O arquivo `.env` está no `.gitignore` e **NÃO** será versionado
- ✅ Nunca comite o arquivo `.env` no Git
- ✅ A chave `anon/public` é segura para ser usada no frontend
- ❌ Nunca compartilhe a chave `service_role` publicamente

## 🔍 Verificar se está funcionando

Execute o app e verifique se não há erros relacionados ao Supabase:

```bash
flutter run
```

Se aparecer erro de autenticação do Supabase, verifique:
1. Se o arquivo `.env` existe na raiz do projeto
2. Se as credenciais estão corretas
3. Se o projeto Supabase está ativo

## 🏗️ Como funciona

### 1. Carregamento no `main.dart`
```dart
void main() async {
  // Carrega variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  // Usa as variáveis
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
}
```

### 2. Acesso via `SupabaseConstants`
```dart
class SupabaseConstants {
  static String get supabaseUrl => 
      dotenv.env['SUPABASE_URL'] ?? 'https://fallback-url.supabase.co';
  
  static String get supabaseAnonKey => 
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
```

## 📦 Arquivos Relacionados

- `.env` - Suas credenciais (ignorado pelo Git)
- `.env.example` - Template de exemplo (versionado)
- `lib/core/constants/supabase_constants.dart` - Constantes que leem do .env
- `lib/main.dart` - Carrega o .env na inicialização
- `pubspec.yaml` - Declara `.env` como asset

## 🚀 Deploy (Produção)

Para deploy em produção, você precisará configurar as variáveis de ambiente na plataforma de hosting:

### Android (via `--dart-define`)
```bash
flutter build apk --dart-define=SUPABASE_URL=https://... --dart-define=SUPABASE_ANON_KEY=...
```

### iOS (via Xcode Environment Variables)
Configure em Xcode → Edit Scheme → Run → Arguments → Environment Variables

### Web (Firebase Hosting, Vercel, etc)
Configure as variáveis de ambiente no painel de configuração da plataforma.

## 🔧 Adicionar Novas Variáveis

### 1. Adicione no `.env`
```env
NOVA_VARIAVEL=valor
```

### 2. Adicione no `.env.example`
```env
NOVA_VARIAVEL=exemplo-de-valor
```

### 3. Acesse no código
```dart
String minhaVar = dotenv.env['NOVA_VARIAVEL'] ?? 'valor-padrao';
```

## 📚 Referências

- [flutter_dotenv no pub.dev](https://pub.dev/packages/flutter_dotenv)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/dart/introduction)
- [12-Factor App - Config](https://12factor.net/config)
