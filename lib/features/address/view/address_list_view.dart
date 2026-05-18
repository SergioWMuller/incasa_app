import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_state.dart';
import 'package:incasa_app/features/address/view/address_view.dart';

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
              itemCount: state.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return _AddressCard(
                  address: address,
                  onTap: () => _navigateToEditAddress(context, address),
                  onDelete: () => _confirmDelete(context, address),
                  onTogglePrimary: (value) =>
                      _togglePrimaryAddress(context, address),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          // Oculta todos os FABs se já tiver 6 ou mais endereços
          if (state.addresses.length >= 6) {
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
                  onPressed: () => _savePrimaryChanges(context),
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Alterações'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                // FAB Novo Endereço (mantém visível)
                FloatingActionButton.extended(
                  heroTag: 'add_fab',
                  onPressed: () => _navigateToAddAddress(context),
                  icon: const Icon(Icons.add_location),
                  label: const Text('Novo Endereço'),
                ),
              ],
            );
          }

          // FAB normal de adicionar endereço (quando não há mudanças pendentes)
          return FloatingActionButton.extended(
            heroTag: 'add_fab',
            onPressed: () => _navigateToAddAddress(context),
            icon: const Icon(Icons.add_location),
            label: const Text('Novo Endereço'),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddAddress(BuildContext context) async {
    final cubit = context.read<AddressCubit>();

    // Limpa o formulário antes de criar novo endereço
    cubit.resetForm();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit, // Reusa o mesmo cubit
          child: const AddressView(),
        ),
      ),
    );

    if (result == true && context.mounted) {
      cubit.refresh();
    }
  }

  Future<void> _navigateToEditAddress(
    BuildContext context,
    Address address,
  ) async {
    final cubit = context.read<AddressCubit>();

    // Carrega dados do endereço no formulário
    cubit.loadAddress(address);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit, // Reusa o mesmo cubit
          child: const AddressView(),
        ),
      ),
    );

    if (result == true && context.mounted) {
      cubit.refresh();
    }
  }

  Future<void> _confirmDelete(BuildContext context, Address address) async {
    // Verifica se o endereço é principal (apenas endereço realmente salvo como principal)
    if (address.isPrimary) {
      // Mostra mensagem informativa se for o endereço principal
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Endereço Principal'),
          content: const Text(
            'Seu endereço principal não pode ser apagado.\n\n'
            'Para apagar este endereço, primeiro defina outro endereço como principal.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }

    // Se não for principal, mostra diálogo de confirmação normal
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Endereço'),
        content: Text(
          'Tem certeza que deseja deletar o endereço:\n\n'
          '${address.street}, ${address.number ?? "S/N"}\n'
          '${address.city} - ${address.state}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<AddressCubit>().deleteAddress(
        address.addressId!,
      );

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
  }

  Future<void> _togglePrimaryAddress(
    BuildContext context,
    Address address,
  ) async {
    // Apenas marca localmente, não salva no DB
    context.read<AddressCubit>().setTemporaryPrimaryAddress(address.addressId!);
  }

  Future<void> _savePrimaryChanges(BuildContext context) async {
    final success = await context.read<AddressCubit>().savePrimaryChanges();

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Endereço principal alterado com sucesso!'),
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
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePrimary;

  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAddressTypeIcon(address.addressType),
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.addressType.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (address.label != null &&
                            address.label!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            address.label!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildAddressRow(
                context,
                Icons.signpost,
                '${address.street}, ${address.number ?? "S/N"}',
              ),
              if (address.complement != null &&
                  address.complement!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildAddressRow(context, Icons.home, address.complement!),
              ],
              if (address.neighborhood != null &&
                  address.neighborhood!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _buildAddressRow(
                  context,
                  Icons.location_city,
                  address.neighborhood!,
                ),
              ],
              const SizedBox(height: 6),
              _buildAddressRow(
                context,
                Icons.map,
                '${address.city} - ${address.state}',
              ),
              if (address.zipCode != null && address.zipCode!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.mail,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      address.zipCode!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    if (address.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Principal',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              BlocBuilder<AddressCubit, AddressState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Deixar este como principal?',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value:
                              address.addressId ==
                              state.currentPrimaryAddressId,
                          onChanged: (value) => onTogglePrimary(value),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  IconData _getAddressTypeIcon(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home;
      case AddressType.work:
        return Icons.work;
      case AddressType.billing:
        return Icons.receipt;
      case AddressType.shipping:
        return Icons.local_shipping;
      case AddressType.other:
        return Icons.location_on;
    }
  }
}
