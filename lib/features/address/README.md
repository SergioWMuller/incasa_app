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
sl.registerFactory(() => AddressCubit(sl<Dio>()));
```

### **2. Navegar para a Tela**

```dart
// Usando Navigator
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => sl<AddressCubit>(),
      child: const AddressView(),
    ),
  ),
);

// Ou usando GoRouter (exemplo)
GoRoute(
  path: '/address',
  builder: (context, state) {
    return BlocProvider(
      create: (context) => sl<AddressCubit>(),
      child: const AddressView(),
    );
  },
),
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
