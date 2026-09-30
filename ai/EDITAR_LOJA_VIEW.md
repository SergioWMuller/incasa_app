# EditarLojaView — Especificação técnica

> **STATUS (2026-09-22): PAUSADA.** O app passou a ter 2 variantes de "Minha
> Loja": (1) esta tela de grid customizável (`EditarLojaView`/`EditarLojaCubit`,
> descrita abaixo) e (2) a vitrine padrão nova, simples e com visual moderno
> (`MyStoreShowcaseTab`, em `lib/features/my_store/widgets/showcase/`), que é
> a usada de fato no MVP. Esta feature (a customizável) **permanece no
> código**, funcional e implementada conforme a spec abaixo, mas foi
> **desconectada do fluxo principal** — não há mais nenhum botão/rota que
> leve o usuário até ela (o gatilho temporário que existia em
> `my_store_loaded_widget.dart` foi removido). Não retome o trabalho nela a
> menos que o usuário peça explicitamente.
>
> Este documento especifica a feature de tela customizável do inCasa: o usuário monta o layout visual da própria loja arrastando, redimensionando e organizando blocos numa grade. Serve como fonte de verdade para a implementação via Claude Code. Não contém código de exemplo pronto — contém contratos, regras e comportamentos que o código deve satisfazer.

---

## 1. Visão geral

`EditarLojaView` é a tela onde o usuário do inCasa monta o layout visual da própria loja: adiciona blocos, posiciona-os numa grade, redimensiona, reorganiza. O resultado desse layout é o que depois será renderizado na tela existente **"Minha Loja"** (fora do escopo deste documento — apenas consome os dados produzidos aqui).

A interação é modelada no estilo "editar home screen" de iOS/Android: o usuário segura um bloco, ele entra em modo de edição (efeito *wiggle*), pode ser arrastado para qualquer posição livre e redimensionado com gesto de pinça.

### 1.1 Não-objetivos deste documento

- Não define como a tela "Minha Loja" renderiza o resultado final (fora de escopo).
- Não define o schema definitivo do Supabase (será tratado em etapa seguinte, após este documento).
- Não define o fluxo de cadastro de produtos (assume que produtos já existem e são consultáveis).

---

## 2. Restrição arquitetural obrigatória

Esta regra é **inegociável** e vale para toda a feature:

- **Todo widget vive em um arquivo separado.**
- **Todo widget é obrigatoriamente `StatelessWidget`.** Nenhum `StatefulWidget` em nenhuma camada desta feature.
- **Toda a gerência de estado é feita por um único `Cubit` chamado `CubitEditarLoja`.**
- **Toda variável mutável da tela vive na state do Cubit (`EditarLojaState`).** Nenhum estado local em widget, nenhum `ValueNotifier` solto, nenhum controller mantido fora da state.
- Efeitos que normalmente exigiriam `TickerProvider` (como a animação de *wiggle*) precisam ser resolvidos sem `StatefulWidget` — ver seção 7.3 para a estratégia recomendada.
- Segue a Clean Architecture já usada no projeto inCasa: separar `domain` (models puros), `data` (repositórios), `presentation` (Cubit + widgets).

---

## 3. Stack técnica desta feature

| Camada | Escolha |
|---|---|
| Gerência de estado | `flutter_bloc` (Cubit) |
| Imutabilidade de state/models | `equatable` (sem `freezed`, sem code-gen) |
| Persistência local (cache) | `shared_preferences` |
| Persistência remota | Supabase (schema a ser definido em etapa posterior) |
| Widgets | 100% `StatelessWidget` |

---

## 4. Modelo de dados — domínio

### 4.1 Conceito de unidade de medida

Toda a grade é medida em **unidades**, não em pixels diretamente. O valor de 1 unidade é calculado em runtime:

```
unidade = (larguraTelaFisica - margin*2 - padding*2) / 6
```

