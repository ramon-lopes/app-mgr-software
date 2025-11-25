import 'package:app_mgr_software/providers/produto_provider.dart';
import 'package:app_mgr_software/services/auth_service.dart';
import 'package:app_mgr_software/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EstoqueScreen extends StatelessWidget {
  const EstoqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProdutoProvider>(
      builder: (context, produtoProvider, child) {
        if (produtoProvider.isLoading && produtoProvider.produtos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (produtoProvider.hasError && produtoProvider.produtos.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar produtos: ${produtoProvider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => produtoProvider.buscarProdutosIniciais(),
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildConteudoPrincipal(context, produtoProvider);
      },
    );
  }

  Widget _buildConteudoPrincipal(
    BuildContext context,
    ProdutoProvider provider,
  ) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visão Geral',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.totalProdutos == 0
                        ? 'Nenhum produto cadastrado.'
                        : 'Total de produtos cadastrados: ${provider.totalProdutos}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (authService.hasAnyRole([
            UserRole.SUPER_USER,
            UserRole.ADMIN,
            UserRole.LOGISTICA,
          ]))
            _buildMenuCard(
              context: context,
              icon: Icons.add_box_outlined,
              title: 'Entrada de Produto',
              subtitle: 'Registrar novas mercadorias',
              routeName: '/estoque/entrada',
            ),

          if (authService.hasAnyRole([
            UserRole.SUPER_USER,
            UserRole.ADMIN,
            UserRole.LOGISTICA,
          ]))
            _buildMenuCard(
              context: context,
              icon: Icons.indeterminate_check_box_outlined,
              title: 'Baixa de Produto',
              subtitle: 'Registrar saídas e vendas',
              routeName: '/estoque/baixa',
            ),

          _buildMenuCard(
            context: context,
            icon: Icons.search,
            title: 'Consultar Estoque',
            subtitle: 'Visualizar todos os produtos',
            routeName: '/estoque/consulta',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () => Navigator.pushNamed(context, routeName),
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28.0,
                  color: theme.colorScheme.primaryContainer,
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 18.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
