import 'package:flutter/material.dart';
import 'package:lista_do_mercadinho/core/database/db_helper.dart';

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

  final _formKey = GlobalKey<FormState>();

  final FocusNode _quantidadeFocus = FocusNode();
  final FocusNode _precoFocus = FocusNode();

  List<Map<String, dynamic>> _sugestoes = [];

  @override
  void initState() {
    super.initState();
    _carregarSugestoes();
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

  Future<void> _carregarSugestoes() async {
    final itens = await DbHelper.instance.getAllItensComprados();
    final mapaAgrupado = <String, Map<String, dynamic>>{};

    for (var item in itens) {
      final nome = item['nome'] as String;
      if (!mapaAgrupado.containsKey(nome)) {
        mapaAgrupado[nome] = {
          'nome': nome,
          'preco': item['preco'],
          'quantidade': item['quantidade'],
          'frequencia': 1,
        };
      } else {
        mapaAgrupado[nome]!['frequencia'] =
            (mapaAgrupado[nome]!['frequencia'] as int) + 1;
        mapaAgrupado[nome]!['preco'] = item['preco'];
        mapaAgrupado[nome]!['quantidade'] = item['quantidade'];
      }
    }

    final listaOrdenada = mapaAgrupado.values.toList()
      ..sort(
        (a, b) => (b['frequencia'] as int).compareTo(a['frequencia'] as int),
      );

    if (mounted) {
      setState(() {
        _sugestoes = listaOrdenada.take(8).toList();
      });
    }
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text.trim();
      final quantidade = int.tryParse(_quantidadeController.text) ?? 1;

      final precoTexto = _precoController.text.replaceAll(',', '.');
      final preco = double.tryParse(precoTexto);

      widget.lista.adicionarProduto(nome, quantidade, preco);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Produto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_sugestoes.isNotEmpty) ...[
                Text(
                  'Mais comprados:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: _sugestoes.map((sugestao) {
                    final nome = sugestao['nome'] as String;
                    final preco = (sugestao['preco'] as num).toDouble();
                    final quantidade = (sugestao['quantidade'] as num).toInt();

                    return ActionChip(
                      label: Text(nome),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      side: BorderSide.none,
                      onPressed: () {
                        setState(() {
                          _nomeController.text = nome;
                          _quantidadeController.text = quantidade.toString();
                          _precoController.text = preco > 0
                              ? preco.toStringAsFixed(2)
                              : '';
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _quantidadeController,
                      focusNode: _quantidadeFocus,
                      decoration: const InputDecoration(labelText: 'Qtd *'),
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
                        labelText: 'Preço (Opcional)',
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
        FilledButton(onPressed: _salvar, child: const Text('Adicionar')),
      ],
    );
  }
}
