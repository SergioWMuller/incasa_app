import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/constants/br_states_constants.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_state.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';

class AddressView extends StatelessWidget {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final scrollController = ScrollController();
    return BlocListener<AddressCubit, AddressState>(
      listenWhen: (previous, current) {
        // Só escuta quando latitude/longitude mudarem (preenchimento novo)
        return previous.latitude != current.latitude ||
            previous.longitude != current.longitude;
      },
      listener: (context, state) {
        if (state.status == AddressStatus.success &&
            state.latitude != null &&
            state.longitude != null) {
          scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Endereço preenchido com base na localização!'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      },
      child: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          final cubit = context.read<AddressCubit>();
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text(
                          state.addressId == null
                              ? 'Cadastrar Endereço'
                              : 'Editar Endereço',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Center(
                      child: NeumorphicSurface(
                        constraints: const BoxConstraints.tightFor(
                          width: 80,
                          height: 80,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
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

                    if (state.isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Form(
                      key: formKey,
                      autovalidateMode: state.enableValidation
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          TextFormField(
                            key: ValueKey('cep_${state.autoCompleteKey}'),
                            initialValue: state.zipCode,
                            decoration: const InputDecoration(
                              labelText: 'CEP',
                              hintText: '00000-000',
                              prefixIcon: Icon(Icons.mail),
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              helperText: ' ',
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                final formatted = cubit.formatCep(
                                  newValue.text,
                                );
                                return TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                    offset: formatted.length,
                                  ),
                                );
                              }),
                            ],
                            onChanged: cubit.setZipCode,
                            validator: cubit.validateCep,
                          ),
                          const SizedBox(height: 8),

                          DropdownButtonFormField<AddressType>(
                            key: ValueKey('type_${state.autoCompleteKey}'),
                            value: state.addressType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                              helperText: ' ',
                            ),
                            items: AddressType.values.map((type) {
                              return DropdownMenuItem<AddressType>(
                                value: type,
                                child: Text(type.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) cubit.setAddressType(value);
                            },
                          ),

                          Row(
                            children: [
                              Switch(
                                value: state.isPrimary,
                                onChanged: state.canChangePrimary
                                    ? (value) => cubit.setIsPrimary(value)
                                    : null, // Desabilita se não pode mudar
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.canChangePrimary
                                      ? 'Este é seu endereço principal'
                                      : 'Este é seu primeiro endereço (principal por padrão)',
                                  style: TextStyle(
                                    color: state.canChangePrimary
                                        ? null
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            key: ValueKey('street_${state.autoCompleteKey}'),
                            initialValue: state.street,
                            decoration: const InputDecoration(
                              labelText: 'Logradouro',
                              hintText: 'Rua, Avenida, etc',
                              prefixIcon: Icon(Icons.signpost),
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              helperText: ' ',
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: cubit.setStreet,
                            validator: cubit.validateRequired,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            key: ValueKey('label_${state.autoCompleteKey}'),
                            initialValue: state.label,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Ex: Casa da mãe',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.label),
                              helperText: ' ',
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: cubit.setLabel,
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  key: ValueKey(
                                    'number_${state.autoCompleteKey}',
                                  ),
                                  initialValue: state.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Número',
                                    hintText: '123',
                                    prefixIcon: Icon(Icons.onetwothree),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    helperText: ' ',
                                  ),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  onChanged: cubit.setNumber,
                                  validator: cubit.validateRequired,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  key: ValueKey(
                                    'complement_${state.autoCompleteKey}',
                                  ),
                                  initialValue: state.complement,
                                  decoration: const InputDecoration(
                                    labelText: 'Complemento',
                                    hintText: 'Apto, Bloco',
                                    prefixIcon: Icon(Icons.home),
                                    border: OutlineInputBorder(),
                                    helperText: ' ',
                                  ),
                                  textInputAction: TextInputAction.next,
                                  onChanged: cubit.setComplement,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            key: ValueKey(
                              'neighborhood_${state.autoCompleteKey}',
                            ),
                            initialValue: state.neighborhood,
                            decoration: const InputDecoration(
                              labelText: 'Bairro',
                              hintText: 'Nome do bairro',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              helperText: ' ',
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: cubit.setNeighborhood,
                            validator: cubit.validateRequired,
                          ),
                          const SizedBox(height: 8),

                          TextFormField(
                            key: ValueKey('city_${state.autoCompleteKey}'),
                            initialValue: state.city,
                            decoration: const InputDecoration(
                              labelText: 'Cidade',
                              hintText: 'Nome da cidade',
                              prefixIcon: Icon(Icons.location_city),
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              helperText: ' ',
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: cubit.setCity,
                            validator: cubit.validateRequired,
                          ),
                          const SizedBox(height: 8),

                          DropdownButtonFormField<String>(
                            key: ValueKey('state_${state.autoCompleteKey}'),
                            value:
                                state.state != null && state.state!.isNotEmpty
                                ? state.state
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              hintText: 'Selecione o estado',
                              prefixIcon: Icon(Icons.map),
                              border: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              helperText: ' ',
                            ),
                            items: BrStates.states.map((state) {
                              return DropdownMenuItem<String>(
                                value: state.uf,
                                child: Text(state.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) cubit.setState(value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () async {
                                      if (formKey.currentState!.validate()) {
                                        final success = await cubit
                                            .saveAddress();

                                        if (success && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Endereço salvo com sucesso!',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          Navigator.of(context).pop(true);
                                        } else if (!success &&
                                            context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                cubit.state.errorMessage ??
                                                    'Erro ao salvar endereço',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      } else {
                                        cubit.enableFormValidation();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
