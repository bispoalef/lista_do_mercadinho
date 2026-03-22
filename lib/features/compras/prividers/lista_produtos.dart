import 'package:flutter/cupertino.dart';

import '../data/lista_mocada.dart';
import '../models/produto.dart';

class ListaDeProdutos extends ChangeNotifier {
  final List<Produto> _list = List.from(listaMocada);
  final List<Produto> _carrinho = [];
  bool _mudarEstado = true;

  List<Produto> get getCarrinho => [..._carrinho];
  List<Produto> get getLista => [..._list];
  bool get getEstado => _mudarEstado;

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
