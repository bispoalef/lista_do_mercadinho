import 'package:flutter/material.dart';

import '../../models/produto.dart';
import '../../providers/lista_produtos.dart';

class EditProdutoDialog extends StatefulWidget {
  final Produto produto;
  final ListaDeProdutos lista;

  const EditProdutoDialog({
    super.key,
    required this.produto,
    required this.lista,
  });

  @override
  State<EditProdutoDialog> createState() => _EditProdutoDialogState();
}

class _EditProdutoDialogState extends State<EditProdutoDialog> {
  final _nomeController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _precoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final FocusNode _quantidadeFocus = FocusNode();
  final FocusNode _precoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nomeController.text = widget.produto.nome;
    _quantidadeController.text = widget.produto.quantidade.toString();
    _precoController.text = widget.produto.preco == 0
        ? ''
        : widget.produto.preco.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _precoController.dispose();
    _quantidadeFocus.dispose();
    _precoFocus.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text.trim();
      final quantidade =
          int.tryParse(_quantidadeController.text) ?? widget.produto.quantidade;

      final precoTexto = _precoController.text.replaceAll(',', '.');
      final preco = double.tryParse(precoTexto) ?? widget.produto.preco;

      final produtoAtualizado = Produto(
        id: widget.produto.id,
        nome: nome,
        quantidade: quantidade,
        preco: preco,
      );

      widget.lista.atualizarProduto(produtoAtualizado);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Produto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Produto'),
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_quantidadeFocus);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _quantidadeController,
                      focusNode: _quantidadeFocus,
                      decoration: const InputDecoration(labelText: 'Qtd'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_precoFocus);
                      },
                      validator: (value) {
                        if (value == null ||
                            int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _precoController,
                      focusNode: _precoFocus,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        prefixText: 'R\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        _salvar();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
