import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';
import 'edit_produto_dialog.dart';

class ItemDaListaPendente extends StatelessWidget {
  final Produto produto;
  final ListaDeProdutos list;

  const ItemDaListaPendente({
    Key? key,
    required this.produto,
    required this.list,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Checkbox(
          value: false,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (bool? newValue) {
            list.removerProduto(produto);
          },
        ),
        title: Text(
          produto.nome,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Qtd: ${produto.quantidade}  •  R\$ ${produto.preco.toStringAsFixed(2)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => EditProdutoDialog(
                produto: produto,
                lista: list,
              ),
            );
          },
        ),
      ),
    );
  }
}
