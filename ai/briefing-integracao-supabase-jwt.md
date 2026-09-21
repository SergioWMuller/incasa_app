# Briefing — Integração final do JWT Supabase no app Flutter (inCasa)

## Contexto

O fluxo de autenticação Firebase → Edge Function → Supabase JWT já foi testado ponta a ponta e está **funcionando corretamente no backend**. O app Flutter faz login com Google, obtém o ID Token do Firebase, chama a Edge Function `auth-firebase`, e recebe de volta um JWT do Supabase válido (HS256, 1h de validade, `sub` = Firebase UID, `role = authenticated`).

Log de confirmação do teste bem-sucedido (Passo 5 do fluxo de login):

```
statusCode: 200
Response: {"success":true,"user_id":"fa02b0d4-80d8-4bef-bbb5-edd57c6b8ab9","is_new_user":false,"is_new_provider":false,"firebase_uid":"6M2nFvnGDDhcDPOwqW1y2hlM9kw1","email":"sergio.swm@gmail.com","display_name":"Sergio Müller","photo_url":"...","provider":"google","supabase_jwt":"eyJhbGciOiJIUzI1NiJ9..."}
```

Apesar do sucesso da Edge Function, duas falhas aparecem **na sequência**, no mesmo log de teste, e ambas precisam ser corrigidas agora:

```
[AUTH] Falha ao buscar usuário no Supabase após login: Exception: Erro ao buscar usuário no Supabase: PostgrestException(message: Unauthorized, code: 401, details: Unauthorized, hint: null)

W/Firestore: Listen for Query(target=Query(users/6M2nFvnGDDhcDPOwqW1y2hlM9kw1 order by __name__);limitType=LIMIT_TO_FIRST) failed: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
```

## Endpoint e credenciais de referência

- Servidor Supabase self-hosted: `http://49.13.158.137:8000`
- Endpoint da Edge Function: `http://49.13.158.137:8000/functions/v1/auth-firebase`
- Método: `POST`, body: `{"id_token": "<firebase_id_token>"}`
- Resposta em caso de sucesso: JSON contendo `supabase_jwt` (string JWT pronta para uso), além de `user_id`, `is_new_user`, `is_new_provider`, `firebase_uid`, `email`, `display_name`, `photo_url`, `provider`.
- **Atenção:** o IP antigo `91.98.84.101` está desativado — nunca usar esse IP em nenhuma referência, teste, ou configuração. O único servidor ativo é `49.13.158.137`.

## Tarefa 1 — Integrar o `supabase_jwt` no callback `accessToken` do `supabase_flutter`

**Problema:** a Edge Function já devolve o `supabase_jwt` corretamente, mas o app não está usando esse token nas chamadas seguintes ao PostgREST — por isso as consultas ao Supabase (ex.: buscar o usuário logado) retornam `401 Unauthorized`, mesmo o login tendo sido bem-sucedido.

**O que fazer:**

1. Localizar onde o `supabase_flutter` é inicializado no projeto (provavelmente em `main.dart` ou um arquivo de bootstrap/inicialização).
2. Configurar o client do Supabase para usar um `accessToken` callback (função assíncrona) que retorna o JWT emitido pela Edge Function `auth-firebase`, em vez de usar (ou não usar) nenhum token.
3. Esse callback deve:
   - Retornar o `supabase_jwt` mais recente obtido no login, armazenado em algum estado/serviço de sessão local do app.
   - Se o JWT estiver perto de expirar ou já expirado (validade de 1 hora), deve chamar novamente a Edge Function `auth-firebase` com um ID Token do Firebase atualizado (`FirebaseAuth.instance.currentUser?.getIdToken(true)` força renovação) para obter um novo `supabase_jwt`, e armazenar esse novo valor antes de retorná-lo.
4. Garantir que esse `supabase_jwt` seja persistido (em memória ou storage seguro local) logo após o Passo 5 do fluxo de login atual (que já loga `✅ [AUTH] Passo 5 OK: Edge Function respondeu`), para que o callback `accessToken` tenha o valor disponível imediatamente após o login.
5. Após implementar, o fluxo esperado é: login Firebase → Edge Function retorna `supabase_jwt` → esse JWT é armazenado → toda chamada subsequente ao Supabase (PostgREST) via `supabase_flutter` usa esse JWT automaticamente através do callback → a busca do usuário logado no Supabase deve funcionar sem erro 401.

**Critério de sucesso:** repetir o fluxo de login e confirmar que a mensagem de erro `Falha ao buscar usuário no Supabase após login... PostgrestException(... 401 ...)` não aparece mais nos logs, e que os dados do usuário são carregados corretamente do Supabase após o login.

## Tarefa 2 — Remover a chamada legada ao Firestore

**Problema:** o app ainda tenta ler o documento `users/<firebase_uid>` diretamente do Firestore, o que gera o erro:
```
PERMISSION_DENIED: Missing or insufficient permissions.
```
Essa leitura é resquício de uma arquitetura anterior. O projeto **não usa mais o Firestore como fonte de dados de usuário** — os dados de usuário vivem inteiramente no Supabase self-hosted (tabela `public.users`), acessados via PostgREST/RLS usando o `supabase_jwt`.

**O que fazer:**

1. Localizar, em todo o código-fonte do app, qualquer chamada que leia ou escute (`listen`/`snapshot`/`get`) o documento `users/<uid>` no Firestore. O log de erro aponta explicitamente para essa query:
   ```
   Query(target=Query(users/6M2nFvnGDDhcDPOwqW1y2hlM9kw1 order by __name__);limitType=LIMIT_TO_FIRST)
   ```
2. Remover essa chamada por completo (não apenas suprimir o erro/log — remover a leitura do Firestore em si, incluindo qualquer listener/stream associado a ela).
3. Confirmar que nenhuma outra parte do app depende dessa leitura do Firestore para funcionar (ex.: telas de perfil, splash screen, verificação de onboarding). Se alguma tela depender desses dados, ela deve ser adaptada para buscar as informações equivalentes do Supabase (tabela `users`) em vez do Firestore.
4. Se houver, no projeto, também uma referência incorreta a uma tabela inexistente chamada `user_auth_providers` (o nome correto no schema atual é `providers`), corrigir essa referência também nesse mesmo momento, já que é uma pendência do mesmo bloco de trabalho.

**Critério de sucesso:** repetir o fluxo de login e confirmar que a mensagem de warning `W/Firestore: ... PERMISSION_DENIED` não aparece mais nos logs.

## Observação final

Depois que as Tarefas 1 e 2 estiverem implementadas e o fluxo de login completo rodar sem esses dois erros, o próximo passo (fora do escopo deste documento, tratado separadamente) será aplicar a migration 006 no backend, que remove as políticas RLS permissivas "Allow all operations" — essa migration está intencionalmente pendente até que este fluxo esteja 100% confirmado funcionando de ponta a ponta a partir do app.