- `margin` e `padding` = 4 (mesmo valor para ambos, conforme já definido).
- O divisor é sempre **6**, independentemente do tamanho do device — é isso que torna o layout proporcional entre telas diferentes.
- Este cálculo deve ser centralizado (não duplicado em múltiplos widgets) — recomenda-se um método/getter único, calculado a partir do `MediaQuery` da tela e armazenado ou recalculado de forma consistente. Definir onde esse cálculo mora é uma decisão de implementação do Claude Code, respeitando a regra de "nenhum estado fora do Cubit" — ou seja, mesmo esse valor calculado deve estar acessível via state (calculado no momento apropriado, ex: ao montar a tela).

### 4.2 Hierarquia da árvore de nós

```
Grid (raiz — implícito, é a própria tela, não é um nó explícito)
 └── children: List<GridNode>
      ├── ItemNode          (folha — bloco de produto)
      ├── ColunaNode        (container — carrossel vertical)
      │    └── children: List<GridNode>   (apenas ItemNode ou LinhaNode)
      └── LinhaNode         (container — carrossel horizontal)
           └── children: List<GridNode>   (apenas ItemNode ou ColunaNode)
```

**Regra de aninhamento (obrigatória, validar em tempo de inserção):**
- Dentro de um `ColunaNode`, só podem existir `ItemNode` ou `LinhaNode`. **Nunca outro `ColunaNode`.**
- Dentro de um `LinhaNode`, só podem existir `ItemNode` ou `ColunaNode`. **Nunca outro `LinhaNode`.**
- No nível raiz (Grid), podem existir `ItemNode`, `ColunaNode` ou `LinhaNode` livremente.
- Não há um terceiro nível de aninhamento: um `ColunaNode` dentro de um `LinhaNode` não pode conter, por sua vez, outro `LinhaNode` — a profundidade máxima da árvore é 2 níveis abaixo da raiz.

### 4.3 Modelo base — `GridNode`

