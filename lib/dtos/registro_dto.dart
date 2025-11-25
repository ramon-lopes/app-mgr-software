import 'package:app_mgr_software/models/user_role.dart';

/*
 * DTO (Data Transfer Object) para o registo de uma nova Conta (empresa)
 * e o seu primeiro Utilizador (admin).
 * Os nomes dos campos correspondem exatamente ao JSON que a API Java espera.
 */
class RegistroDto {
  // --- Dados da Empresa (Conta) ---
  final String usuarioConta;
  final String nomeEmpresa;
  final String cnpj;
  final String emailEmpresa;
  final String? telefoneEmpresa;

  // --- Dados do Administrador (Usuario) ---
  final String nomeUsuarioAdmin;
  final String nomeUsuarioLogin;
  final String emailUsuarioAdmin;
  final String senhaUsuarioAdmin;
  final UserRole funcao;

  RegistroDto({
    required this.usuarioConta,
    required this.nomeEmpresa,
    required this.cnpj,
    required this.emailEmpresa,
    this.telefoneEmpresa,
    required this.nomeUsuarioAdmin,
    required this.nomeUsuarioLogin,
    required this.emailUsuarioAdmin,
    required this.senhaUsuarioAdmin,
    // O primeiro utilizador deve ser sempre SUPER_USER
    this.funcao = UserRole.SUPER_USER,
  });

  /// Converte este objeto Dart para um Map JSON.
  Map<String, dynamic> toJson() {
    return {
      'usuarioConta': usuarioConta,
      'nomeEmpresa': nomeEmpresa,
      'cnpj': cnpj,
      'emailEmpresa': emailEmpresa,
      'telefoneEmpresa': telefoneEmpresa,
      'nomeUsuarioAdmin': nomeUsuarioAdmin,
      'nomeUsuarioLogin': nomeUsuarioLogin,
      'emailUsuarioAdmin': emailUsuarioAdmin,
      'senhaUsuarioAdmin': senhaUsuarioAdmin,
      // Converte o Enum para a String que a API Java espera
      'funcao': funcao.toString().split('.').last,
    };
  }
}
