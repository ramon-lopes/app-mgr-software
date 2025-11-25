import 'dart:convert';

// Funções auxiliares (como no seu exemplo)
List<Categoria> categoriaFromJson(String str) =>
    List<Categoria>.from(json.decode(str).map((x) => Categoria.fromJson(x)));

String categoriaToJson(Categoria data) => json.encode(data.toJson());

class Categoria {
  final int id;
  final String nome;
  final String? descricao;

  Categoria({required this.id, required this.nome, this.descricao});

  // Factory para ler o JSON da API
  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
    id: json["id"],
    nome: json["nome"],
    descricao: json["descricao"],
  );

  // toJson para enviar dados para a API
  // (Ex: ao criar/editar um Produto, podemos precisar de enviar a Categoria)
  Map<String, dynamic> toJson() => {
    "id": id,
    "nome": nome,
    "descricao": descricao,
  };
}
