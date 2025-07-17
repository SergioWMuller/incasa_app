import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projeto_incasa_app/features/my_store/states/add_product_state.dart';
import '../cubits/add_product_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddProductCubit(),
      child: BlocConsumer<AddProductCubit, AddProductState>(
        listener: (context, state) {
          if (state is AddProductSuccess) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          String? error;
          bool loading = false;
          if (state is AddProductLoading) loading = true;
          if (state is AddProductError) error = state.message;

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
                        DropdownMenuItem(
                            value: 'product', child: Text('Produto')),
                        DropdownMenuItem(
                            value: 'service', child: Text('Serviço')),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'product'),
                      decoration: const InputDecoration(labelText: 'Tipo'),
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe a descrição' : null,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o preço' : null,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _stockController,
                      decoration: const InputDecoration(
                          labelText: 'Estoque (opcional)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.next,
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
                    if (error != null) ...[
                      const SizedBox(height: 8),
                      Text(error, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AddProductCubit>().submit(
                                      type: _type,
                                      name: _nameController.text,
                                      description: _descriptionController.text,
                                      price: _priceController.text,
                                      stock: _stockController.text,
                                      leadTimeDays: _leadTimeController.text,
                                      isAvailable: _isAvailable,
                                    );
                              }
                            },
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
