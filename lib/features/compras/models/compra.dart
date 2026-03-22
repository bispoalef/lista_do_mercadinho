import 'produto.dart';

class Compra {
  final String id;
  final DateTime data;
  final double valorTotal;
  final List<Produto> itens;

  Compra({
    required this.id,
    required this.data,
    required this.valorTotal,
    required this.itens,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'data': data.toIso8601String(), 'valorTotal': valorTotal};
  }
}
