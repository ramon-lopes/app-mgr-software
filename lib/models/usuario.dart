import 'package:app_mgr_software/models/user_role.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;
  final UserRole funcao;
  final bool ativo;

  // --- CAMPOS ADICIONADOS ---
  // A API também envia o nome de login (ex: 'admin')
  final String nomeUsuario;
  // A API envia a data de criação
  final DateTime criadoEm;
  // --- FIM ---

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.funcao,
    required this.ativo,
    required this.nomeUsuario, // Adicionado ao construtor
    required this.criadoEm, // Adicionado ao construtor
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      funcao: userRoleFromString(json['funcao']),
      ativo: json['ativo'],
      // --- CAMPOS ADICIONADOS ---
      nomeUsuario: json['nomeUsuario'] ?? '',
      // A API Java envia um Timestamp (String ISO 8601), convertemos para DateTime
      criadoEm: DateTime.parse(
        json['criadoEm'] ?? DateTime.now().toIso8601String(),
      ),
      // --- FIM ---
    );
  }
}
