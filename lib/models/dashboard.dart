import 'dart:convert';

// Função auxiliar (opcional, mas boa prática)
DashboardSummary dashboardSummaryFromJson(String str) =>
    DashboardSummary.fromJson(json.decode(str));

/*
 * Este é o Modelo (Model) que representa os dados do seu Dashboard.
 * (Extraído do ficheiro do provider para seguir as boas práticas).
 */
class DashboardSummary {
  final double valorTotalEstoque;
  // Os campos 'long' da API Java são lidos como 'int' no Dart
  final int produtosEstoqueBaixo;
  final int movimentacoesHoje;

  DashboardSummary({
    required this.valorTotalEstoque,
    required this.produtosEstoqueBaixo,
    required this.movimentacoesHoje,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      // A API Java envia 'BigDecimal', que o jsonDecode lê como 'double' ou 'int'
      valorTotalEstoque: (json['valorTotalEstoque'] as num?)?.toDouble() ?? 0.0,
      // A API Java envia 'long', que o jsonDecode lê como 'int'
      produtosEstoqueBaixo: json['produtosEstoqueBaixo'] ?? 0,
      movimentacoesHoje: json['movimentacoesHoje'] ?? 0,
    );
  }
}
