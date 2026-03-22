import 'produto.dart';

class Compra {
  final String id;
  final String? nome;
  final DateTime data;
  final double valorTotal;
  final List<Produto> itens;

  Compra({
    required this.id,
    required this.nome,
    required this.data,
    required this.valorTotal,
    required this.itens,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'data': data.toIso8601String(),
      'valorTotal': valorTotal,
    };
  }
}
