import 'dart:convert';

// Funções auxiliares
List<RelatorioPosicaoEstoque> relatorioPosicaoEstoqueFromJson(String str) =>
    List<RelatorioPosicaoEstoque>.from(
      json.decode(str).map((x) => RelatorioPosicaoEstoque.fromJson(x)),
    );

/*
 * Este é o Modelo (Model) que representa a resposta do relatório
 * de Posição de Estoque (o RelatorioPosicaoEstoqueDto.java da API).
 */
class RelatorioPosicaoEstoque {
  final int id;
  final String nome;
  final String sku;
  final double quantidadeEmEstoque;

  RelatorioPosicaoEstoque({
    required this.id,
    required this.nome,
    required this.sku,
    required this.quantidadeEmEstoque,
  });

  factory RelatorioPosicaoEstoque.fromJson(Map<String, dynamic> json) {
    return RelatorioPosicaoEstoque(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      sku: json['sku'] ?? '',
      quantidadeEmEstoque:
          (json['quantidadeEmEstoque'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
