import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_state.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  late final TextEditingController _cepController;
  late final TextEditingController _streetController;
  late final TextEditingController _numberController;
  late final TextEditingController _complementController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final state = context.read<AddressCubit>().state;
    _cepController = TextEditingController(text: state.cep);
    _streetController = TextEditingController(text: state.street);
    _numberController = TextEditingController(text: state.number);
    _complementController = TextEditingController(text: state.complement);
    _neighborhoodController = TextEditingController(text: state.neighborhood);
    _cityController = TextEditingController(text: state.city);
    _stateController = TextEditingController(text: state.state);
  }

  @override
  void dispose() {
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddressCubit>();

    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        // Atualiza os controllers quando o state muda (ex: após buscar CEP)
        if (_cepController.text != state.cep && state.cep != null) {
          _cepController.text = state.cep!;
        }
        if (_streetController.text != state.street && state.street != null) {
          _streetController.text = state.street!;
        }
        if (_neighborhoodController.text != state.neighborhood &&
            state.neighborhood != null) {
          _neighborhoodController.text = state.neighborhood!;
        }
        if (_cityController.text != state.city && state.city != null) {
          _cityController.text = state.city!;
        }
        if (_stateController.text != state.state && state.state != null) {
          _stateController.text = state.state!;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header integrado
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        'Cadastrar Endereço',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ícone
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  // Título e Descrição
                  Center(
                    child: Text(
                      'Complete seu Endereço',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Para preencher automaticamente pode\nusar sua localização ou digite seu CEP',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botão de ação rápida
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => cubit.useCurrentLocation(),
                      icon: const Icon(Icons.my_location, size: 20),
                      label: const Text('Usar Minha Localização'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Mensagem de erro
                  if (state.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Loading indicator
                  if (state.isLoading) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Formulário
                  _buildForm(context, state, cubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(
    BuildContext context,
    AddressState state,
    AddressCubit cubit,
  ) {
    return Form(
      key: _formKey,
      autovalidateMode: state.enableValidation
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        children: [
          // CEP
          TextFormField(
            controller: _cepController,
            decoration: const InputDecoration(
              labelText: 'CEP',
              hintText: '00000-000',
              prefixIcon: Icon(Icons.mail),
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              helperText: ' ',
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
              TextInputFormatter.withFunction((oldValue, newValue) {
                final formatted = cubit.formatCep(newValue.text);
                return TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }),
            ],
            onChanged: (value) {
              cubit.onCepChanged(value);
            },
            validator: (value) => cubit.validateCep(value),
          ),
          const SizedBox(height: 8),

          // Logradouro
          TextFormField(
            controller: _streetController,
            decoration: const InputDecoration(
              labelText: 'Logradouro',
              hintText: 'Rua, Avenida, etc',
              prefixIcon: Icon(Icons.signpost),
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              helperText: ' ',
            ),
            textInputAction: TextInputAction.next,
            validator: cubit.validateRequired,
          ),
          const SizedBox(height: 8),

          // Número e Complemento
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: 'Número',
                    hintText: '123',
                    prefixIcon: Icon(Icons.onetwothree),
                    border: OutlineInputBorder(),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    helperText: ' ',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: cubit.validateRequired,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _complementController,
                  decoration: const InputDecoration(
                    labelText: 'Complemento',
                    hintText: 'Apto, Bloco',
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(),
                    helperText: ' ',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bairro
          TextFormField(
            controller: _neighborhoodController,
            decoration: const InputDecoration(
              labelText: 'Bairro',
              hintText: 'Nome do bairro',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              helperText: ' ',
            ),
            textInputAction: TextInputAction.next,
            validator: cubit.validateRequired,
          ),
          const SizedBox(height: 8),

          // Cidade
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Cidade',
              hintText: 'Nome da cidade',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              helperText: ' ',
            ),
            textInputAction: TextInputAction.next,
            validator: cubit.validateRequired,
          ),
          const SizedBox(height: 8),

          // Estado
          TextFormField(
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'Estado',
              hintText: 'UF',
              prefixIcon: Icon(Icons.map),
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              helperText: ' ',
            ),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              LengthLimitingTextInputFormatter(2),
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
            ],
            validator: cubit.validateState,
          ),

          const SizedBox(height: 32),

          // Botão Salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        // Sincroniza os valores dos controllers com o state
                        cubit.updateField(
                          cep: _cepController.text,
                          street: _streetController.text,
                          number: _numberController.text,
                          complement: _complementController.text,
                          neighborhood: _neighborhoodController.text,
                          city: _cityController.text,
                          stateUf: _stateController.text,
                        );

                        // TODO: Implementar salvamento no backend
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Endereço salvo com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.of(context).pop(true);
                      } else {
                        cubit.enableFormValidation();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Salvar Endereço',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
