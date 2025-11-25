import 'package:app_mgr_software/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // CORREÇÃO: Busca a instância global do AuthService através do Provider
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      // Adicionado um AppBar para consistência visual
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Cabeçalho com Informações do Usuário ---
          _buildProfileHeader(context, theme, authService),
          const SizedBox(height: 24),
          // --- Opções de Navegação ---
          _buildMenuTile(
            context: context,
            icon: Icons.person_outline,
            title: 'Meu Perfil',
            routeName: '/perfil',
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Configurações',
            routeName: '/settings',
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.help_outline,
            title: 'Ajuda & Suporte',
            routeName: '/ajuda_suporte',
          ),
          const Divider(height: 32),
          // --- Ação de Sair ---
          _buildMenuTile(
            context: context,
            icon: Icons.logout,
            title: 'Sair',
            onTap: () async {
              // Chama o método de logout para limpar o token e os dados
              await authService.logout();
              // Navega para a tela de login, garantindo que o usuário
              // não possa voltar para a tela anterior.
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              }
            },
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para o cabeçalho do perfil
  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    AuthService authService,
  ) {
    // CORREÇÃO: Usa o novo getter 'userEmail' para obter os dados
    final userEmail = authService.userEmail;
    final displayName = userEmail?.split('@').first ?? 'Usuário';

    return Column(
      children: [
        const SizedBox(height: 20),
        Icon(Icons.account_circle, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          displayName,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          userEmail ?? 'Login realizado',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600], // CORREÇÃO: Evita o 'withOpacity' depreciado
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
      ],
    );
  }

  // Widget auxiliar para criar cada item da lista do menu
  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? routeName,
    VoidCallback? onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final tileColor = color ?? theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: tileColor),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: tileColor, fontWeight: FontWeight.w500),
      ),
      trailing: (onTap == null)
          ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)
          : null,
      onTap: onTap ?? () => Navigator.pushNamed(context, routeName!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
