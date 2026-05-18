# 📍 Address Feature - Cadastro de Endereço

Tela de cadastro de endereço seguindo o padrão do onboarding.

## 🎯 Estrutura

```
lib/features/address/
├── cubit/
│   ├── address_state.dart    # Estado do endereço
│   └── address_cubit.dart    # Lógica de negócio
└── view/
    └── address_view.dart     # Interface visual
```

## 🚀 Como Usar

### **1. Registrar no Dependency Injection**

Adicione em `lib/core/di/injection_container.dart`:

```dart
// Cubits
sl.registerFactory(() => AddressCubit(sl<Dio>(), sl<GeolocatorPlatform>(), sl<AddressRepository>(), sl<SharedPreferences>()));
```

### **2. Navegar para a Tela**

**IMPORTANTE:** O mesmo cubit é reutilizado entre as telas da feature Address para manter estado persistente.

```dart
// Para LISTAR endereços (primeira navegação)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<AddressCubit>()..initialize(), // ← Cria cubit e carrega lista
      child: const AddressListView(),
    ),
  ),
);

// Para CRIAR novo endereço (navegação interna)
final cubit = context.read<AddressCubit>();
cubit.resetForm(); // Limpa campos do formulário
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: cubit, // ← Reusa o mesmo cubit
      child: const AddressView(),
    ),
  ),
);

// Para EDITAR endereço (navegação interna)
final cubit = context.read<AddressCubit>();
cubit.loadAddress(address); // Carrega dados do endereço
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider.value(
      value: cubit, // ← Reusa o mesmo cubit
      child: const AddressView(),
    ),
  ),
);
```

## 🎨 Funcionalidades

### **1. Usar Localização Atual**
- Botão "Usar Localização"
- Usa `geolocator` + `geocoding`
- Preenche automaticamente:
  - ✅ Logradouro
  - ✅ Bairro
  - ✅ Cidade
  - ✅ Estado
  - ✅ CEP (aproximado)
  - ⚠️ Número e Complemento (usuário preenche)

### **2. Buscar por CEP**
- Botão "Digitar CEP" ou campo CEP
- Busca automática ao digitar 8 números
- APIs usadas (com fallback):
  1. **ViaCEP** (principal)
  2. **BrasilAPI** (fallback)
- Preenche automaticamente:
  - ✅ Logradouro
  - ✅ Bairro
  - ✅ Cidade
  - ✅ Estado
  - ⚠️ Número e Complemento (usuário preenche)

### **3. Validação**
- Todos os campos obrigatórios exceto Complemento
- CEP: formato 00000-000
- Estado: 2 letras (UF)
- Validação em tempo real

## 📱 Layout

- ✅ Header com botão voltar
- ✅ Ícone de localização
- ✅ Título e descrição
- ✅ Dois botões de ação rápida
- ✅ Formulário com validação
- ✅ Mensagens de erro amigáveis
- ✅ Loading indicator
- ✅ Tema dark/light mode compatível

## 🔄 Estado (AddressState)

```dart
{
  isLoading: bool,
  errorMessage: String?,
  cep: String?,
  street: String?,
  number: String?,
  complement: String?,
  neighborhood: String?,
  city: String?,
  state: String?,
  latitude: double?,
  longitude: double?,
}
```

## 📝 TODO

- [ ] Integrar com Supabase/backend para salvar endereço
- [ ] Adicionar lista de endereços salvos
- [ ] Permitir múltiplos endereços
- [ ] Marcar endereço como principal
- [ ] Integração com mapa (Google Maps/Mapbox)
- [ ] Validação de logradouro inexistente
