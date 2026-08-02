# Handoff: inCasa — Marketplace de Produtos Artesanais (7 telas core)

## Overview
inCasa é um marketplace de bairro para comida caseira, artesanato e serviços feitos por vizinhos, com foco em distância/proximidade. Este pacote cobre as 7 telas core do fluxo principal: descoberta → produto → anúncio → pagamento → coordenação de entrega → loja do vendedor → perfil. **Ainda faltam ~6 telas para MVP completo** (onboarding/login, busca com filtros, meus pedidos, confirmação pós-pagamento, avaliação pós-compra, gestão de anúncios) — não incluídas neste pacote.

## About the Design Files
Os arquivos `.dc.html` neste pacote são **referências de design** — mockups em HTML mostrando aparência e comportamento pretendidos, não código de produção para copiar diretamente. A tarefa é **recriar estes designs no ambiente já existente do projeto de destino** (React Native, Flutter, SwiftUI/Kotlin nativo, etc.), usando os padrões e bibliotecas já estabelecidos lá. Se ainda não houver um ambiente definido, escolha o framework mais apropriado (recomendação: React Native ou Flutter, dado o alvo mobile) e implemente os designs nele.

## Fidelity
**Alta fidelidade (hifi)** — `inCasa Hi-Fi.dc.html`. Cores, tipografia, espaçamento e componentes finais definidos; deve ser recriado pixel-a-pixel. Imagens são placeholders coloridos (`.thumb`) — substituir por fotos reais de produtos/vendedores.
`inCasa Wireframes.dc.html` é incluído apenas como referência histórica das decisões estruturais (rótulos 3b/4a/5a/6c/7b/8b/9c) — não precisa ser implementado.

## Screens / Views

### 01 — Início (Feed de descoberta)
**Purpose:** tela inicial; navegação por proximidade, com toggle Produtos/Vizinhos.
**Layout:** coluna única, safe-area top com barra de status simulada. Estrutura vertical: header de localização + sino de notificação → busca → seção "Vizinhos vendendo hoje" (carrossel horizontal de stories) → seção "Perto de você" com toggle segmentado → lista de cards de produto (scroll vertical) → tab bar fixa no rodapé (5 itens, "Vender" central elevado).
**Components:**
- Location pill: pin terracota + "Jd. das Flores" + chevron, 17px Bricolage 800.
- Bell button: círculo 38px branco, borda `#EDE3D4`.
- Search bar: pill branca, borda `#EDE3D4`, radius 16px, placeholder "Buscar comida, artesanato, serviços…", cinza `#A99A84`.
- Stories/vizinhos: avatar circular 56px com anel gradiente laranja→terracota (`#E0902B`→`#D9592B`), nome + distância abaixo (11px 700).
- Segmented toggle: fundo `#F0E7D8` radius 12px, opção ativa em branco com sombra sutil.
- Product card: imagem topo (thumb colorido placeholder, 150px), heart button flutuante top-right (32px círculo branco translúcido), corpo com nome do produto (15px Bricolage 800), avatar do vendedor + nome + distância + estrela/nota (12px 600), preço (17px Bricolage 800) + tag de categoria (pill verde `#E9F0E2`/`#5A8149`).
- Tab bar: 66px altura, fundo branco, borda-top `#EFE6D7`; item central "Vender" elevado com botão circular terracota 48px "+".

### 02 — Produto
**Purpose:** detalhe de produto, decisão de compra ou conversa com vendedor.
**Layout:** imagem full-bleed no topo (250px, estende sob a status bar) com botão voltar, favoritar e compartilhar sobrepostos; dots de carrossel de imagem; corpo com scroll; barra de ação fixa no rodapé com dois botões.
**Components:**
- Back button: círculo 38px branco sobre imagem.
- Category tag + distância acima do título.
- Título produto: 22px Bricolage 800, letter-spacing -0.4px.
- Preço: 24px Bricolage 800.
- Vendor card: avatar 40px, nome + estrela + "X vendas no bairro" (12px), link "ver loja ›" em terracota.
- Banner verde de disponibilidade (`.banG`): "Retirada no bairro hoje até 18h · ou entrego até 1 km".
- Descrição: 13.5px 400, cinza `#6F6353`.
- Rodapé fixo: botão outline "Conversar" (flex 1) + botão preenchido terracota "Comprar · R$ 32" (flex 1.5).

