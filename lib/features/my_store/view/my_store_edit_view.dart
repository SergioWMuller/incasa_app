import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incasa_app/core/di/injection_container.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_cubit.dart';
import 'package:incasa_app/features/my_store/cubit/editar_loja_state.dart';
import 'package:incasa_app/features/my_store/widgets/editar_loja/editar_loja_bottom_bar.dart';
import 'package:incasa_app/features/my_store/widgets/editar_loja/editar_loja_conflito_dialog.dart';
import 'package:incasa_app/features/my_store/widgets/editar_loja/grid_canvas_widget.dart';
import 'package:incasa_app/features/my_store/widgets/editar_loja/no_flutuante_overlay.dart';

/// Tela onde o usuário monta o layout visual da própria loja, arrastando,
/// redimensionando e organizando blocos numa grade (ai/EDITAR_LOJA_VIEW.md).
///
/// Todo o estado mutável vive em `EditarLojaCubit` — este e os demais
/// widgets desta feature são `StatelessWidget` (ai/EDITAR_LOJA_VIEW.md §2).
class MyStoreEditView extends StatelessWidget {
  const MyStoreEditView({super.key});

  @override
  Widget build(BuildContext context) {
    // A largura precisa ser lida aqui (contexto normal, com suporte a
    // dependências de InheritedWidget) — dentro do `create` do BlocProvider
    // o contexto só existe para uma chamada única (como um `initState`), e
    // `MediaQuery.sizeOf` tenta se inscrever para atualizações, o que
    // dispara um erro do provider.
    final larguraTela = MediaQuery.sizeOf(context).width;
    return BlocProvider(
      create: (_) => sl<EditarLojaCubit>()..inicializar(larguraTela),
      child: const _MyStoreEditBody(),
    );
  }
}

class _MyStoreEditBody extends StatelessWidget {
  const _MyStoreEditBody();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditarLojaCubit>();

    return BlocConsumer<EditarLojaCubit, EditarLojaState>(
      listenWhen: (previous, current) =>
          previous.statusSalvamento != current.statusSalvamento,
      listener: (context, state) {
        switch (state.statusSalvamento) {
          case StatusSalvamentoLayout.conflito:
            mostrarDialogoConflitoDeVersao(context, cubit);
          case StatusSalvamentoLayout.sucesso:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Layout da loja salvo!')),
            );
          case StatusSalvamentoLayout.erro:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erroMensagem ?? 'Erro ao salvar layout'),
              ),
            );
          case StatusSalvamentoLayout.ocioso:
          case StatusSalvamentoLayout.salvando:
            break;
        }
      },
      builder: (context, state) {
        final salvando = state.statusSalvamento == StatusSalvamentoLayout.salvando;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Editar loja'),
            actions: [
              if (state.modoEdicaoAtivo)
                TextButton(
                  onPressed: cubit.desativarModoEdicao,
                  child: const Text('Concluir edição'),
                ),
              IconButton(
                tooltip: 'Salvar layout',
                onPressed: salvando ? null : cubit.salvarLayout,
                icon: salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
              ),
            ],
          ),
          body: state.statusCarregamento == StatusCarregamentoLayout.erro
              ? _ErroCarregamento(cubit: cubit, mensagem: state.erroMensagem)
              : GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: state.modoEdicaoAtivo
                      ? cubit.desativarModoEdicao
                      : null,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GridCanvasWidget(state: state, cubit: cubit),
                      NoFlutuanteOverlay(state: state, cubit: cubit),
                    ],
                  ),
                ),
          bottomNavigationBar: state.noFlutuante == null
              ? EditarLojaBottomBar(cubit: cubit)
              : null,
        );
      },
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  final EditarLojaCubit cubit;
  final String? mensagem;

  const _ErroCarregamento({required this.cubit, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(mensagem ?? 'Erro ao carregar layout da loja'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: cubit.carregarLayout,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