Sugestão de modelagem: uma classe abstrata (ou `sealed class`, se o projeto já usa Dart 3+) `GridNode`, estendida por `ItemNode`, `ColunaNode`, `LinhaNode`. Todos compartilham:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String` | Identificador único do nó (ex: uuid v4). |
| `x` | `int` | Posição horizontal em unidades, relativa ao pai. |
| `y` | `int` | Posição vertical em unidades, relativa ao pai. |
| `w` | `int` | Largura em unidades. |
| `h` | `int` | Altura em unidades. |

Cada subtipo adiciona seus próprios campos e regras — ver 4.4, 4.5, 4.6.

### 4.4 `ItemNode` (folha — bloco de produto)

| Campo | Valor/Regra |
|---|---|
| `productId` | `String` — referência ao produto cadastrado na loja. |
| `w` | mínimo 1, máximo 6 |
| `h` | mínimo 1, máximo 6 |
| Tamanho inicial | `w=2, h=2` |
| Eixo de resize | Livre — largura e altura ajustam independentemente (pinça altera os 2 eixos). |
| Restrição extra | Nenhuma (pode ser quadrado ou retangular em qualquer proporção dentro dos limites). |

### 4.5 `LinhaNode` (container — carrossel horizontal)

| Campo | Valor/Regra |
|---|---|
| `w` | mínimo 3, máximo 6 |
| `h` | mínimo 2, máximo 6 |
| Tamanho inicial | `w=6, h=2` |
| Restrição de proporção | **`h` nunca pode ser maior que `w`** (a Linha é sempre "deitada" ou quadrada, nunca mais alta que larga). Validar a cada resize: se o usuário tentar reduzir `w` a um valor menor que `h` atual, `h` deve ser limitado junto. |
| Eixo de resize | A pinça altera `w` (e, por extensão, pode ser necessário ajustar `h` para não violar a restrição de proporção acima). |
| `children` | Lista de `ItemNode` ou `ColunaNode`. |
| Capacidade máxima | **12 itens.** Ao atingir 12, não aceita mais adições — a UI deve bloquear/avisar. |
| Comportamento de overflow (visual) | Quando há mais itens do que cabem visíveis na largura atual, mostrar um indicador visual na borda direita (ex: seta ou contador "+N") sinalizando que há mais conteúdo, incentivando o usuário a rolar o carrossel. |
| Reordenação (>6 itens) | Long-press em um item dentro da Linha entra em modo *wiggle* local (apenas os itens da Linha entram em wiggle, não a tela toda) e permite arrastar o item para reposicionar dentro do próprio carrossel. Ao arrastar até perto da borda esquerda/direita do carrossel, ele deve rolar automaticamente (auto-scroll), permitindo alcançar itens fora da área visível. |

### 4.6 `ColunaNode` (container — carrossel vertical)

| Campo | Valor/Regra |
|---|---|
| `w` | mínimo 2, máximo 6 |
| `h` | mínimo 3, máximo 12 |
| Tamanho inicial | `w=2, h=6` |
| Restrição de proporção | **`w` nunca pode ser maior que `h`** (a Coluna é sempre "em pé" ou quadrada, nunca mais larga que alta). Validar a cada resize, análogo à Linha. |
| Eixo de resize | A pinça altera `h` diretamente. Além disso, **`h` cresce automaticamente** conforme itens são adicionados (ver linha abaixo) — este crescimento automático é independente do gesto de pinça do usuário. |
| `children` | Lista de `ItemNode` ou `LinhaNode`. |
| Capacidade máxima | **12 itens.** |
| Crescimento automático de altura | A Coluna nasce comportando 6 itens visíveis na altura inicial (`h=6`). A cada item adicionado além do 6º, a altura (`h`) da Coluna cresce **+1**, até o teto de `h=12` (que corresponde à capacidade máxima de 12 itens). Ao atingir `h=12` com 12 itens, não aceita mais adições. |
| Scroll | Como o Grid pai já é rolável verticalmente, o crescimento de altura da Coluna é suficiente para acomodar os itens — não precisa de scroll interno independente do scroll do Grid. |

### 4.7 Resumo comparativo de dimensões

| Tipo | Largura (min–max) | Altura (min–max) | Restrição de proporção | Tamanho inicial | Capacidade máxima de itens |
|---|---|---|---|---|---|
| `ItemNode` | 1–6 | 1–6 | nenhuma | 2×2 | — (é folha) |
| `LinhaNode` | 3–6 | 2–6 | `h ≤ w` | 6×2 | 12 |
| `ColunaNode` | 2–6 | 3–12 | `w ≤ h` | 2×6 | 12 |

---

## 5. Grid pai (nível raiz)

- É a própria tela — **não é um `GridNode` explícito na árvore**, é o container implícito que posiciona os `GridNode` de nível raiz.
- Largura fixa em **6 unidades** (nunca muda).
- Altura **cresce dinamicamente** conforme blocos são adicionados — a tela inteira é rolável verticalmente (`SingleChildScrollView` ou equivalente).
- Todo posicionamento de nós de nível raiz é feito com coordenadas absolutas (`x, y` em unidades) dentro deste grid — recomenda-se implementação via `Stack` + `Positioned`, não `GridView` nativo (que não suporta posicionamento livre/sobreposto necessário para o reflow).

---

## 6. Interações do usuário

### 6.1 Modo de edição (wiggle)

- Ativado por **long-press** em qualquer `GridNode` (item, coluna ou linha) que esteja solto no Grid.
- Enquanto ativo, **todos os nós de nível raiz** entram em animação de *wiggle* (leve rotação oscilante, ±0.02 radianos aproximadamente, em loop, com pequena variação de fase entre nós para não ficarem sincronizados — efeito similar ao "modo editar" de home screens).
- O nó tocado passa a ser arrastável livremente pela tela.
- Sair do modo de edição: toque fora de qualquer nó, ou botão explícito de "concluir edição" (a decidir na implementação da UI, mas deve existir uma saída clara).

### 6.2 Arrastar e posicionar (drag)

- Durante o modo de edição, o usuário arrasta um nó pela tela.
- Ao soltar sobre uma célula já ocupada por outro nó, ocorre **reflow**: os nós à direita da posição de soltura são deslocados uma posição adiante para abrir espaço (comportamento similar ao reflow de ícones do iOS). Em caso de necessidade, quebra para a "linha" seguinte do grid (reflow em 2D).
- Dentro de `ColunaNode`/`LinhaNode`, o reflow é mais simples: a lista interna é 1D, então o deslocamento é apenas de índice na lista.

### 6.3 Redimensionar (pinça)

- Gesto de pinça (`onScaleUpdate`) sobre um nó em modo de edição altera suas dimensões.
- `ItemNode`: pinça altera `w` e `h` livremente, dentro dos limites da seção 4.4.
- `LinhaNode`: pinça altera `w` (a Linha se estica/encolhe horizontalmente); `h` é recalculado/limitado para nunca ultrapassar `w`, dentro dos limites da seção 4.5.
- `ColunaNode`: pinça altera `h` (a Coluna se estica/encolhe verticalmente); `w` é recalculado/limitado para nunca ultrapassar `h`, dentro dos limites da seção 4.6. Note que `h` também pode crescer automaticamente por adição de itens (seção 4.6) — o Cubit deve tratar ambas as fontes de mudança de `h` de forma consistente (o maior dos dois valores nunca deve ultrapassar 12).

### 6.4 Fluxo de adicionar bloco — BottomBar

A `EditarLojaView` tem uma barra inferior fixa (`BottomBar`) com **3 botões**:

1. **Coluna**
2. **Linha**
3. **Produto** (ícone de "botão"/bloco)

Fluxo comum aos 3, com uma etapa extra apenas para "Produto":

```
Usuário toca no botão da BottomBar
  → [apenas para "Produto"] abre menu central (modal/dialog) listando os produtos
     cadastrados na loja — cada item do menu mostra a foto do produto e uma única
     palavra do nome; usuário toca no produto desejado
  → um novo GridNode (ColunaNode 2×6, LinhaNode 6×2, ou ItemNode 2×2 vinculado
     ao productId escolhido) é criado e aparece FLUTUANDO no centro da tela,
     sobre os demais elementos, ainda sem posição fixa no grid
  → usuário arrasta esse bloco flutuante para a posição desejada no Grid
  → ao soltar, o bloco se encaixa na grade (com reflow se necessário) e passa
     a fazer parte permanente da árvore de nós
