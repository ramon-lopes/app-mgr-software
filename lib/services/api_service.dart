import 'dart:convert'; // Para jsonEncode e jsonDecode
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Para guardar o token e o URL
// import 'package:flutter/foundation.dart'; // kDebugMode já não é necessário aqui

/*
 * O CORAÇÃO DA SUA CONEXÃO FLUTTER <-> SPRING BOOT.
 */
class ApiService {
  static String? _baseUrl;
  static String? _tokenStorage;

  /// ATUALIZADO: Esta função agora carrega SEMPRE das SharedPreferences,
  /// independentemente de ser Debug ou Release.
  static Future<void> loadBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('ngrok_url');

    if (_baseUrl == null || _baseUrl!.isEmpty) {
      // Se NENHUM URL estiver guardado (nem ngrok, nem produção),
      // ele vai falhar. Isto é o esperado.
      // O utilizador TEM de o configurar na ⚙️ engrenagem primeiro.
      throw Exception("URL da API não configurado.");
    }
  }

  /// Salva o URL base (Ngrok/Produção) na memória.
  static Future<void> saveBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ngrok_url', url);
    _baseUrl = url; // Atualiza a variável estática em tempo real
  }

  /// Utilizado pelo AuthService para definir o token a ser usado
  static void setToken(String? token) {
    _tokenStorage = token;
  }

  /// Prepara os cabeçalhos (headers) para uma requisição segura.
  Future<Map<String, String>> _getAuthHeaders() async {
    if (_tokenStorage == null) {
      // Se o auto-login falhou (ex: token expirado), o AuthService
      // deve fazer logout antes de chegar aqui.
      throw Exception('Token não encontrado, faça login novamente.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_tokenStorage', // Envia o token
      'ngrok-skip-browser-warning': 'true', // Útil para o ngrok
    };
  }

  /// Cabeçalhos para requisições públicas (login/registo).
  Map<String, String> get _publicHeaders => {
    'Content-Type': 'application/json; charset=UTF-8',
    'ngrok-skip-browser-warning': 'true', // Útil para o ngrok
  };

  // --- MÉTODOS DE REQUISIÇÃO (GET, POST, PUT, DELETE) ---

  Future<http.Response> get(String endpoint) async {
    if (_baseUrl == null) await loadBaseUrl();
    final headers = await _getAuthHeaders();
    return await http.get(
      Uri.parse('$_baseUrl/api/$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    if (_baseUrl == null) await loadBaseUrl();
    final headers = await _getAuthHeaders();
    return await http.post(
      Uri.parse('$_baseUrl/api/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    if (_baseUrl == null) await loadBaseUrl();
    final headers = await _getAuthHeaders();
    return await http.put(
      Uri.parse('$_baseUrl/api/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> delete(String endpoint) async {
    if (_baseUrl == null) await loadBaseUrl();
    final headers = await _getAuthHeaders();
    return await http.delete(
      Uri.parse('$_baseUrl/api/$endpoint'),
      headers: headers,
    );
  }

  // --- MÉTODOS PÚBLICOS (Não precisam de token) ---

  Future<http.Response> postPublic(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    if (_baseUrl == null) await loadBaseUrl();
    return await http.post(
      Uri.parse('$_baseUrl/api/$endpoint'),
      headers: _publicHeaders,
      body: jsonEncode(data),
    );
  }

  Future<Map<String, dynamic>> login(String nomeUsuario, String senha) async {
    try {
      final response = await postPublic('auth/login', {
        'nomeUsuario': nomeUsuario,
        'senha': senha,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Erro ao fazer login');
      }
    } catch (e) {
      // Se o 'postPublic' falhar (ex: 'seu-dominio-de-producao.com'),
      // é aqui que o erro (SocketFailed) é apanhado.
      throw Exception('Falha na comunicação: $e');
    }
  }
}
