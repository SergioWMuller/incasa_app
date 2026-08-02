# Teste E2E do fluxo de JWT — Firebase → Edge Function → Supabase RLS

## Contexto

O app **inCasa** usa Firebase Auth (Google Sign-In) para autenticação e Supabase self-hosted (Postgres + PostgREST) como backend. O elo entre os dois é a Edge Function `auth-firebase`, que:

1. Recebe o `id_token` do Firebase.
2. Valida o token e faz upsert do usuário via RPC `upsert_user_with_provider`.
3. Emite um JWT compatível com o Supabase (`sub` = UID do Firebase, `role` = `authenticated`), assinado com o mesmo `JWT_SECRET` do projeto.

O Flutter deveria estar inicializando o `supabase_flutter` com uma função `accessToken` que retorna esse JWT emitido pela Edge Function — **não** o token bruto do Firebase.

**Já foi implementado (segundo o dev):** a emissão do JWT na Edge Function e o consumo dele no Flutter. **Ainda não testado ponta a ponta.**

**Objetivo desta tarefa:** verificar, com evidência concreta (logs, valores impressos, resultado de queries), se esse fluxo está funcionando de verdade — e não presumir que está.

---

## O que fazer

Trabalhe na base de código Flutter deste projeto. Não é necessário mexer no backend/Supabase nesta etapa — apenas instrumentar e rodar o app para coletar evidências.

### Passo 1 — Localizar a inicialização do `supabase_flutter`

Encontre onde o `Supabase.initialize(...)` é chamado (provavelmente em `main.dart` ou um arquivo de bootstrap/config).

- Confirme se existe um parâmetro `accessToken:` (ou equivalente) passado para o client.
- Se existir, identifique a função que ele chama para buscar o JWT.
- Se **não existir**, isso já é um achado importante: significa que o Flutter ainda não está usando o JWT do Supabase e todas as chamadas continuam caindo como `anon`. Reporte isso claramente e pare por aqui (não adianta testar RLS sem essa peça).

### Passo 2 — Localizar onde o JWT é obtido/armazenado

Encontre a função que chama a Edge Function `auth-firebase` (provavelmente um `AuthService`, `AuthRepository` ou similar) e:

- Confirme que a resposta da Edge Function inclui o campo com o JWT do Supabase (algo como `access_token` ou `supabase_jwt` — confirme o nome exato no código, não assuma).
- Confirme onde esse valor é guardado (memória, `SharedPreferences`, `FlutterSecureStorage`, etc.) e como ele é recuperado depois pela função `accessToken` do passo 1.

### Passo 3 — Instrumentar com logs temporários

Adicione `debugPrint` (ou `log()`) temporários nos seguintes pontos:

1. **Logo após a chamada à Edge Function**, imprimindo o JWT recebido (ou pelo menos os primeiros ~40 caracteres, para não poluir o log).
2. **Dentro da função `accessToken`** do `Supabase.initialize`, imprimindo o token retornado a cada chamada.
3. **Antes de uma chamada de leitura à tabela `phones`**, imprimindo o `user_id` esperado (o que o app acha que é o usuário logado).

Exemplo de instrumentação no callback:

```dart
accessToken: () async {
  final token = await getSupabaseJwt();
  debugPrint('[JWT-TEST] accessToken chamado, token: ${token?.substring(0, 40)}...');
  return token;
},
```

### Passo 4 — Rodar o app e fazer login

- Execute o app (emulador ou dispositivo).
- Faça login com Google.
- Capture no console:
  - O JWT retornado pela Edge Function (passo 3.1).
  - O JWT retornado pelo callback `accessToken` (passo 3.2) — **compare se são o mesmo valor**.

Se forem diferentes, ou se o callback nunca for chamado, esse é o ponto de falha — reporte com o trecho de código responsável.

### Passo 5 — Testar uma chamada protegida por RLS

Depois do login, force uma leitura na tabela `phones` (ou crie uma chamada de teste temporária se não houver uma tela que já faça isso):

```dart
final result = await Supabase.instance.client
    .from('phones')
    .select();
debugPrint('[JWT-TEST] Resultado phones: $result');
```

Avalie o resultado:

- **Retornou os telefones do usuário logado** → RLS reconhecendo a identidade corretamente. ✅
- **Retornou vazio**, mesmo sabendo que existem dados no banco para esse usuário → token não está chegando como `authenticated` (provavelmente ainda `anon`). ❌
- **Erro de permissão / 401 / 403** → token ausente, malformado, ou expirado. ❌

### Passo 6 — Decodificar o JWT manualmente (fora do app)

Pegue o valor impresso no passo 4 e cole em https://jwt.io (apenas o payload, não precisa validar assinatura ali). Confirme:

- `sub` = UID do Firebase do usuário que logou
- `role` = `authenticated`
- `exp` no futuro (não expirado)

Se algum desses estiver errado, o problema está na emissão do token pela Edge Function, não no Flutter.

### Passo 7 — Remover a instrumentação

Depois de concluir os testes, remova (ou comente) os `debugPrint` temporários adicionados nos passos 3 e 5, para não deixar logs de token em produção.

---

## Reportar ao final

Ao terminar, produza um resumo objetivo com:

1. **Passo 1**: `accessToken` está configurado? (sim/não + arquivo/linha)
2. **Passo 4**: o JWT da Edge Function e o do callback `accessToken` são idênticos? (sim/não)
3. **Passo 5**: a leitura em `phones` retornou dados do usuário correto, vazio, ou erro? (cole o resultado)
4. **Passo 6**: os claims `sub`, `role` e `exp` do JWT decodificado (cole os valores, sem colar o token completo por segurança)
5. **Diagnóstico**: o fluxo está funcionando ponta a ponta? Se não, em qual passo especificamente quebrou?

Não corrija nada automaticamente — apenas reporte os achados. As correções (se necessárias) serão decididas depois, com base no diagnóstico.
