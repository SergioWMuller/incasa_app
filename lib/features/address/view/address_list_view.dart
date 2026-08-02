import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_state.dart';
import 'package:incasa_app/features/address/view/address_view.dart';
import 'package:incasa_app/features/address/widgets/address_card_widget.dart';
import 'package:incasa_app/features/address/widgets/address_primary_dialog_widget.dart';
import 'package:incasa_app/features/address/widgets/address_delete_confirmation_dialog_widget.dart';

class AddressListView extends StatelessWidget {
  const AddressListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Endereços'), centerTitle: true),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          // Mostra loading apenas se estiver carregando OU se estiver inicial E sem endereços
          if (state.isLoading || (state.isInitial && state.addresses.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar endereços',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Erro desconhecido',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<AddressCubit>().refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            );
          }

          if (state.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withAlpha(128),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Você ainda não tem\nendereço cadastrado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Adicione seu primeiro endereço\nusando o botão abaixo',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<AddressCubit>().refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.addresses.length) {
                  return const SizedBox(height: 48);
                }
                final address = state.addresses[index];
                return AddressCard(
                  address: address,
                  onTap: () async {
                    final cubit = context.read<AddressCubit>();
                    cubit.loadAddress(address);

                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const AddressView(),
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      cubit.refresh();
                    }
                  },
                  onDelete: () async {
                    if (address.isPrimary) {
                      await showAddressPrimaryDialog(context);
                      return;
                    }

                    final confirmed = await showAddressDeleteConfirmationDialog(
                      context,
                      street: address.street,
                      number: address.number,
                      city: address.city,
                      state: address.state,
                    );

                    if (confirmed && context.mounted) {
                      final success = await context
                          .read<AddressCubit>()
                          .deleteAddress(address.addressId!);

                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Endereço deletado com sucesso'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.read<AddressCubit>().state.errorMessage ??
                                  'Erro ao deletar endereço',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  onTogglePrimary: (value) {
                    context.read<AddressCubit>().setTemporaryPrimaryAddress(
                      address.addressId!,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          // Oculta todos os FABs se já tiver 4 ou mais endereços
          if (state.addresses.length >= 4) {
            return const SizedBox.shrink();
          }

          // Se há mudanças pendentes, mostra FAB de salvar + FAB de adicionar
          if (state.hasPendingPrimaryChanges) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // FAB Salvar Alterações
                FloatingActionButton.extended(
                  heroTag: 'save_fab',
                  onPressed: () async {
                    final success = await context
                        .read<AddressCubit>()
                        .savePrimaryChanges();

                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Endereço principal alterado com sucesso!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<AddressCubit>().state.errorMessage ??
                                'Erro ao alterar endereço principal',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Alterações'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                // FAB Novo Endereço (mantém visível)
                FloatingActionButton.extended(
                  heroTag: 'add_fab',
                  onPressed: () async {
                    final cubit = context.read<AddressCubit>();
                    cubit.resetForm();

                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: const AddressView(),
                        ),
                      ),
                    );

                    if (result == true && context.mounted) {
                      cubit.refresh();
                    }
                  },
                  icon: const Icon(Icons.add_location),
                  label: const Text('Novo Endereço'),
                ),
              ],
            );
          }

          // FAB normal de adicionar endereço (quando não há mudanças pendentes)
          return FloatingActionButton.extended(
            heroTag: 'add_fab',
            onPressed: () async {
              final cubit = context.read<AddressCubit>();
              cubit.resetForm();

              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: cubit,
                    child: const AddressView(),
                  ),
                ),
              );

              if (result == true && context.mounted) {
                cubit.refresh();
              }
            },
            icon: const Icon(Icons.add_location),
            label: const Text('Novo Endereço'),
          );
        },
      ),
    );
  }
}
