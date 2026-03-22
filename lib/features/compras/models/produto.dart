class Produto {
  final String id;
  final String nome;
  final double preco;
  final int quantidade;

  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.quantidade,
  });

  // O método copyWith é o padrão da indústria para atualizar estados imutáveis
  Produto copyWith({
    String? id,
    String? nome,
    double? preco,
    int? quantidade,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
    );
  }

  @override
  String toString() {
    return 'Produto(id: $id, nome: $nome, preco: $preco, quantidade: $quantidade)';
  }
}