```

Esse fluxo deve ser implementado como uma função única no Cubit (algo como `iniciarPosicionamentoDeNovoNo(GridNode node)`), reaproveitada pelos 3 botões — o que muda entre eles é apenas a construção do `GridNode` antes de chamar essa função (e, no caso de Produto, a etapa prévia de seleção no menu).

---

## 7. `CubitEditarLoja` — contrato de estado e responsabilidades

### 7.1 Responsabilidades do Cubit

- Manter a árvore completa de `GridNode` (estado da tela).
- Controlar se a tela está em modo de edição (wiggle ativo) ou não.
- Controlar qual nó (se algum) está sendo posicionado como "flutuante" (recém-criado, ainda não encaixado).
- Controlar qual nó (se algum) está sendo arrastado/redimensionado no momento.
- Validar todas as regras de dimensão, proporção e capacidade máxima antes de aplicar qualquer mudança (nunca deixar a UI representar um estado inválido).
- Executar a lógica de reflow (2D no Grid raiz, 1D dentro de Coluna/Linha).
- Executar a lógica de crescimento automático de altura da Coluna.
- Orquestrar o carregamento inicial (comparação de versão local vs. remota) e o salvamento (local + remoto, com checagem de conflito) — ver seção 8.
- Expor ao menu de seleção de produtos (botão "Produto" da BottomBar) a lista de produtos cadastrados — via chamada a um repositório de produtos já existente no projeto (não é escopo deste documento redefinir esse repositório).

### 7.2 Esboço de `EditarLojaState` (campos mínimos esperados)

> Esta é uma referência de quais informações a state precisa carregar — a modelagem exata (uma state única com campos nulos, ou múltiplas subclasses de state via `Equatable`) fica a critério da implementação, desde que **toda** variável abaixo esteja acessível via state, nunca fora dela.

| Campo | Tipo (sugestão) | Descrição |
|---|---|---|
| `nodes` | `List<GridNode>` | Árvore de nível raiz (cada `ColunaNode`/`LinhaNode` carrega seus próprios `children`). |
| `unidadeMedida` | `double` | Valor calculado da unidade (seção 4.1), para os widgets converterem unidades em pixels. |
| `modoEdicaoAtivo` | `bool` | Se o wiggle está ativo. |
| `noFlutuante` | `GridNode?` | Nó recém-criado, ainda sem posição, aguardando o usuário posicionar. |
| `noEmArrasto` | `String?` (id) | Id do nó sendo arrastado no momento, se algum. |
| `noEmResize` | `String?` (id) | Id do nó sendo redimensionado no momento, se algum. |
| `versaoCarregada` | `String?` | Version token do layout no momento em que foi carregado (para checagem de conflito ao salvar). |
| `statusCarregamento` | enum (`inicial`, `carregando`, `carregado`, `erro`) | Estado de carregamento da tela. |
| `statusSalvamento` | enum (`ocioso`, `salvando`, `sucesso`, `erro`, `conflito`) | Estado do processo de salvar. |
| `produtosDisponiveis` | `List<Produto>` | Cache dos produtos da loja, para o menu de seleção do botão "Produto". |

### 7.3 Estratégia para o efeito wiggle sem `StatefulWidget`

Como nenhum widget pode ser `StatefulWidget` (logo, nenhum widget pode hospedar um `AnimationController` próprio), a animação de wiggle precisa ser conduzida de fora do widget. Opções válidas para o Claude Code avaliar e escolher na implementação:

1. Um `AnimationController` vive fora da árvore de widgets — por exemplo, hospedado em um `StatefulWidget` de altíssimo nível já existente na aplicação (como o `MaterialApp` ou um shell de navegação, se já existir um), e o Cubit apenas liga/desliga esse controller via uma referência exposta por injeção de dependência.
2. Usar um pacote de animação declarativa que não exige `StatefulWidget` explícito no seu código (ex: `AnimatedBuilder` combinado com um `Ticker` gerenciado por uma classe utilitária separada, não um widget).
3. Usar animações implícitas orientadas por valores que mudam a cada `emit()` do Cubit (ex: alternar um ângulo-alvo periodicamente através de um `Timer.periodic` disparado e controlado pelo próprio Cubit, e widgets usando `TweenAnimationBuilder` reagindo à mudança de valor — `TweenAnimationBuilder` não exige `StatefulWidget` próprio do seu código, o gerenciamento interno é do framework).

A opção 3 é a que melhor respeita a letra da regra "nenhum estado fora do Cubit", já que o `Timer.periodic` fica dentro do próprio Cubit (que não é um widget), e os `StatelessWidget`s apenas reagem a valores emitidos. Recomenda-se essa abordagem, mas a decisão final de qual mecanismo usar cabe à implementação, respeitando a restrição da seção 2.

### 7.4 Eventos/métodos esperados no Cubit (lista não exaustiva)

- `carregarLayout()` — dispara o fluxo de comparação de versão e carregamento (seção 8.2).
- `ativarModoEdicao(String nodeId)`
- `desativarModoEdicao()`
- `iniciarPosicionamentoDeNovoNo(GridNode node)` — cria o nó flutuante (seção 6.4).
- `moverNoFlutuanteParaPosicao(int x, int y)`
- `confirmarPosicionamentoDoNoFlutuante()` — encaixa o nó flutuante na árvore, aplicando reflow se necessário.
- `iniciarArrasto(String nodeId)`
- `atualizarArrasto(String nodeId, int novoX, int novoY)`
- `finalizarArrasto(String nodeId)` — aplica reflow.
- `redimensionar(String nodeId, int novoW, int novoH)` — valida limites e proporção antes de aplicar.
- `adicionarItemAoContainer(String containerId, ItemNode item)` — aplica regras de capacidade máxima e crescimento automático de altura (se for Coluna).
- `reordenarItemNaLinha(String linhaId, int deIndex, int paraIndex)`
- `removerNo(String nodeId)`
- `salvarLayout()` — dispara o fluxo completo de salvamento (seção 8.3).
- `resolverConflitoSobrescrevendo()` — chamado quando o usuário confirma a sobrescrita após aviso de conflito.

---

## 8. Persistência

### 8.1 Modelo de dados serializado

O layout inteiro é serializado como um único documento JSON (formato "documento", não relacional — ver justificativa na seção 8.5). Estrutura sugerida:

```json
{
  "version": "  ",
  "nodes": [
    {
      "id": "  ",
      "type": "item",
      "x": 0, "y": 0, "w": 2, "h": 2,
      "productId": "  "
    },
    {
      "id": "  ",
      "type": "linha",
      "x": 2, "y": 0, "w": 6, "h": 2,
      "children": [
        { "id": "  ", "type": "item", "x": 0, "y": 0, "w": 1, "h": 1, "productId": "  " }
      ]
    },
    {
      "id": "  ",
      "type": "coluna",
      "x": 0, "y": 2, "w": 2, "h": 6,
      "children": []
    }
  ]
}
```

- Cada `GridNode` deve implementar `toJson()`/`fromJson()` de forma recursiva (containers serializam seus `children` chamando o mesmo método nos filhos).
- O campo `version` no topo do documento é o mesmo version token tratado na seção 8.2 — pode viver dentro do próprio JSON, na coluna separada do banco, ou em ambos (redundância aceitável para simplificar leitura).

### 8.2 Fluxo de carregamento (ao abrir `EditarLojaView`)

```
1. Lê version_local do cache (shared_preferences).
2. Consulta ao Supabase APENAS a coluna de versão (query leve, sem
   trazer o jsonb inteiro).
