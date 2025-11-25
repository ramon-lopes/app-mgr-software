import 'package:app_mgr_software/models/user_role.dart';

/*
 * DTO (Data Transfer Object) para CRIAR ou ATUALIZAR um Usuário.
 * Os nomes dos campos correspondem exatamente ao JSON que a API Java espera.
 */
class UsuarioRequestDto {
  final String nome;

  // --- CAMPO ADICIONADO ---
  // A API Java (UsuarioRequestDto) exige este campo
  final String nomeUsuario;
  // --- FIM DA ADIÇÃO ---

  final String email;

  // --- CORRIGIDO: Opcional para obrigatório ---
  // A API Java (UsuarioRequestDto) exige a senha na criação (@NotBlank)
  final String senha;
  // --- FIM DA CORREÇÃO ---

  final UserRole funcao;

  UsuarioRequestDto({
    required this.nome,
    required this.nomeUsuario, // Adicionado ao construtor
    required this.email,
    required this.senha, // Corrigido para obrigatório
    required this.funcao,
  });

  /// Converte este objeto Dart para um Map JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nome': nome,
      'nomeUsuario': nomeUsuario, // Adicionado ao JSON
      'email': email,
      // --- CORRIGIDO: O nome da chave ---
      // A API Java espera 'senha', não 'senhaHash'.
      // A API é que vai criptografar (fazer o hash).
      'senha': senha,
      // --- FIM DA CORREÇÃO ---
      'funcao':
          funcao
              .toString()
              .split('.')
              .last, // Converte o enum para String (Ex: "SUPER_USER")
    };
    return data;
  }
}
