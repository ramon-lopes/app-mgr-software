/*
 * DTO (Data Transfer Object) para CRIAR ou ATUALIZAR uma Categoria.
 * Os nomes dos campos correspondem exatamente ao JSON que a API Java espera
 * (que é o CategoriaDto.java).
 */
class CategoriaRequestDto {
  final String nome;
  final String? descricao;
  // O ID não é necessário no Request, pois a API o gera (no POST)
  // ou o recebe pela URL (no PUT).

  CategoriaRequestDto({required this.nome, this.descricao});

  /// Converte este objeto Dart para um Map JSON.
  Map<String, dynamic> toJson() {
    return {'nome': nome, 'descricao': descricao};
  }
}