3. Se version_local == version_remota:
     usa o layout já salvo em cache local — não baixa o jsonb completo.
4. Se version_local != version_remota (ou cache vazio/inexistente):
     baixa o documento completo do Supabase, atualiza o cache local
     (jsonb + version), e usa esse layout.
5. Armazena a version usada nesta sessão em `versaoCarregada` na state
   (necessário para a checagem de conflito no salvamento).
```

### 8.3 Fluxo de salvamento (botão "Salvar" — não há auto-save)

```
1. Usuário toca em "Salvar".
2. Cubit consulta novamente APENAS a versão remota atual no Supabase.
3. Compara essa versão com `versaoCarregada` (guardada na state desde
   o carregamento/última operação de salvar bem-sucedida):
   a. Se IGUAIS → segue fluxo normal:
      - gera uma nova version (ex: uuid v4)
      - salva localmente (shared_preferences): jsonb + nova version
      - executa UPSERT no Supabase: jsonb + nova version
      - em caso de sucesso, atualiza `versaoCarregada` para a nova version
      - em caso de falha de rede, mantém uma flag local indicando que o
        cache local está "não sincronizado com o remoto", para permitir
        nova tentativa depois (o Claude Code deve definir a estratégia
        exata de retry/flag, mas o dado não pode ser perdido)
   b. Se DIFERENTES → houve edição concorrente em outro device:
      - NÃO salva automaticamente
      - state de salvamento muda para `conflito`
      - a UI deve exibir um diálogo perguntando se o usuário deseja
        sobrescrever a versão remota mesmo assim
      - se o usuário confirmar (`resolverConflitoSobrescrevendo()`),
        prossegue com o mesmo fluxo do item (a) a partir da geração de
        nova version
      - se o usuário cancelar, nada é salvo; o usuário pode optar por
        recarregar o layout remoto mais recente antes de tentar de novo
        (fluxo de recarregamento pode reaproveitar `carregarLayout()`)
