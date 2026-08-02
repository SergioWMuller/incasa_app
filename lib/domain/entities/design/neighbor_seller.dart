import 'package:equatable/equatable.dart';

/// Vizinho vendendo hoje (carrossel da tela Início do design handoff).
class NeighborSeller extends Equatable {
  final String id;
  final String name;
  final String distanceLabel;

  const NeighborSeller({
    required this.id,
    required this.name,
    required this.distanceLabel,
  });

  @override
  List<Object?> get props => [id, name, distanceLabel];
}
