/// Estados brasileiros com suas siglas
class BrState {
  final String name;
  final String uf;

  const BrState({required this.name, required this.uf});

  String get displayName => '$name - $uf';

  @override
  String toString() => displayName;
}

/// Lista completa dos 27 estados brasileiros ordenados alfabeticamente
class BrStates {
  static const List<BrState> states = [
    BrState(name: 'Acre', uf: 'AC'),
    BrState(name: 'Alagoas', uf: 'AL'),
    BrState(name: 'Amapá', uf: 'AP'),
    BrState(name: 'Amazonas', uf: 'AM'),
    BrState(name: 'Bahia', uf: 'BA'),
    BrState(name: 'Ceará', uf: 'CE'),
    BrState(name: 'Distrito Federal', uf: 'DF'),
    BrState(name: 'Espírito Santo', uf: 'ES'),
    BrState(name: 'Goiás', uf: 'GO'),
    BrState(name: 'Maranhão', uf: 'MA'),
    BrState(name: 'Mato Grosso', uf: 'MT'),
    BrState(name: 'Mato Grosso do Sul', uf: 'MS'),
    BrState(name: 'Minas Gerais', uf: 'MG'),
    BrState(name: 'Pará', uf: 'PA'),
    BrState(name: 'Paraíba', uf: 'PB'),
    BrState(name: 'Paraná', uf: 'PR'),
    BrState(name: 'Pernambuco', uf: 'PE'),
    BrState(name: 'Piauí', uf: 'PI'),
    BrState(name: 'Rio de Janeiro', uf: 'RJ'),
    BrState(name: 'Rio Grande do Norte', uf: 'RN'),
    BrState(name: 'Rio Grande do Sul', uf: 'RS'),
    BrState(name: 'Rondônia', uf: 'RO'),
    BrState(name: 'Roraima', uf: 'RR'),
    BrState(name: 'Santa Catarina', uf: 'SC'),
    BrState(name: 'São Paulo', uf: 'SP'),
    BrState(name: 'Sergipe', uf: 'SE'),
    BrState(name: 'Tocantins', uf: 'TO'),
  ];

  /// Converte nome do estado (completo ou abreviado) para sigla UF
  /// Exemplos: "Paraná" -> "PR", "PR" -> "PR", "parana" -> "PR"
  static String? nameToUf(String? stateName) {
    if (stateName == null || stateName.isEmpty) return null;

    final normalized = stateName.trim();

    // Se já é uma sigla válida (2 caracteres), retorna em uppercase
    if (normalized.length == 2) {
      final uf = normalized.toUpperCase();
      if (states.any((state) => state.uf == uf)) {
        return uf;
      }
    }

    // Busca pelo nome do estado (case-insensitive)
    final state = states.firstWhere(
      (s) => s.name.toLowerCase() == normalized.toLowerCase(),
      orElse: () => const BrState(name: '', uf: ''),
    );

    return state.uf.isNotEmpty ? state.uf : null;
  }

  /// Converte sigla UF para nome completo do estado
  /// Exemplo: "PR" -> "Paraná"
  static String? ufToName(String? uf) {
    if (uf == null || uf.isEmpty) return null;

    final state = states.firstWhere(
      (s) => s.uf == uf.toUpperCase(),
      orElse: () => const BrState(name: '', uf: ''),
    );

    return state.name.isNotEmpty ? state.name : null;
  }

  /// Busca um BrState pela sigla UF
  static BrState? findByUf(String? uf) {
    if (uf == null || uf.isEmpty) return null;

    try {
      return states.firstWhere((s) => s.uf == uf.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}
