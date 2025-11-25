/*
 * DTO (Data Transfer Object) para criar ou atualizar um Produto.
 * Os nomes dos campos correspondem exatamente ao JSON que a API Java espera.
 * Todos os IDs estão como 'int' para corresponder ao 'Integer' do Java.
 */
class ProdutoRequestDto {
  final String sku;
  final String nome;
  final String? descricao;
  final String? codigoDeBarras;
  final double estoqueMinimo;
  final int idCategoria; // ID da Categoria (int/Integer)

  ProdutoRequestDto({
    required this.sku,
    required this.nome,
    this.descricao,
    this.codigoDeBarras,
    required this.estoqueMinimo,
    required this.idCategoria,
  });

  /// Converte este objeto Dart para um Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'nome': nome,
      'descricao': descricao,
      'codigoDeBarras': codigoDeBarras,
      'estoqueMinimo': estoqueMinimo,
      'idCategoria': idCategoria,
    };
  }
}
