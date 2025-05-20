import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/products_repository.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _leadTimeController = TextEditingController();
  bool _isAvailable = true;
  String _type = 'product';

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _error = 'Usuário não autenticado.';
        });
        return;
      }
      await ProductsServicesRepository().create(
        userId: userId,
        type: _type,
        name: _nameController.text,
        description: _descriptionController.text,
        price: num.parse(_priceController.text),
        stock: int.tryParse(_stockController.text),
        leadTimeDays: int.tryParse(_leadTimeController.text),
        isAvailable: _isAvailable,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Produto/Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'product', child: Text('Produto')),
                  DropdownMenuItem(value: 'service', child: Text('Serviço')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'product'),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a descrição' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o preço' : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration:
                    const InputDecoration(labelText: 'Estoque (opcional)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _leadTimeController,
                decoration: const InputDecoration(
                    labelText: 'Prazo de entrega (dias, opcional)'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
                title: const Text('Disponível para venda?'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
