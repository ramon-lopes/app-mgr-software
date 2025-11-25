/*
 * DTO (Data Transfer Object) para enviar uma movimentação de stock.
 * Os nomes dos campos correspondem exatamente ao JSON que a API Java espera.
 */
class MovimentoDto {
  final TipoMovimentoAPI tipoMovimento;

  final double quantidade;
  final String? observacao;
  final int versao;
  final double? precoCusto; // Opcional, usado apenas em entradas

  MovimentoDto({
    required this.tipoMovimento,
    required this.quantidade,
    this.observacao,
    required this.versao,
    this.precoCusto, // Opcional
  });

  /// Converte este objeto Dart para um Map JSON.
  Map<String, dynamic> toJson() {
    return {
      // --- CORRIGIDO ---
      // Envia o nome do enum como String (ex: "SAIDA")
      'tipoMovimento': tipoMovimento.name,
      // --- FIM DA CORREÇÃO ---
      'quantidade': quantidade,
      'observacao': observacao,
      'versao': versao,
      'precoCusto': precoCusto,
    };
  }
}

// Este enum corresponde ao 'MovimentoEstoque.java' da API
enum TipoMovimentoAPI { ENTRADA, SAIDA, AJUSTE_POSITIVO, AJUSTE_NEGATIVO }
