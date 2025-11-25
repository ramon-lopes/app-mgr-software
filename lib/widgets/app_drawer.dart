import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userEmail = authService.userEmail;
    final displayName = userEmail?.split('@').first ?? "Utilizador";

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail ?? "Login realizado"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimary,
              child: Icon(
                Icons.person,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            decoration: BoxDecoration(color: theme.colorScheme.primary),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // --- SEÇÃO DE OPERAÇÕES ---
                _buildSectionHeader('Operações'),
                if (authService.hasAnyRole([
                  UserRole.SUPER_USER,
                  UserRole.ADMIN,
                  UserRole.LOGISTICA,
                ]))
                  _buildDrawerItem(
                    context,
                    icon: Icons.sync_alt_outlined,
                    title: 'Movimentar Estoque',
                    routeName: '/estoque/movimentar',
                  ),

                // --- SEÇÃO DE GESTÃO ---
                _buildSectionHeader('Gestão'),
                if (authService.hasAnyRole([
                  UserRole.SUPER_USER,
                  UserRole.ADMIN,
                ]))
                  _buildDrawerItem(
                    context,
                    icon: Icons.people_outline,
                    title: 'Gerir Utilizadores',
                    routeName: '/gerenciar_usuarios',
                  ),

                // --- SEÇÃO PESSOAL ---
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.person_outline,
                  title: 'Meu Perfil',
                  routeName: '/perfil',
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  routeName: '/settings',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Sair',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para criar os cabeçalhos das seções
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  // Widget auxiliar para criar os itens do menu
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String routeName,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Fecha o drawer
        Navigator.pushNamed(context, routeName);
      },
    );
  }
}
