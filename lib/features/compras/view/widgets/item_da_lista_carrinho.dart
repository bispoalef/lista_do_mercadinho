import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';

class ItemDaListaCarrinho extends StatelessWidget {
  final Produto produto;
  final ListaDeProdutos list;

  const ItemDaListaCarrinho({
    Key? key,
    required this.produto,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Checkbox(
          value: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
          ),
        ),
        subtitle: Text('Qtd: ${produto.quantidade}'),
        trailing: Text(
          'R\$ ${produto.preco.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
