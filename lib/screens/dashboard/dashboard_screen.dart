import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user_role.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/produto_provider.dart';
import '../../services/auth_service.dart';
// import '../estoque/consulta_estoque_screen.dart'; // Importação não utilizada

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitialDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialDataLoaded) {
      _isInitialDataLoaded = true;
      _recarregarDashboard();
    }
  }

  Future<void> _recarregarDashboard() async {
    final dashboardProvider = context.read<DashboardProvider>();
    final produtoProvider = context.read<ProdutoProvider>();

    try {
      await Future.wait([
        dashboardProvider.fetchSummary(),
        produtoProvider.buscarProdutosIniciais(),
      ]);
    } catch (error) {
      debugPrint("Erro inesperado ao recarregar o dashboard: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro ao carregar os dados.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, ProdutoProvider>(
      builder: (context, dashboardProvider, produtoProvider, child) {
        if ((dashboardProvider.isLoading &&
                dashboardProvider.summary == null) ||
            (produtoProvider.isLoading && produtoProvider.produtos.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        if ((dashboardProvider.hasError && dashboardProvider.summary == null) ||
            (produtoProvider.hasError && produtoProvider.produtos.isEmpty)) {
          return _buildErrorState(dashboardProvider, produtoProvider);
        }

        return _buildDashboardContent(
          context,
          dashboardProvider,
          produtoProvider,
        );
      },
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    DashboardProvider dashboardProvider,
    ProdutoProvider produtoProvider,
  ) {
    final authService = context.read<AuthService>();
    final nomeUsuario =
        authService.userName ??
        authService.userEmail?.split('@').first ??
        'Usuário';

    return RefreshIndicator(
      onRefresh: _recarregarDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, nomeUsuario),
            const SizedBox(height: 24),
            _buildSummaryGrid(context, dashboardProvider, produtoProvider),
            const SizedBox(height: 24),
            _buildAcoesRapidasCard(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String nomeUsuario) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Olá, $nomeUsuario',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Aqui está um resumo do seu negócio hoje.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(
    BuildContext context,
    DashboardProvider dashboardProvider,
    ProdutoProvider produtoProvider,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final summary = dashboardProvider.summary;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      // --- CORREÇÃO DE OVERFLOW ---
      // Damos um pouco mais de altura para os cartões
      childAspectRatio: 1.0,
      // --- FIM DA CORREÇÃO ---
      children: [
        _buildSummaryCard(
          context: context,
          icon: Icons.inventory_2_outlined,
          title: 'Produtos Cadastrados',
          value: produtoProvider.totalProdutos.toString(),
          color: Theme.of(context).colorScheme.primary,
          onTap: () => Navigator.pushNamed(context, '/estoque/consulta'),
        ),
        _buildSummaryCard(
          context: context,
          icon: Icons.attach_money_outlined,
          title: 'Valor Total em Estoque',
          value:
              summary != null
                  ? currencyFormat.format(summary.valorTotalEstoque)
                  : '...',
          color: Colors.green.shade700,
          onTap: () {},
        ),
        _buildSummaryCard(
          context: context,
          icon: Icons.warning_amber_rounded,
          title: 'Estoque Baixo',
          value: summary?.produtosEstoqueBaixo.toString() ?? '...',
          color: Colors.orange.shade800,
          onTap: () => Navigator.pushNamed(context, '/notificacoes'),
        ),
        _buildSummaryCard(
          context: context,
          icon: Icons.history_toggle_off,
          title: 'Mov. Hoje',
          value: summary?.movimentacoesHoje.toString() ?? '...',
          color: Colors.purple.shade700,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween, // Removido
            children: [
              Icon(icon, size: 32, color: color),

              // --- CORREÇÃO DE OVERFLOW (Início) ---
              // O Spacer() foi removido.
              // O Expanded 'dá' todo o espaço restante para os textos
              // e alinha-os ao fundo.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // Alinha em baixo
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // O FittedBox encolhe o texto do valor
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // O maxLines: 2 permite que o título quebre a linha
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // --- FIM DA CORREÇÃO ---
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAcoesRapidasCard(BuildContext context) {
    final authService = context.read<AuthService>();
    final theme = Theme.of(context);

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Ações Rápidas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: theme.dividerColor, height: 24, thickness: 1),
            if (authService.hasAnyRole([
              UserRole.SUPER_USER,
              UserRole.ADMIN,
              UserRole.LOGISTICA,
            ])) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/estoque/entrada').then((res) {
                    if (res == true && mounted) _recarregarDashboard();
                  });
                },
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('Cadastrar Novo Produto'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/estoque/movimentar').then((
                    res,
                  ) {
                    if (res == true && mounted) _recarregarDashboard();
                  });
                },
                icon: const Icon(Icons.sync_alt),
                label: const Text('Movimentar Estoque'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    DashboardProvider dashboardProvider,
    ProdutoProvider produtoProvider,
  ) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 64),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar o dashboard: ${dashboardProvider.errorMessage.isNotEmpty ? dashboardProvider.errorMessage : produtoProvider.errorMessage}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
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
              onPressed: _recarregarDashboard,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
