import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AjudaSuporteScreen extends StatelessWidget {
  const AjudaSuporteScreen({super.key});

  // Função para lançar URLs (email, telefone, etc)
  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajuda & Suporte')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            context,
            title: 'Perguntas Frequentes (FAQ)',
            icon: Icons.quiz_outlined,
            children: [
              _buildFaqItem(
                'Como cadastrar um novo produto?',
                'Vá para a tela de Estoque, toque no botão "+" e preencha todas as informações solicitadas, como nome, código de barras, preço e fornecedor.',
              ),
              _buildFaqItem(
                'Como dar baixa no estoque de um produto?',
                'Na tela de Estoque, encontre o produto desejado e toque nele para ver os detalhes. Use as opções de "Entrada" ou "Saída" para ajustar a quantidade.',
              ),
              _buildFaqItem(
                'Onde vejo o relatório de vendas?',
                'Acesse a aba "Relatórios" no menu principal. Lá você encontrará diversas opções para filtrar por período, produto ou categoria de vendas.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            context,
            title: 'Entre em Contato',
            icon: Icons.contact_support_outlined,
            children: [
              _buildContactTile(
                Icons.email_outlined,
                'Enviar um E-mail',
                'suporte@sgetr.com',
                () => _launchURL(context, 'mailto:suporte@sgetr.com'),
              ),
              const Divider(height: 1),
              _buildContactTile(
                Icons.phone_outlined,
                'Ligar para o Suporte',
                '(19) 99999-8888',
                () => _launchURL(context, 'tel:+5519999998888'),
              ),
              const Divider(height: 1),
              _buildContactTile(
                Icons.message_outlined,
                'Mensagem no WhatsApp',
                'Iniciar conversa com nossa equipe',
                () => _launchURL(context, 'https://wa.me/5519999998888'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói um card de seção customizado.
  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: theme.colorScheme.primary),
            title: Text(title, style: theme.textTheme.titleLarge),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...children,
        ],
      ),
    );
  }

  /// Constrói um item da FAQ usando ExpansionTile.
  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      childrenPadding: const EdgeInsets.all(16.0),
      children: [Text(answer)],
    );
  }

  /// Constrói um item da lista de contato.
  Widget _buildContactTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
