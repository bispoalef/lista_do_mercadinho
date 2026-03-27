import 'dart:math';
import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';
import 'edit_produto_dialog.dart';

class ItemDaListaPendente extends StatefulWidget {
  final Produto produto;
  final ListaDeProdutos list;

  const ItemDaListaPendente({
    super.key,
    required this.produto,
    required this.list,
  });

  @override
  State<ItemDaListaPendente> createState() => _ItemDaListaPendenteState();
}

class _ItemDaListaPendenteState extends State<ItemDaListaPendente>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _darTremidinha() {
    _shakeController.forward(from: 0.0);

    ScaffoldMessenger.of(context).clearMaterialBanners();

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(
          '⚠️ Informe o preço para mover pro carrinho',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(
              'FECHAR',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final deslocamento = sin(_shakeController.value * pi * 4) * 8;
        return Transform.translate(
          offset: Offset(deslocamento, 0),
          child: child,
        );
      },
      child: Dismissible(
        key: ValueKey(widget.produto.id),
        direction: DismissDirection.endToStart,
        background: Container(
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
                      "Deseja realmente remover '${widget.produto.nome}' da sua lista?",
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
          widget.list.excluirProduto(widget.produto);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => EditProdutoDialog(
                  produto: widget.produto,
                  lista: widget.list,
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Checkbox(
                value: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (bool? newValue) {
                  if (widget.produto.preco == 0) {
                    _darTremidinha();
                  } else {
                    widget.list.removerProduto(widget.produto);
                  }
                },
              ),
              title: Text(
                widget.produto.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Qtd: ${widget.produto.quantidade}  •  R\$ ${widget.produto.preco.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
