import 'dart:convert';
import 'package:app_mgr_software/dtos/usuario_request_dto.dart';
import 'package:app_mgr_software/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart'; // O nosso serviço central

/*
 * Classe auxiliar para lidar com a resposta paginada da API
 * para /api/usuarios
 */
class PaginaUsuarios {
  final List<Usuario> usuarios;
  final int totalPages;
  final int totalElements;

  PaginaUsuarios({
    required this.usuarios,
    required this.totalPages,
    required this.totalElements,
  });
}

/*
 * Este serviço gere toda a comunicação com o endpoint /api/usuarios
 * usando o ApiService centralizado.
 */
class UsuarioService {
  final ApiService _api = ApiService();
  final String _endpoint = 'usuarios';

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

  /// Busca a lista paginada de usuários
  Future<PaginaUsuarios> listarUsuarios({int page = 0, int size = 10}) async {
    // Monta a URL com os parâmetros de paginação
    final url = '$_endpoint?page=$page&size=$size&sort=nome';

    try {
      final response = await _api.get(url); // Ex: GET /api/usuarios?page=0...

      if (response.statusCode == 200) {
        // Decodifica a resposta paginada completa
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );

        // Pega a lista de usuários de dentro do 'content'
        final List<dynamic> content = data['content'];
        final List<Usuario> usuarios =
            content.map((json) => Usuario.fromJson(json)).toList();

        // Retorna o objeto de paginação completo
        return PaginaUsuarios(
          usuarios: usuarios,
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

  /// Busca um único usuário pelo ID
  Future<Usuario> buscarUsuarioPorId(int id) async {
    try {
      final response = await _api.get(
        '$_endpoint/$id',
      ); // Ex: GET /api/usuarios/1

      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Cria um novo usuário (Admin ou Logística/Financeiro)
  Future<Usuario> criarUsuario(UsuarioRequestDto dto) async {
    try {
      // O DTO (do ficheiro db:121) já está correto
      final response = await _api.post(
        _endpoint,
        dto.toJson(),
      ); // Ex: POST /api/usuarios

      if (response.statusCode == 201) {
        return Usuario.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // TODO: Adicionar 'atualizarUsuario(int id, UsuarioRequestDto dto)'
  // Ele será um `_api.put('$_endpoint/$id', dto.toJson())`
  // (A sua API Java ainda não tem este endpoint)

  /// Deleta (Inativa) um usuário
  Future<void> inativarUsuario(int id) async {
    try {
      final response = await _api.delete(
        '$_endpoint/$id',
      ); // Ex: DELETE /api/usuarios/1

      if (response.statusCode != 204) {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
