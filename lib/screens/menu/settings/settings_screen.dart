import 'package:app_mgr_software/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificacoesEstoque = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSectionHeader('Aparência'),
          // O Consumer reconstrói apenas este widget quando o tema muda.
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return _buildThemeSelectorTile(context, themeProvider);
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildSectionHeader('Notificações'),
          SwitchListTile(
            title: const Text('Alertas de Estoque Baixo'),
            subtitle: const Text(
              'Receber avisos quando um produto atingir o mínimo',
            ),
            value: _notificacoesEstoque,
            onChanged: (bool value) {
              setState(() => _notificacoesEstoque = value);
            },
            secondary: const Icon(Icons.notifications_active_outlined),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          const Divider(indent: 16, endIndent: 16),
          _buildSectionHeader('Sobre'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre o App'),
            subtitle: const Text('Veja os detalhes da licença e do software'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'MGR Software Gestor',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    '© 2025 MGR Software. Todos os direitos reservados.',
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'Software de gestão empresarial para otimizar seu negócio.',
                    ),
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Termos de Serviço'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ALTERAÇÃO: O método agora recebe o ThemeProvider
  Widget _buildThemeSelectorTile(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    String themeText;
    switch (themeProvider.themeMode) {
      case ThemeMode.light:
        themeText = 'Claro';
        break;
      case ThemeMode.dark:
        themeText = 'Escuro';
        break;
      case ThemeMode.system:
        themeText = 'Sistema';
        break;
    }

    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Tema do Aplicativo'),
      subtitle: Text(themeText),
      onTap: () => _showThemeDialog(context, themeProvider),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha um Tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Claro'),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    // ALTERAÇÃO: Chama o método do provedor para trocar o tema
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Escuro'),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Padrão do Sistema'),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
