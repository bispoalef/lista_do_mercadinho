import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/db_helper.dart';
import '../models/compra.dart';
import '../models/produto.dart';

class ListaDeProdutos extends ChangeNotifier {
  List<Produto> _list = [];
  List<Produto> _carrinho = [];
  bool _mudarEstado = false;

  List<Produto> get getCarrinho => [..._carrinho];
  List<Produto> get getLista => [..._list];
  bool get getEstado => _mudarEstado;

  ListaDeProdutos() {
    carregarSugestoes();
  }

  List<Map<String, dynamic>> _sugestoes = [];

  List<Map<String, dynamic>> get sugestoes {
    return _sugestoes.where((sugestao) {
      final nomeSugestao = (sugestao['nome'] as String).toLowerCase();
      final existeNaLista = _list.any(
        (p) => p.nome.toLowerCase() == nomeSugestao,
      );
      final existeNoCarrinho = _carrinho.any(
        (p) => p.nome.toLowerCase() == nomeSugestao,
      );

      return !existeNaLista && !existeNoCarrinho;
    }).toList();
  }

  Future<void> carregarSugestoes() async {
    _sugestoes = await DbHelper.instance.getItensFrequentes();
    notifyListeners();
  }

  Future<void> finalizarCompra({String? apelido}) async {
    if (_carrinho.isEmpty) return;

    final novaCompra = Compra(
      id: const Uuid().v4(),
      nome: apelido,
      data: DateTime.now(),
      valorTotal: valorTotalCarrinho(),
      itens: [..._carrinho],
    );

    await DbHelper.instance.salvarCompra(novaCompra);

    _carrinho.clear();
    _list.clear();

    _persistirRascunho();

    notifyListeners();
  }

  void excluirProduto(Produto produto) {
    _list.removeWhere((p) => p.id == produto.id);
    _carrinho.removeWhere((p) => p.id == produto.id);
    notifyListeners();
  }

  void reordenarLista(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = _list.removeAt(oldIndex);
    _list.insert(newIndex, item);

    _persistirRascunho();
    notifyListeners();
  }

  void importarItens(List<Produto> itensParaImportar) {
    for (var item in itensParaImportar) {
      final jaExiste =
          _list.any((p) => p.nome.toLowerCase() == item.nome.toLowerCase()) ||
          _carrinho.any((p) => p.nome.toLowerCase() == item.nome.toLowerCase());

      if (!jaExiste) {
        _list.add(item);
      }
    }
    notifyListeners();
  }

  void ocultarCarrinho() {
    _mudarEstado = !_mudarEstado;
    notifyListeners();
  }

  double valorTotalCarrinho() {
    double total = 0;
    for (var produto in _carrinho) {
      total += produto.preco * produto.quantidade;
    }
    return total;
  }

  void adicionarProduto(String nome, int qtd, double? preco) {
    final novo = Produto(
      id: const Uuid().v4(),
      nome: nome,
      quantidade: qtd,
      preco: preco ?? 0.0,
    );

    _list.add(novo);
    _persistirRascunho();
    notifyListeners();
  }

  void atualizarProduto(Produto produtoAtualizado) {
    int index = _list.indexWhere((p) => p.id == produtoAtualizado.id);

    if (index != -1) {
      _list[index] = produtoAtualizado;
    } else {
      index = _carrinho.indexWhere((p) => p.id == produtoAtualizado.id);
      if (index != -1) {
        _carrinho[index] = produtoAtualizado;
      }
    }

    _persistirRascunho();
    notifyListeners();
  }

  Future<void> carregarRascunho() async {
    final dados = await DbHelper.instance.getRascunho();
    _list = [];
    _carrinho = [];

    for (var item in dados) {
      final p = Produto(
        id: const Uuid().v4(),
        nome: item['nome'],
        quantidade: item['quantidade'],
        preco: item['preco'],
      );

      if (item['noCarrinho'] == 1) {
        _carrinho.add(p);
      } else {
        _list.add(p);
      }
    }
    notifyListeners();
  }

  void _persistirRascunho() {
    final listaMapeada = [
      ..._list.map((p) => {...p.toMap(), 'noCarrinho': 0}),
      ..._carrinho.map((p) => {...p.toMap(), 'noCarrinho': 1}),
    ];
    DbHelper.instance.salvarNoRascunho(listaMapeada);
  }

  void inserirNoIndex(int index, Produto prod) {
    _list.insert(index, prod);
    notifyListeners();
  }

  void removerNoIndex(int index) {
    _list.removeAt(index);
    notifyListeners();
  }

  void removerProduto(Produto produto) {
    _carrinho.add(produto);
    _list.removeWhere((p) => p.id == produto.id);
    notifyListeners();
  }

  void restaurarProduto(Produto produto) {
    _list.add(produto);
    _carrinho.removeWhere((p) => p.id == produto.id);
    notifyListeners();
  }

  void editarProduto(
    Produto produtoAntigo,
    String nome,
    double preco,
    int quantidade,
  ) {
    final index = _list.indexWhere((p) => p.id == produtoAntigo.id);
    if (index != -1) {
      _list[index] = produtoAntigo.copyWith(
        nome: nome,
        preco: preco,
        quantidade: quantidade,
      );
      notifyListeners();
    }
  }
}
