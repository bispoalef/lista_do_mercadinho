import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';

class EditProdutoDialog extends StatefulWidget {
  final Produto produto;
  final ListaDeProdutos lista;

  const EditProdutoDialog({
    Key? key,
    required this.produto,
    required this.lista,
  }) : super(key: key);

  @override
  State<EditProdutoDialog> createState() => _EditProdutoDialogState();
}

class _EditProdutoDialogState extends State<EditProdutoDialog> {
  late final TextEditingController _nomeController;
  late final TextEditingController _quantidadeController;
  late final TextEditingController _precoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.produto.nome);
    _quantidadeController =
        TextEditingController(text: widget.produto.quantidade.toString());
    _precoController =
        TextEditingController(text: widget.produto.preco.toString());
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nomeController.text.isEmpty ||
        _quantidadeController.text.isEmpty ||
        _precoController.text.isEmpty) {
      return;
    }

    final nome = _nomeController.text;
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final preco = double.tryParse(_precoController.text) ?? 0.0;

    if (quantidade <= 0 || preco <= 0) return;

    widget.lista.editarProduto(
      widget.produto,
      nome,
      preco,
      quantidade,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Produto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Produto'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantidadeController,
              decoration: const InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _precoController,
              decoration: const InputDecoration(labelText: 'Preço Unitário'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Salvar Alterações'),
        ),
      ],
    );
  }
}
