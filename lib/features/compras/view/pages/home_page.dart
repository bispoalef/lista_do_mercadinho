import 'package:flutter/material.dart';
import 'package:lista_do_mercadinho/core/theme/theme_provider.dart';

import 'package:provider/provider.dart';

import '../../providers/lista_produtos.dart';
import '../widgets/item_da_lista_carrinho.dart';
import '../widgets/item_da_lista_pendente.dart';
import '../widgets/novo_produto_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lista = Provider.of<ListaDeProdutos>(context);
    final size = MediaQuery.of(context).size;

    final carrinho = lista.getCarrinho;
    final pendentes = lista.getLista;
    final carrinhoOculto = lista.getEstado;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Lista de Compras')),
      body: Column(
        children: [
          Expanded(
            child: pendentes.isEmpty
                ? Center(
                    child: Text(
                      'Tudo comprado!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    onReorder: (oldIndex, newIndex) {
                      final index = newIndex > oldIndex
                          ? newIndex - 1
                          : newIndex;
                      final prod = pendentes[oldIndex];
                      lista.removerNoIndex(oldIndex);
                      lista.inserirNoIndex(index, prod);
                    },
                    itemCount: pendentes.length,
                    itemBuilder: (context, index) {
                      final produto = pendentes[index];
                      return ItemDaListaPendente(
                        key: ValueKey(produto.id),
                        list: lista,
                        produto: produto,
                      );
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: lista.ocultarCarrinho,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: R\$ ${lista.valorTotalCarrinho().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Row(
                          children: [
                            if (carrinho.isNotEmpty)
                              FilledButton.icon(
                                onPressed: () {
                                  // --- NOVA LÓGICA DO BOTÃO FINALIZAR ---
                                  final controller = TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Finalizar Compra'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          labelText: 'Apelido (Opcional)',
                                          hintText: 'Ex: Compra do Mês',
                                        ),
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancelar'),
                                        ),
                                        FilledButton(
                                          onPressed: () async {
                                            final nome = controller.text.trim();
                                            await lista.finalizarCompra(
                                              apelido: nome.isEmpty
                                                  ? null
                                                  : nome,
                                            );

                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Compra salva! 🛒',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Salvar e Sair'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Finalizar'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Icon(
                              carrinhoOculto
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: carrinhoOculto ? 0 : size.height * 0.4,
                  child: carrinho.isEmpty
                      ? Center(
                          child: Text(
                            'Carrinho Vazio',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: carrinho.length,
                          itemBuilder: (context, index) => ItemDaListaCarrinho(
                            list: lista,
                            produto: carrinho[index],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => NovoProdutoDialog(lista: lista),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
