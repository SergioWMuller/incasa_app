import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/domain/entities/marketplace/product.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/my_store_state.dart';

/// View StatelessWidget seguindo o padrão do projeto
class AddProductView extends StatelessWidget {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Produto')),
      body: const _AddProductForm(),
    );
  }
}

/// StatefulWidget apenas para gerenciar TextEditingControllers
class _AddProductForm extends StatefulWidget {
  const _AddProductForm();

  @override
  State<_AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<_AddProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _estoqueController = TextEditingController();
  final _prazoProducaoController = TextEditingController();
  // final _prazoEntregaController = TextEditingController(); // Comentado temporariamente
  final _prazoMinimoEncomendaController = TextEditingController();

  String _tipo = 'produto';
  bool _disponivelVenda = true;
  bool _prontaEntrega = true;
  bool _aceitaEncomenda = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _estoqueController.dispose();
    _prazoProducaoController.dispose();
    // _prazoEntregaController.dispose(); // Comentado temporariamente
    _prazoMinimoEncomendaController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      tipo: _tipo,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text.replaceAll(',', '.')),
      imageUrl: _imageUrlController.text.isEmpty
          ? 'https://via.placeholder.com/300'
          : _imageUrlController.text,
      category: _categoryController.text,
      estoque: _estoqueController.text.isEmpty
          ? null
          : int.tryParse(_estoqueController.text),
      prazoProducaoDias: _prazoProducaoController.text.isEmpty
          ? null
          : int.tryParse(_prazoProducaoController.text),
      prazoEntregaHoras: null, // Comentado temporariamente
      prazoMinimoEncomendaDias: _prazoMinimoEncomendaController.text.isEmpty
          ? null
          : int.tryParse(_prazoMinimoEncomendaController.text),
      disponivelVenda: _disponivelVenda,
      prontaEntrega: _prontaEntrega,
      aceitaEncomenda: _aceitaEncomenda,
      createdAt: DateTime.now(),
    );

    // Cubit gerencia o estado de loading; o retorno só chega depois da
    // confirmação (sucesso ou erro) da chamada ao Supabase.
    final success = await sl<MyStoreCubit>().addProduct(product);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produto salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final errorMessage = sl<MyStoreCubit>().state.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyStoreCubit, MyStoreState>(
      bloc: sl<MyStoreCubit>(),
      builder: (context, state) {
        final isLoading = state.isAddingProduct;

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tipo: Produto ou Serviço
              DropdownButtonFormField<String>(
                initialValue: _tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'produto', child: Text('Produto')),
                  DropdownMenuItem(value: 'servico', child: Text('Serviço')),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  final price = double.tryParse(value.replaceAll(',', '.'));
                  if (price == null || price <= 0) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // TODO: Implementar upload de foto
              // TextFormField(
              //   controller: _imageUrlController,
              //   decoration: const InputDecoration(
              //     labelText: 'Foto do Produto',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.photo_camera),
              //     hintText: 'Adicionar foto...',
              //   ),
              // ),
              // const SizedBox(height: 16),
              TextFormField(
                controller: _estoqueController,
                decoration: const InputDecoration(
                  labelText: 'Estoque (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prazoProducaoController,
                decoration: const InputDecoration(
                  labelText: 'Prazo de Produção - dias (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   controller: _prazoEntregaController,
              //   decoration: const InputDecoration(
              //     labelText: 'Prazo de Entrega - horas (opcional)',
              //     border: OutlineInputBorder(),
              //     prefixIcon: Icon(Icons.delivery_dining),
              //     hintText: '0',
              //   ),
              //   keyboardType: TextInputType.number,
              //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Já está disponível para venda'),
                subtitle: Text(
                  _disponivelVenda ? 'Produto visível' : 'Produto oculto',
                ),
                value: _disponivelVenda,
                onChanged: (value) {
                  setState(() {
                    _disponivelVenda = value;
                  });
                },
                secondary: Icon(
                  _disponivelVenda ? Icons.visibility : Icons.visibility_off,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Comercializado a pronta entrega'),
                subtitle: Text(
                  _prontaEntrega
                      ? 'Aceita pronta entrega'
                      : 'Não aceita pronta entrega',
                ),
                value: _prontaEntrega,
                onChanged: (value) {
                  setState(() {
                    _prontaEntrega = value;
                  });
                },
                secondary: Icon(
                  _prontaEntrega
                      ? Icons.delivery_dining
                      : Icons.delivery_dining_outlined,
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponível para encomendas'),
                subtitle: Text(
                  _aceitaEncomenda
                      ? 'Aceita encomendas'
                      : 'Não aceita encomendas',
                ),
                value: _aceitaEncomenda,
                onChanged: (value) {
                  setState(() {
                    _aceitaEncomenda = value;
                  });
                },
                secondary: Icon(
                  _aceitaEncomenda ? Icons.event : Icons.event_outlined,
                ),
              ),
              // Campo condicional: Prazo mínimo para encomenda
              if (_aceitaEncomenda) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: TextFormField(
                    controller: _prazoMinimoEncomendaController,
                    decoration: const InputDecoration(
                      labelText: 'Prazo mínimo para preparar encomenda - dias',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                      hintText: '0',
                      helperText:
                          'Dias necessários para produzir sob encomenda',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _saveProduct,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(isLoading ? 'Salvando...' : 'Salvar Produto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