```

### 8.4 Papel do `shared_preferences`

Usado exclusivamente como **cache local**, não como fonte de verdade:
- Chave sugerida: algo como `loja_layout_json` e `loja_layout_version` (nomes exatos a critério da implementação).
- Permite abrir a tela instantaneamente sem esperar rede quando a versão já é a mais recente.
- Nunca é a fonte usada pela tela "Minha Loja" (essa sempre lê do Supabase) — o cache serve apenas para acelerar a abertura da própria `EditarLojaView`.

### 8.5 Justificativa da escolha de modelo (documento JSON vs. relacional)

Decisão já tomada e validada: usar um documento JSON (coluna `jsonb` no Supabase) em vez de normalizar cada nó como uma linha de tabela relacional. Motivos:
- A árvore é sempre lida e escrita como um todo — nunca há necessidade de query parcial (`WHERE largura > 3`, por exemplo).
- Alinhado com o padrão observado em editores visuais de referência (home screens de iOS/Android, editores de nível de jogos 2D como Tiled, page builders como Notion/Webflow) — todos tratam esse tipo de layout como um documento serializável.
- Simplifica o `LayoutRepository` para operações únicas de leitura/escrita completas, sem necessidade de transações multi-tabela.
- O schema definitivo da tabela Supabase (nome exato, colunas, RLS) será definido na próxima etapa deste projeto, fora do escopo deste documento.

---

## 9. Estrutura de arquivos sugerida

> Sugestão de organização respeitando "cada widget em seu próprio arquivo" e Clean Architecture já usada no projeto. Ajustar nomes de pastas ao padrão já existente no inCasa.

```
lib/
  features/
    editar_loja/
      domain/
        models/
          grid_node.dart          (classe base + ItemNode, ColunaNode, LinhaNode)
          resize_axis.dart        (enum: both, widthOnly, heightOnly)
      data/
        repositories/
          layout_repository.dart  (interface + implementação Supabase)
        local/
          layout_local_cache.dart (wrapper sobre shared_preferences)
      presentation/
        cubit/
          cubit_editar_loja.dart
          editar_loja_state.dart
        pages/
          editar_loja_view.dart
        widgets/
          grid_canvas.dart          (Stack + Positioned dos nós de nível raiz)
          item_node_widget.dart
          coluna_node_widget.dart
          linha_node_widget.dart
          wiggle_wrapper.dart        (aplica o efeito de wiggle a qualquer child)
          bottom_bar_editar_loja.dart
          menu_selecao_produto.dart  (modal do botão "Produto")
          no_flutuante_overlay.dart  (renderiza o bloco flutuante em posicionamento)
