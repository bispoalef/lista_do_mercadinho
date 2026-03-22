import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Precisamos disso para gerar o ID da Compra

import '../../../core/database/db_helper.dart';
import '../models/compra.dart';
import '../models/produto.dart';

class ListaDeProdutos extends ChangeNotifier {
  final List<Produto> _list = [];
  final List<Produto> _carrinho = [];
  bool _mudarEstado = false;

  List<Produto> get getCarrinho => [..._carrinho];
  List<Produto> get getLista => [..._list];
  bool get getEstado => _mudarEstado;

  ListaDeProdutos() {
    carregarSugestoes();
  }

  List<Map<String, dynamic>> _sugestoes = [];
  List<Map<String, dynamic>> get sugestoes => [..._sugestoes];

  // O método carregarSugestoes sofre uma pequena alteração para aceitar o Map
  Future<void> carregarSugestoes() async {
    _sugestoes = await DbHelper.instance.getItensFrequentes();
    notifyListeners();
  }

  Future<void> finalizarCompra() async {
    if (_carrinho.isEmpty) return;

    final novaCompra = Compra(
      id: const Uuid().v4(),
      data: DateTime.now(),
      valorTotal: valorTotalCarrinho(),
      itens: [..._carrinho],
    );

    await DbHelper.instance.salvarCompra(novaCompra);

    _carrinho.clear();

    await carregarSugestoes();

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

  void adicionarProduto(Produto produto) {
    _list.add(produto);
    notifyListeners();
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
