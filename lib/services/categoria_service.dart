import 'dart:convert';
import 'package:app_mgr_software/dtos/categoria_request_dto.dart';
import 'package:app_mgr_software/models/categoria.dart';
import 'package:app_mgr_software/services/api_service.dart';
import 'package:http/http.dart' as http;

/*
 * Este serviço gere toda a comunicação com o endpoint /api/categorias
 * usando o ApiService centralizado.
 */
class CategoriaService {
  final ApiService _api = ApiService();
  final String _endpoint = 'categorias';

  // Função auxiliar para tratar erros (padrão)
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

  /// Busca a lista "limpa" de categorias (a API Java já removeu a paginação)
  Future<List<Categoria>> buscarCategorias() async {
    try {
      final response = await _api.get(_endpoint); // Ex: GET /api/categorias

      if (response.statusCode == 200) {
        // A API retorna uma lista "limpa" [ ... ]
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonList.map((json) => Categoria.fromJson(json)).toList();
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Busca uma única categoria pelo ID
  Future<Categoria> buscarCategoriaPorId(int id) async {
    try {
      final response = await _api.get(
        '$_endpoint/$id',
      ); // Ex: GET /api/categorias/3

      if (response.statusCode == 200) {
        return Categoria.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cria uma nova categoria
  Future<Categoria> criarCategoria(CategoriaRequestDto dto) async {
    try {
      final response = await _api.post(
        _endpoint,
        dto.toJson(),
      ); // Ex: POST /api/categorias

      if (response.statusCode == 201) {
        return Categoria.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Atualiza uma categoria existente
  Future<Categoria> atualizarCategoria(int id, CategoriaRequestDto dto) async {
    try {
      final response = await _api.put(
        '$_endpoint/$id',
        dto.toJson(),
      ); // Ex: PUT /api/categorias/3

      if (response.statusCode == 200) {
        return Categoria.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Deleta (Inativa) uma categoria
  Future<void> deletarCategoria(int id) async {
    try {
      final response = await _api.delete(
        '$_endpoint/$id',
      ); // Ex: DELETE /api/categorias/3

      if (response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