```

---

## 10. Checklist de aceite

Uma implementação está completa quando:

- [ ] Todos os widgets desta feature são `StatelessWidget`, um por arquivo.
- [ ] Nenhuma variável de estado da tela existe fora de `EditarLojaState`.
- [ ] `GridNode` e subtipos têm `toJson()`/`fromJson()` recursivos funcionando (round-trip sem perda de dados).
- [ ] Todas as regras de dimensão/proporção da seção 4.7 são validadas no Cubit antes de qualquer `emit()` — nunca é possível a UI representar um estado fora dos limites.
- [ ] Regras de aninhamento (seção 4.2) são impostas na inserção — impossível colocar Coluna dentro de Coluna ou Linha dentro de Linha.
- [ ] Reflow funciona tanto no Grid raiz (2D) quanto dentro de Coluna/Linha (1D).
- [ ] Coluna cresce automaticamente em altura ao passar de 6 itens, até o teto de 12 itens/altura 12.
- [ ] Linha bloqueia adição ao atingir 12 itens, com indicador visual de overflow quando há itens fora da área visível.
- [ ] Reordenação por wiggle+drag funciona dentro do carrossel da Linha, com auto-scroll nas bordas.
- [ ] Fluxo dos 3 botões da BottomBar (Coluna, Linha, Produto) cria corretamente o nó flutuante e permite posicioná-lo.
- [ ] Fluxo de carregamento respeita a comparação de versão antes de baixar o layout completo.
- [ ] Fluxo de salvamento detecta conflito de versão e exibe aviso ao usuário antes de sobrescrever.
- [ ] Cache local via `shared_preferences` nunca é tratado como fonte de verdade para outras telas do app.