### 03 — Anunciar (wizard, passo 2 de 4)
**Purpose:** fluxo passo-a-passo de criação de anúncio.
**Layout:** header com voltar + título + indicador "passo 2 de 4"; barra de progresso (50% preenchida, gradiente laranja→terracota); corpo em coluna com campos de formulário; botão de continuar fixo no rodapé.
**Components:**
- Banner de alerta (`.banA`, laranja claro `#FBE6DB`/`#B0431C`): regra "só itens feitos por você".
- Upload de fotos: 1 thumbnail preenchido + 2 slots dashed com "+".
- Campo de texto (`.field`): borda 1.5px `#E6DAC6`, radius 14px.
- Chips de categoria: pill outline, estado ativo = preenchido preto `#2A231C`.
- Textarea de descrição com placeholder cinza.
- Botão "Continuar →" terracota full-width.

### 04 — Pagamento Pix
**Purpose:** checkout expresso via QR Pix.
**Layout:** fundo desfocado/esmaecido do pedido atrás; sheet modal ancorado no rodapé (radius 26px superior, sobe do fundo) contendo todo o fluxo de pagamento.
**Components:**
- Drag handle (barra 42×5px) no topo do sheet.
- Título "Pague com Pix" 20px Bricolage 800.
- Timer de expiração: "expira em 09:58".
- QR code: 150×150px, fundo branco, borda, radius 16px.
- Código copia-e-cola: campo monoespaçado truncado.
- Resumo do pedido: avatar + nome do produto/vendedor + preço à direita.
- Banner verde: horário de retirada combinado.
- Botão "Já paguei" terracota full-width.

### 05 — Chat + combinado
**Purpose:** coordenação de entrega com resumo do pedido fixado no topo.
**Layout:** header com vendedor (avatar, nome, status online) → **bloco fixado (pinned) logo abaixo do header**, fundo laranja claro, com nome do produto + preço + status pago, local e horário combinados, botão "Ver combinado / alterar" → thread de mensagens scrollável (bolhas alinhadas esq/dir) → input bar fixo no rodapé.
**Components:**
- Pinned summary (`.pinned`): fundo `#FBE6DB`, borda inferior `#F1CBB8`; linha de status "Pago ✓" (pill branca); linha local/hora em caps 12px 700 terracota escuro.
- Bolhas de chat: recebida (`.bi`) fundo bege `#F1E8D9`, texto escuro, alinhada à esquerda; enviada (`.bo`) fundo terracota, texto branco, alinhada à direita; radius 16px com o canto adjacente ao autor em 5px.
- Input bar: campo pill cinza-bege + botão enviar circular terracota 40px com seta "↑".

### 06 — Loja do vendedor
**Purpose:** vitrine do vendedor com item em destaque + carrossel do restante do catálogo.
**Layout:** header com voltar, avatar, nome + rating + distância, botão "Seguir" à direita; corpo: bio curta → seção "Destaque de hoje" com card grande de produto → seção "Mais da Bel" com carrossel horizontal de cards menores + seta "ver mais".
**Components:**
- Botão "Seguir" (`.btnS`): pill bege `#F0E7D8`.
- Tag "novo" (pill laranja `.tagp`).
- Card destaque: imagem 140px + linha nome/subtítulo + preço à direita (19px).
- Cards do carrossel: 118px largura, imagem 80px, nome 12px, preço 14px.

### 07 — Perfil
**Purpose:** atalhos simples de conta (pedidos, favoritos, anúncios, vendas, avaliações, configurações).
**Layout:** header com avatar 56px, nome, localização + rating, link "editar"; lista vertical de linhas de atalho (sem cards, divisórias finas); tab bar no rodapé com "Perfil" ativo.
**Components:**
- Profile row (`.prow`): ícone em quadrado arredondado bege 34px à esquerda, label 15px 700, valor opcional à direita (contagem, tag "3 ativos", valor em R$ verde para vendas), chevron `›` cinza-claro.
- Linhas: Meus pedidos · Favoritos (badge "3") · Meus anúncios (tag "3 ativos") · Minhas vendas (valor verde "R$ 480") · Avaliações · Configurações.

## Interactions & Behavior
- **Navegação:** tab bar (Início/Buscar/Vender/Chat/Perfil) é navegação principal por abas; "Vender" abre o wizard de anúncio (tela 03) como flow modal/full-screen, não como aba persistente.
- **Toggle segmentado (Início):** alterna lista de produtos vs. lista de vendedores próximos — mesma seção, conteúdo diferente.
- **Card de produto → Produto (tela 02):** tap navega para detalhe.
- **"ver loja" (Produto) → Loja do vendedor (tela 06).**
- **"Comprar" (Produto) → Pagamento Pix (tela 04)**, apresentado como bottom sheet sobre a tela de pedido.
- **"Já paguei" (Pix) → Chat + combinado (tela 05)**, iniciando a conversa com resumo do pedido já pago fixado no topo.
- **Heart/favoritar:** toggle visual local (preenche o ícone), sem navegação.
- **Wizard de anúncio:** 4 passos com barra de progresso; "Continuar" avança passo a passo; passo final deve publicar o anúncio e retornar ao Perfil/Meus anúncios.
- **Chat "Ver combinado / alterar":** deve abrir edição de local/horário combinados (tela não coberta neste pacote — a definir).
- Nenhuma animação/transição específica foi definida; usar as transições padrão da plataforma (push/pop de navegação, sheet slide-up para o Pix).

