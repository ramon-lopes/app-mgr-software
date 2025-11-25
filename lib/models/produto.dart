import 'package:app_mgr_software/models/categoria.dart';
import 'dart:convert'; // Necessário para o helper

// Helper (opcional, mas bom de ter)
Produto produtoFromJson(String str) => Produto.fromJson(json.decode(str));

class Produto {
  final int id;
  final String sku;
  final String nome;
  final String? descricao;
  final String? codigoDeBarras;
  final double quantidadeEmEstoque;
  final double estoqueMinimo;
  final double? precoCusto;
  final int versao;
  final bool ativo;
  final Categoria? categoria;

  // --- CAMPO ADICIONADO ---
  // A API envia a data de criação (ex: "2025-11-08T10:00:00")
  final DateTime? criadoEm;
  // --- FIM DA ADIÇÃO ---

  Produto({
    required this.id,
    required this.sku,
    required this.nome,
    this.descricao,
    this.codigoDeBarras,
    required this.quantidadeEmEstoque,
    required this.estoqueMinimo,
    this.precoCusto,
    required this.versao,
    this.categoria,
    required this.ativo,
    this.criadoEm, // Adicionado ao construtor
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'] ?? 0,
      sku: json['sku'] ?? '',
      nome: json['nome'] ?? 'Nome não informado',
      descricao: json['descricao'],
      codigoDeBarras: json['codigoDeBarras'],
      quantidadeEmEstoque:
          (json['quantidadeEmEstoque'] as num?)?.toDouble() ?? 0.0,
      estoqueMinimo: (json['estoqueMinimo'] as num?)?.toDouble() ?? 0.0,
      precoCusto: (json['precoCusto'] as num?)?.toDouble(),
      versao: json['versao'] ?? 0,
      ativo: json['ativo'] ?? false,
      categoria:
          json['categoria'] != null
              ? Categoria.fromJson(json['categoria'])
              : null,

      // --- LÓGICA DE PARSING ADICIONADA ---
      // A API envia uma String (ex: "2025-11-08T10:00:00"),
      // nós convertemo-la para um objeto DateTime do Dart.
      criadoEm:
          json['criadoEm'] != null ? DateTime.parse(json['criadoEm']) : null,
      // --- FIM DA ADIÇÃO ---
    );
  }
}
