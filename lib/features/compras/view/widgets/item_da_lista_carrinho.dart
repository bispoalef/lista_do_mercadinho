import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';

class ItemDaListaCarrinho extends StatelessWidget {
  final Produto produto;
  final ListaDeProdutos list;

  const ItemDaListaCarrinho({
    super.key,
    required this.produto,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(produto.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.onError,
          size: 28,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline_rounded,
          color: Theme.of(context).colorScheme.onError,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmar Exclusão"),
                  content: Text(
                    "Deseja realmente remover '${produto.nome}' do carrinho?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text("Excluir"),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (direction) {
        list.excluirProduto(produto);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Checkbox(
            value: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (bool? newValue) {
              list.restaurarProduto(produto);
            },
          ),
          title: Text(
            produto.nome,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          subtitle: Text(
            'Qtd: ${produto.quantidade}  •  R\$ ${produto.preco.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