## State Management
- **Localização do usuário:** bairro atual (ex: "Jd. das Flores"), usada para ordenar feed por distância e calcular "Xm/Xkm" em cada card.
- **Toggle de visualização (Início):** estado local `view: 'produtos' | 'vizinhos'`.
- **Wizard de anúncio:** estado multi-step (fotos, título, categoria, descrição, + passos 3–4 não desenhados: preço/disponibilidade e revisão/publicar); progresso persistido caso o usuário saia e volte.
- **Pagamento Pix:** estado do pedido (`aguardando_pagamento` → `pago`) e countdown de expiração do QR (ex: 10min).
- **Chat:** thread de mensagens por pedido; resumo fixado (produto, preço, status de pagamento, local/hora combinados) associado ao pedido, não à conversa genérica.
- **Favoritos:** lista de IDs de produto marcados, refletida no contador da tela de Perfil.
- **Perfil:** contagem de anúncios ativos, total de vendas (R$), rating agregado — dados vindos do backend, não mockados no cliente.

## Design Tokens

**Cores**
- Terracota (primária): `#D9592B`
- Verde floresta (secundária): `#5E8A4E`
- Laranja accent (gradientes/rings): `#E0902B`
- Texto principal: `#2A231C`
- Texto secundário/meta: `#6F6353`
- Texto terciário/placeholder: `#9a8c78` / `#A99A84`
- Fundo de app: `#E7DCCB` (fora do device) / `#FBF6EE` (dentro das telas)
- Fundo de card: `#FFFFFF`
- Borda padrão: `#EEE4D5` / `#E6DAC6` / `#EDE3D4`
- Tag verde (categoria): fundo `#E9F0E2`, texto `#5A8149`
- Tag laranja (pago/status): fundo `#FBE6DB`, texto `#B0431C`
- Banner sucesso: fundo `#E9F0E2`, borda `#CFDEBE`, texto `#4E7540`
- Banner alerta: fundo `#FBE6DB`, borda `#F1CBB8`, texto `#B0431C`
- Estrela/rating: `#E0902B`

**Tipografia**
- Títulos/marca: **Bricolage Grotesque**, pesos 600/700/800
- Texto/interface: **Nunito Sans**, pesos 400/600/700/800
- Escala usada: 11px (labels/legendas) · 12–13px (meta/corpo pequeno) · 14–15px (corpo/nome de item) · 16–18px (títulos de seção) · 19–24px (títulos de tela/preços destacados)

**Espaçamento / Radius**
- Radius pequeno (chips, campos): 12–16px
- Radius de card: 20px
- Radius de botão: 14–16px
- Radius de avatar/botão circular: 50%
- Radius de sheet modal: 26px (apenas topo)
- Padding padrão de tela: 16–18px horizontal
- Gap padrão entre elementos empilhados: 12–15px

**Sombras**
- Card: `0 4px 16px rgba(42,35,28,.05)`
- Botão primário: `0 6px 16px rgba(217,89,43,.28)`
- Sheet modal: `0 -8px 30px rgba(42,35,28,.16)`

## Assets
Nenhuma imagem real é usada — todos os "thumbnails" de produto/foto são placeholders coloridos com texto descritivo (classe `.thumb`, variantes `.t-cake/.t-berry/.t-herb/.t-choc/.t-bread`). **Substituir por fotografia real de produtos e avatares de vendedores antes de ir a produção.** Fontes carregadas via Google Fonts (Bricolage Grotesque, Nunito Sans) — usar os mesmos arquivos de fonte ou equivalentes no ambiente nativo/mobile de destino.

## Files
- `inCasa Hi-Fi.dc.html` — as 7 telas de alta fidelidade descritas acima (fonte de verdade visual).
- `inCasa Wireframes.dc.html` — wireframes de baixa fidelidade com as decisões de fluxo (3b, 4a, 5a, 6c, 7b, 8b, 9c) — referência histórica de por que cada layout foi escolhido.
- `screenshots/01-inicio.png` … `07-perfil.png` — capturas PNG de cada tela, na mesma ordem do README, para referência visual rápida sem precisar abrir o HTML.
