import 'dart:async';
import 'dart:convert';
import 'package:app_mgr_software/dtos/registro_dto.dart';
import 'package:app_mgr_software/models/user_role.dart';
import 'package:app_mgr_software/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message; // Retorna a mensagem diretamente
}

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final ApiService _api = ApiService();

  String? _token;
  String? _userEmail;
  UserRole _userRole = UserRole.UNKNOWN;
  // --- CAMPOS ADICIONADOS ---
  String? _userName; // O nome real (ex: "Administrador Principal")
  String? _nomeUsuarioLogin; // O login (ex: "admin")
  // --- FIM DA ADIÇÃO ---

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  String? get userEmail => _userEmail;
  UserRole get userRole => _userRole;
  // --- GETTERS ADICIONADOS ---
  String? get userName => _userName;
  String? get nomeUsuarioLogin => _nomeUsuarioLogin;
  // --- FIM DA ADIÇÃO ---

  bool hasAnyRole(List<UserRole> roles) {
    return roles.contains(_userRole);
  }

  // Decodifica o token e armazena os dados na memória (estado)
  void _processLoginData(String token, Map<String, dynamic> loginData) {
    try {
      _token = token;
      _userEmail = loginData['email'];
      // --- LÓGICA ATUALIZADA ---
      // A API agora envia a 'funcao', 'nome' e 'nomeUsuario'
      _userRole = userRoleFromString(loginData['funcao']);
      _userName = loginData['nome'];
      _nomeUsuarioLogin = loginData['nomeUsuario'];
      // --- FIM DA ATUALIZAÇÃO ---

      // Atualiza o ApiService com o token atual
      ApiService.setToken(token);
    } catch (e) {
      debugPrint("Erro ao processar dados de login: $e");
      // Limpa tudo se a decodificação falhar
      _token = null;
      _userEmail = null;
      _userName = null;
      _nomeUsuarioLogin = null;
      _userRole = UserRole.UNKNOWN;
      ApiService.setToken(null);
    }
  }

  // --- MÉTODO LOGIN (ATUALIZADO) ---
  Future<void> login(String nomeUsuario, String senha) async {
    try {
      // 1. Delega a chamada de API
      final Map<String, dynamic> data = await _api.login(nomeUsuario, senha);

      // 2. A API retornou sucesso.
      final receivedToken = data['token'] as String?;
      if (receivedToken == null) {
        throw AuthException('Token não recebido do servidor.');
      }

      // 3. Processa e armazena os dados (incluindo o 'nome')
      _processLoginData(receivedToken, data);

      // 4. Guarda tudo no armazenamento seguro
      await _storage.write(key: 'jwt_token', value: _token);
      await _storage.write(
        key: 'user_role',
        value: _userRole.name,
      ); // Guarda o Enum como String
      await _storage.write(key: 'user_name', value: _userName);
      await _storage.write(key: 'user_login', value: _nomeUsuarioLogin);

      notifyListeners(); // Avisa a UI
    } catch (e) {
      await logout();
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }
  // --- FIM DO MÉTODO LOGIN ---

  // --- MÉTODO REGISTRAR (ATUALIZADO) ---
  Future<void> registrar(RegistroDto dto) async {
    try {
      // 1. Delega a chamada de API
      final response = await _api.postPublic('auth/registrar', dto.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 2. A API retornou sucesso
        final data = jsonDecode(response.body);
        final receivedToken = data['token'] as String?;
        if (receivedToken == null) {
          throw AuthException('Token não recebido do servidor após o registo.');
        }

        // 3. Processa e armazena os dados (incluindo o 'nome')
        _processLoginData(receivedToken, data);

        // 4. Guarda no armazenamento seguro
        await _storage.write(key: 'jwt_token', value: _token);
        await _storage.write(key: 'user_role', value: _userRole.name);
        await _storage.write(key: 'user_name', value: _userName);
        await _storage.write(key: 'user_login', value: _nomeUsuarioLogin);

        notifyListeners(); // Avisa a UI
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Falha ao registrar.';
        throw AuthException(message);
      }
    } catch (e) {
      await logout();
      throw AuthException(e.toString().replaceAll('Exception: ', ''));
    }
  }
  // --- FIM DO NOVO MÉTODO ---

  /// Limpa o estado e o armazenamento.
  Future<void> logout() async {
    _token = null;
    _userEmail = null;
    _userRole = UserRole.UNKNOWN;
    _userName = null; // Limpa o nome
    _nomeUsuarioLogin = null; // Limpa o login
    ApiService.setToken(null);
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_role');
    await _storage.delete(key: 'user_name'); // Limpa do armazenamento
    await _storage.delete(key: 'user_login'); // Limpa do armazenamento
    notifyListeners();
  }

  /// Tenta carregar o token e a função do armazenamento ao iniciar o app.
  Future<bool> tryAutoLogin() async {
    final storedToken = await _storage.read(key: 'jwt_token');

    if (storedToken == null || JwtDecoder.isExpired(storedToken)) {
      await logout();
      return false;
    }

    // --- LÓGICA ATUALIZADA ---
    // Reconstrói os dados do utilizador a partir do armazenamento
    final storedRole = await _storage.read(key: 'user_role');
    final storedName = await _storage.read(key: 'user_name');
    final storedLogin = await _storage.read(key: 'user_login');
    final decodedToken = JwtDecoder.decode(storedToken);

    // Recria o mapa 'data' como se tivesse vindo do login
    final Map<String, dynamic> loginData = {
      'email': decodedToken['sub'], // O email está no token
      'funcao': storedRole,
      'nome': storedName,
      'nomeUsuario': storedLogin,
    };

    _processLoginData(storedToken, loginData);
    // --- FIM DA ATUALIZAÇÃO ---

    notifyListeners();
    return true;
  }
}
