/*
 * Este ficheiro é necessário para o 'usuario.dart' funcionar.
 * Ele define o Enum e a função de conversão.
 */

// 1. O Enum (copiado da sua API Java)
enum UserRole {
  SUPER_USER,
  ADMIN,
  FINANCEIRO,
  LOGISTICA,
  UNKNOWN, // Um valor padrão caso a API envie algo inesperado
}

// 2. A função de conversão (que 'Usuario.fromJson' usa)
UserRole userRoleFromString(String? role) {
  switch (role) {
    case 'SUPER_USER':
      return UserRole.SUPER_USER;
    case 'ADMIN':
      return UserRole.ADMIN;
    case 'FINANCEIRO':
      return UserRole.FINANCEIRO;
    case 'LOGISTICA':
      return UserRole.LOGISTICA;
    default:
      return UserRole.UNKNOWN;
  }
}
