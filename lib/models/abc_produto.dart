import 'dart:convert';

// Funções auxiliares
List<AbcProduto> abcProdutoFromJson(String str) =>
    List<AbcProduto>.from(json.decode(str).map((x) => AbcProduto.fromJson(x)));

/*
 * Este é o Modelo (Model) que representa a resposta do relatório
 * da Curva ABC (o RelatorioAbcDto.java da API).
 */
class AbcProduto {
  final String nomeProduto;
  final double valorTotalItem;
  final double percentualAcumulado;
  final String classe;

  AbcProduto({
    required this.nomeProduto,
    required this.valorTotalItem,
    required this.percentualAcumulado,
    required this.classe,
  });

  factory AbcProduto.fromJson(Map<String, dynamic> json) {
    return AbcProduto(
      nomeProduto: json['nomeProduto'] ?? '',
      valorTotalItem: (json['valorTotalItem'] as num?)?.toDouble() ?? 0.0,
      percentualAcumulado:
          (json['percentualAcumulado'] as num?)?.toDouble() ?? 0.0,
      classe: json['classe'] ?? '',
    );
  }
}
