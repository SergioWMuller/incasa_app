import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/widgets/design/neumorphic_surface.dart';
import 'package:incasa_app/domain/entities/profile/address.dart';
import 'package:incasa_app/features/address/cubit/address_cubit.dart';
import 'package:incasa_app/features/address/cubit/address_state.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePrimary;

  const AddressCard({
    super.key,
    required this.address,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePrimary,
  });

  @override
  Widget build(BuildContext context) {
    return NeumorphicSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (address.label != null && address.label!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        address.label!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          if (address.complement != null && address.complement!.isNotEmpty) ...[
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: address.addressId == state.currentPrimaryAddressId,
                      onChanged: (value) => onTogglePrimary(value),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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
