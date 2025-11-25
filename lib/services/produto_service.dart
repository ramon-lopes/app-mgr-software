import 'dart:convert';

import 'package:app_mgr_software/dtos/movimento_dto.dart';
import 'package:app_mgr_software/dtos/produto_request_dto.dart';
import 'package:app_mgr_software/models/abc_produto.dart';
import 'package:app_mgr_software/models/posicao_estoque.dart';
import 'package:app_mgr_software/models/produto.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

// Classe de Paginação (Necessária para o Provider)
class PaginaProdutos {
  final List<Produto> produtos;
  final int totalPages;
  final int totalElements;

  PaginaProdutos({
    required this.produtos,
    required this.totalPages,
    required this.totalElements,
  });
}

class ProdutoService {
  final ApiService _api = ApiService();
  final String _endpoint = 'produtos';

  Exception _handleError(http.Response response) {
    try {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final errorMessage =
          errorBody['message'] ??
          errorBody['error'] ??
          'Ocorreu um erro desconhecido.';
      return Exception(errorMessage);
    } catch (e) {
      return Exception(
        'Falha ao comunicar com o servidor. Código: ${response.statusCode}',
      );
    }
  }

  // Método buscarProdutos (Correto, retorna PaginaProdutos)
  Future<PaginaProdutos> buscarProdutos({int page = 0, int size = 10}) async {
    final url = '$_endpoint?page=$page&size=$size&sort=nome';

    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> content = data['content'];
        final List<Produto> produtos =
            content.map((json) => Produto.fromJson(json)).toList();

        return PaginaProdutos(
          produtos: produtos,
          totalPages: data['totalPages'],
          totalElements: data['totalElements'],
        );
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // (O resto dos métodos [buscarPorSku, movimentar, CRUD] permanecem iguais)
  // ... (código db:204 - buscarProdutoPorSku) ...
  Future<Produto?> buscarProdutoPorSku(String sku) async {
    final url = '$_endpoint/sku/$sku';
    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      if (response.statusCode == 404) {
        return null;
      }
      throw _handleError(response);
    } catch (e) {
      rethrow;
    }
  }

  // -----------------------------------------------------------------
  // --- NOVO MÉTODO ADICIONADO (PARA O SCANNER) ---
  /// Busca um produto pelo seu código de barras.
  Future<Produto?> buscarProdutoPorCodigoDeBarras(String barcode) async {
    // A sua API Spring Boot (Controller) precisa ter este endpoint
    final url = '$_endpoint/barcode/$barcode';

    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        // Produto encontrado
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      if (response.statusCode == 404) {
        // Produto não encontrado com este código de barras
        return null;
      }
      // Outro erro (500, 400, etc.)
      throw _handleError(response);
    } catch (e) {
      // Erro de rede ou timeout
      rethrow;
    }
  }
  // --- FIM DO NOVO MÉTODO ---
  // -----------------------------------------------------------------

  // ... (código db:204 - movimentarEstoque) ...
  Future<Produto> movimentarEstoque(int produtoId, MovimentoDto dto) async {
    final url = '$_endpoint/movimentar/$produtoId';
    try {
      final response = await _api
          .post(url, dto.toJson())
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ... (código db:204 - criarProduto) ...
  Future<Produto> criarProduto(ProdutoRequestDto dto) async {
    final url = _endpoint;
    try {
      final response = await _api.post(url, dto.toJson());
      if (response.statusCode == 201) {
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ... (código db:204 - atualizarProduto) ...
  Future<Produto> atualizarProduto(int produtoId, ProdutoRequestDto dto) async {
    final url = '$_endpoint/$produtoId';
    try {
      final response = await _api.put(url, dto.toJson());
      if (response.statusCode == 200) {
        return Produto.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ... (código db:204 - deletarProduto) ...
  Future<void> deletarProduto(int produtoId) async {
    final url = '$_endpoint/$produtoId';
    try {
      final response = await _api
          .delete(url)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO CORRIGIDO ---
  // O 'ProdutoProvider' (db:221) precisa que este método
  // retorne 'List<RelatorioPosicaoEstoque>'
  Future<List<RelatorioPosicaoEstoque>> buscarTodosParaRelatorio() async {
    final url = '$_endpoint/relatorio/posicao-estoque';
    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        // CORREÇÃO: Mapeia para o Modelo correto
        return jsonList
            .map((json) => RelatorioPosicaoEstoque.fromJson(json))
            .toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
  // --- FIM DA CORREÇÃO ---

  // (Método buscarProdutosComAlerta inalterado)
  Future<List<Produto>> buscarProdutosComAlerta() async {
    final url = '$_endpoint/alertas/estoque-baixo';
    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonList.map((json) => Produto.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // (Método buscarDadosCurvaAbc inalterado)
  Future<List<AbcProduto>> buscarDadosCurvaAbc() async {
    final url = '$_endpoint/relatorio/curva-abc';
    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonList.map((json) => AbcProduto.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- NOVO MÉTODO ADICIONADO ---
  /// Busca produtos cadastrados (da API) que estão dentro de um período.
  /// (Usado pelo RelatoriosScreen)
  Future<List<Produto>> buscarProdutosPorPeriodo(
    DateTime dataInicial,
    DateTime dataFinal,
  ) async {
    // Converte as datas do Dart para o formato ISO String que o Java espera
    final de = dataInicial.toIso8601String();
    final ate = dataFinal.toIso8601String();

    // Chama o novo endpoint da API: /api/produtos/por-periodo?dataInicial=...
    final url = '$_endpoint/por-periodo?dataInicial=$de&dataFinal=$ate';

    try {
      final response = await _api.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        // Mapeia para o Modelo 'Produto' (o 'criadoEm' será preenchido)
        return jsonList.map((json) => Produto.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
