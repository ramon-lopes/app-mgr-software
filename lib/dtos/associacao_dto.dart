class AssociacaoRequestDto {
  final int fornecedorId;
  final double precoCusto;
  final String? codigoProdutoFornecedor;

  AssociacaoRequestDto({
    required this.fornecedorId,
    required this.precoCusto,
    this.codigoProdutoFornecedor,
  });

  Map<String, dynamic> toJson() {
    return {
      'idFornecedor': fornecedorId,
      'precoCusto': precoCusto,
      'codigoProdutoNoFornecedor': codigoProdutoFornecedor,
    };
  }
}
