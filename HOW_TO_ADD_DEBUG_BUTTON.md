# Como Adicionar o Botão de Debug ao App

## Opção 1: Na Tela de Perfil (Recomendado)

```dart
// lib/features/profile/view/profile_view.dart

import 'package:incasa_app/core/widgets/supabase_schema_debug_screen.dart';

// ... dentro do build method, adicione:

// Por exemplo, após a lista de configurações:
ListTile(
  leading: Icon(Icons.bug_report, color: Colors.orange),
  title: Text('Debug Supabase Schema'),
  subtitle: Text('Inspecionar tabelas (DEV only)'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupabaseSchemaDebugScreen(),
      ),
    );
  },
),
```

---

## Opção 2: Adicionar ao AppShell (Menu Principal)

```dart
// lib/core/widgets/app_shell.dart

import 'package:incasa_app/core/widgets/supabase_schema_debug_screen.dart';

// Adicione um FloatingActionButton temporário:
floatingActionButton: FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SupabaseSchemaDebugScreen(),
      ),
    );
  },
  child: Icon(Icons.bug_report),
  backgroundColor: Colors.orange,
),
```

---

## Opção 3: Usar Diretamente no Código (Sem Widget)

```dart
// Em qualquer lugar do código onde você tenha contexto e DI

import 'package:incasa_app/core/utils/supabase_inspector.dart';
import 'package:incasa_app/core/di/injection_container.dart';

// Criar o inspector
final inspector = SupabaseInspector(sl<SupabaseClientWrapper>());

// Inspecionar uma tabela
await inspector.inspectTable('products');

// Ou inspecionar todas
await inspector.inspectAllTables();

// Veja o output no console/debug
```

---

## Opção 4: Executar via Teste (Mais Rápido)

```bash
# No terminal, na raiz do projeto:
flutter test test/tools/inspect_supabase_schema_test.dart

# Veja o output completo no terminal
```

---

## Exemplo Completo - ProfileView com Botão

```dart
import 'package:flutter/material.dart';
import 'package:incasa_app/core/widgets/supabase_schema_debug_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: ListView(
        children: [
          // ... seus widgets existentes
          
          // Seção de Configurações
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Configurações'),
            onTap: () {
              // navegar para settings
            },
          ),
          
          // Seção de Tema
          ListTile(
            leading: Icon(Icons.palette),
            title: Text('Tema'),
            onTap: () {
              // navegar para tema
            },
          ),
          
          Divider(),
          
          // 🔧 ADICIONE ESTA SEÇÃO (remover depois)
          Container(
            color: Colors.orange.shade50,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.bug_report, color: Colors.orange),
                  title: Text(
                    'Debug Tools (DEV)',
                    style: TextStyle(color: Colors.orange.shade900),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.storage, color: Colors.deepPurple),
                  title: Text('Inspecionar Schema Supabase'),
                  subtitle: Text('Ver estrutura das tabelas'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SupabaseSchemaDebugScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          Divider(),
          
          // ... resto dos widgets
        ],
      ),
    );
  }
}
```

---

## ⚠️ Lembre-se de Remover em Produção!

Estas ferramentas são **apenas para desenvolvimento**. Antes de fazer deploy:

```dart
// Remova ou comente:
// ListTile(
//   leading: Icon(Icons.bug_report),
//   title: Text('Debug Supabase Schema'),
//   onTap: () => Navigator.push(...),
// ),

// Ou adicione uma flag de ambiente:
if (kDebugMode) {  // Só aparece em modo debug
  ListTile(
    leading: Icon(Icons.bug_report),
    title: Text('Debug Supabase Schema'),
    onTap: () => Navigator.push(...),
  ),
}
```

---

## 🚀 Quick Start

**Forma mais rápida de começar:**

1. Execute o teste:
   ```bash
   flutter test test/tools/inspect_supabase_schema_test.dart
   ```

2. Veja o output no terminal

3. Copie o código gerado para suas Models

**Pronto!** Não precisa adicionar botão nem widget se usar o teste.
