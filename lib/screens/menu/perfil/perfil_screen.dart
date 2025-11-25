import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // CORREÇÃO: Busca os dados do usuário logado através do Provider
    final authService = Provider.of<AuthService>(context, listen: false);
    final userEmail = authService.userEmail;
    final displayName = userEmail?.split('@').first ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(theme, displayName),
          const SizedBox(height: 24),
          _buildInfoCard(theme, displayName, userEmail),
        ],
      ),
    );
  }

  /// Constrói o cabeçalho com a foto e nome do usuário.
  Widget _buildProfileHeader(ThemeData theme, String displayName) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.person, size: 60, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Nível de Acesso: Administrador', // Exemplo
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  /// Constrói o card com as informações pessoais (apenas visualização).
  Widget _buildInfoCard(ThemeData theme, String displayName, String? userEmail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informações Pessoais', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.person_outline,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Nome de Usuário'),
              subtitle: Text(
                displayName,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Divider(height: 16),
            ListTile(
              leading: Icon(
                Icons.email_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text('E-mail'),
              subtitle: Text(
                userEmail ?? 'E-mail não informado',
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
