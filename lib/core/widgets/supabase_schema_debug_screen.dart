import 'dart:async';
import 'package:flutter/material.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/core/utils/supabase_inspector.dart';
import 'package:incasa_app/core/network/supabase_client.dart';

/// Widget de Debug para inspecionar o schema do Supabase
///
/// **USO TEMPORÁRIO** - Adicione este widget em algum lugar do app
/// para inspecionar suas tabelas e ver o output no console/debug.
///
/// Exemplo:
/// ```dart
/// // Adicionar em algum lugar acessível (ex: tela de perfil)
/// ElevatedButton(
///   onPressed: () {
///     Navigator.push(
///       context,
///       MaterialPageRoute(builder: (_) => SupabaseSchemaDebugScreen()),
///     );
///   },
///   child: Text('Debug Supabase Schema'),
/// )
/// ```
class SupabaseSchemaDebugScreen extends StatefulWidget {
  const SupabaseSchemaDebugScreen({super.key});

  @override
  State<SupabaseSchemaDebugScreen> createState() =>
      _SupabaseSchemaDebugScreenState();
}

class _SupabaseSchemaDebugScreenState extends State<SupabaseSchemaDebugScreen> {
  final _inspector = SupabaseInspector(sl<SupabaseClientWrapper>());
  final _tableController = TextEditingController();
  bool _isLoading = false;
  String _output = 'Selecione uma tabela ou insira um nome personalizado';

  final _commonTables = ['users', 'products', 'categories', 'stores'];

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _inspectTable(String tableName) async {
    if (tableName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite o nome da tabela')));
      return;
    }

    setState(() {
      _isLoading = true;
      _output = 'Inspecionando tabela "$tableName"...\n';
    });

    // Capturar output do print
    final buffer = StringBuffer();

    await runZonedGuarded(
      () async {
        // Redirecionar prints para o buffer
        await _inspector.inspectTable(tableName);
      },
      (error, stack) {
        buffer.writeln('Erro: $error');
      },
    );

    // Nota: Em produção, você precisaria de uma solução melhor
    // para capturar os prints. Esta é uma versão simplificada.

    setState(() {
      _isLoading = false;
      _output =
          'Inspeção concluída! Veja o console/debug para detalhes.\n\n'
          '💡 Dica: Use "flutter run" no terminal para ver o output completo.\n\n'
          'Ou use o método diretamente em um teste:\n'
          'final inspector = SupabaseInspector(sl<SupabaseClientWrapper>());\n'
          'await inspector.inspectTable("$tableName");';
    });

    // Mostrar notificação
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inspeção de "$tableName" completa! Veja o console.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _inspectAllTables() async {
    setState(() {
      _isLoading = true;
      _output = 'Inspecionando todas as tabelas...\n';
    });

    await _inspector.inspectAllTables();

    setState(() {
      _isLoading = false;
      _output =
          'Inspeção completa! Veja o console/debug para todos os detalhes.';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspeção completa! Veja o console.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Schema Inspector'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Debug Tool',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta ferramenta inspeciona suas tabelas do Supabase '
                      'e gera código para sincronizar suas Models.\n\n'
                      'O output detalhado aparece no console/debug.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tabelas Comuns
            Text(
              'Tabelas Comuns',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonTables.map((table) {
                return ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _inspectTable(table),
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(table),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.deepPurple.shade900,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Input personalizado
            Text(
              'Tabela Personalizada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tableController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da tabela',
                      hintText: 'ex: my_custom_table',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.table_chart),
                    ),
                    enabled: !_isLoading,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => _inspectTable(_tableController.text.trim()),
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Inspecionar todas
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _inspectAllTables,
              icon: const Icon(Icons.list_alt),
              label: const Text('Inspecionar Todas as Tabelas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Loading
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Inspecionando... Veja o console para detalhes.'),
                  ],
                ),
              ),

            // Output
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terminal, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instruções
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Como usar o output',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Execute o app com "flutter run"\n'
                      '2. Clique em uma tabela para inspecionar\n'
                      '3. Veja o console/terminal - lá terá:\n'
                      '   • Lista de todos os campos\n'
                      '   • Tipos Dart inferidos\n'
                      '   • Código gerado para fromSupabase()\n'
                      '   • Código gerado para toSupabase()\n'
                      '   • JSON de exemplo\n\n'
                      '4. Copie o código gerado para sua Model\n'
                      '5. Ajuste conforme necessário',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
