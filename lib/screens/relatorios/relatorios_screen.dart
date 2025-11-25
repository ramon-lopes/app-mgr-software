import 'package:app_mgr_software/models/produto.dart';
import 'package:app_mgr_software/models/user_role.dart';
import 'package:app_mgr_software/providers/produto_provider.dart';
import 'package:app_mgr_software/screens/relatorios/curva_abc_screen.dart';
import 'package:app_mgr_software/screens/relatorios/posicao_estoque_screen.dart';
import 'package:app_mgr_software/services/auth_service.dart';
import 'package:app_mgr_software/services/produto_service.dart';
import 'package:app_mgr_software/widgets/produto_list_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  List<Produto> _produtosFiltrados = [];
  bool _relatorioGerado = false;

  bool _isGerandoRelatorio = false;
  String? _erroRelatorio;
  final ProdutoService _produtoService = ProdutoService();

  // (Métodos _selecionarPeriodo, _gerarRelatorio, _formatarData inalterados)
  // ... (código db:266 - _selecionarPeriodo) ...
  Future<void> _selecionarPeriodo(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          _dataInicial != null && _dataFinal != null
              ? DateTimeRange(
                start: _dataInicial!,
                end: _dataFinal!.subtract(const Duration(days: 1)),
              )
              : null,
    );

    if (picked != null) {
      setState(() {
        _dataInicial = picked.start;
        _dataFinal = picked.end.add(const Duration(days: 1));
        _relatorioGerado = false;
        _erroRelatorio = null;
      });
    }
  }

  // ... (código db:266 - _gerarRelatorio) ...
  Future<void> _gerarRelatorio() async {
    if (_dataInicial == null || _dataFinal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um período primeiro.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGerandoRelatorio = true;
      _relatorioGerado = false;
      _erroRelatorio = null;
    });

    try {
      final filtrados = await _produtoService.buscarProdutosPorPeriodo(
        _dataInicial!,
        _dataFinal!,
      );
      setState(() {
        _produtosFiltrados = filtrados;
        _relatorioGerado = true;
      });
    } catch (e) {
      setState(() {
        _erroRelatorio = e.toString().replaceAll('Exception: ', '');
        _relatorioGerado = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGerandoRelatorio = false;
        });
      }
    }
  }

  // ... (código db:266 - _formatarData) ...
  String _formatarData(DateTime? data) {
    if (data == null) return 'N/A';
    if (data == _dataFinal) {
      return DateFormat(
        'dd/MM/yyyy',
      ).format(data.subtract(const Duration(days: 1)));
    }
    return DateFormat('dd/MM/yyyy').format(data);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // --- ADICIONADO (Para verificar permissões) ---
    final authService = context.read<AuthService>();
    // --- FIM DA ADIÇÃO ---

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Relatórios'),
            pinned: true,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildCabecalhoRelatorios(context, theme),
            ),
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.assessment_outlined),
                tooltip: "Outros Relatórios",
                itemBuilder:
                    (context) => [
                      // 1. Posição de Estoque (Visível para todos)
                      _buildPopupMenuItem(
                        context,
                        'Posição de Estoque',
                        Icons.inventory_2_outlined,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChangeNotifierProvider.value(
                                  value: Provider.of<ProdutoProvider>(
                                    context,
                                    listen: false,
                                  ),
                                  child: const PosicaoEstoqueScreen(),
                                ),
                          ),
                        ),
                      ),

                      // --- CORREÇÃO DE PERMISSÃO ---
                      // 2. Curva ABC (Visível apenas para SUPER_USER, ADMIN, FINANCEIRO)
                      if (authService.hasAnyRole([
                        UserRole.SUPER_USER,
                        UserRole.ADMIN,
                        UserRole.FINANCEIRO,
                      ]))
                        _buildPopupMenuItem(
                          context,
                          'Curva ABC',
                          Icons.pie_chart_outline,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => ChangeNotifierProvider.value(
                                    value: Provider.of<ProdutoProvider>(
                                      context,
                                      listen: false,
                                    ),
                                    child: const CurvaAbcScreen(),
                                  ),
                            ),
                          ),
                        ),
                      // --- FIM DA CORREÇÃO ---

                      // 3. Alertas de Estoque Baixo (Visível para todos)
                      _buildPopupMenuItem(
                        context,
                        'Alertas (Estoque Baixo)',
                        Icons.warning_amber_rounded,
                        () => Navigator.pushNamed(context, '/notificacoes'),
                      ),
                    ],
              ),
            ],
          ),

          _buildResultadoRelatorio(context, theme),
        ],
      ),
    );
  }

  // (O resto do seu ficheiro: _buildCabecalhoRelatorios, _buildResultadoRelatorio,
  // e _buildPopupMenuItem permanecem 100% inalterados)

  // ... (código db:266 - _buildCabecalhoRelatorios) ...
  Widget _buildCabecalhoRelatorios(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relatório de Novos Produtos',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecione um período para ver os produtos cadastrados.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.onPrimary,
                    side: BorderSide(
                      color: theme.colorScheme.onPrimary.withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _dataInicial == null
                        ? 'Selecionar Período'
                        : '${_formatarData(_dataInicial)} - ${_formatarData(_dataFinal)}',
                  ),
                  onPressed: () => _selecionarPeriodo(context),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onPrimary,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 20,
                  ),
                ),
                onPressed: _isGerandoRelatorio ? null : _gerarRelatorio,
                child:
                    _isGerandoRelatorio
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text(
                          'Gerar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ... (código db:266 - _buildResultadoRelatorio) ...
  Widget _buildResultadoRelatorio(BuildContext context, ThemeData theme) {
    if (_isGerandoRelatorio) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_erroRelatorio != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Center(
            child: Text(
              'Erro ao gerar relatório: $_erroRelatorio',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
          ),
        ),
      );
    }
    if (!_relatorioGerado) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Center(
            child: Text(
              'Selecione um período e clique em "Gerar".',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }
    if (_produtosFiltrados.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.2,
          ),
          child: Center(
            child: Text(
              'Nenhum produto cadastrado neste período.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final produto = _produtosFiltrados[index];
        return ProdutoListCard(
          produto: produto,
          onTap: () {
            // (Opcional)
          },
        );
      }, childCount: _produtosFiltrados.length),
    );
  }

  // ... (código db:266 - _buildPopupMenuItem) ...
  PopupMenuItem _buildPopupMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).textTheme.bodyMedium?.color),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }
}
