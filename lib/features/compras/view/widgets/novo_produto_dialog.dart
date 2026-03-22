import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';

class NovoProdutoDialog extends StatefulWidget {
  final ListaDeProdutos lista;

  const NovoProdutoDialog({Key? key, required this.lista}) : super(key: key);

  @override
  State<NovoProdutoDialog> createState() => _NovoProdutoDialogState();
}

class _NovoProdutoDialogState extends State<NovoProdutoDialog> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

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

    widget.lista.adicionarProduto(
      Produto(
        id: const Uuid().v4(),
        nome: nome,
        preco: preco,
        quantidade: quantidade,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Produto'),
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
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
