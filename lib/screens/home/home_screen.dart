import 'package:app_mgr_software/models/user_role.dart';
import 'package:app_mgr_software/providers/dashboard_provider.dart';
import 'package:app_mgr_software/providers/produto_provider.dart';
import 'package:app_mgr_software/screens/dashboard/dashboard_screen.dart';
import 'package:app_mgr_software/screens/estoque/consulta_estoque_screen.dart';
import 'package:app_mgr_software/screens/estoque/inventario_screen.dart';
import 'package:app_mgr_software/screens/estoque/movimentar_estoque_screen.dart';
import 'package:app_mgr_software/screens/relatorios/curva_abc_screen.dart';
import 'package:app_mgr_software/screens/relatorios/relatorios_screen.dart';
import 'package:app_mgr_software/services/auth_service.dart';
import 'package:app_mgr_software/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _telas;
  late final List<String> _appBarTitles;
  final Map<int, bool> _dataLoaded = {0: false, 1: false, 2: false, 3: false};

  @override
  void initState() {
    super.initState();
    _telas = const [
      DashboardScreen(),
      ConsultaEstoqueScreen(),
      InventarioScreen(),
      RelatoriosScreen(),
    ];
    _appBarTitles = const ['Dashboard', 'Estoque', 'Inventário', 'Relatórios'];
    _loadInitialData(0);
  }

  void _loadInitialData(int index) {
    if (!_dataLoaded[index]!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        try {
          switch (index) {
            case 0: // Dashboard
              context.read<ProdutoProvider>().buscarProdutosIniciais();
              context.read<DashboardProvider>().fetchSummary();
              break;
            case 1: // Consulta Estoque
            case 2: // Inventário
              context.read<ProdutoProvider>().buscarProdutosIniciais();
              break;
            case 3: // Relatórios
              // (O Ecrã de Relatórios agora busca os seus próprios dados)
              break;
          }
          if (mounted) {
            setState(() {
              _dataLoaded[index] = true;
            });
          }
        } catch (e) {
          debugPrint("Erro ao carregar dados iniciais para tela $index: $e");
        }
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) return; // Ignora o placeholder do FAB
    final actualIndex = index > 2 ? index - 1 : index;
    setState(() {
      _selectedIndex = actualIndex;
    });
    _loadInitialData(actualIndex);
  }

  void _navigateToMovimentarEstoque() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MovimentarEstoqueScreen()),
    ).then((recarregar) {
      if (recarregar == true && mounted) {
        _dataLoaded[_selectedIndex] = false;
        _loadInitialData(_selectedIndex);
      }
    });
  }

  /// Navega para o ecrã da Curva ABC (para o FINANCEIRO)
  void _navigateToCurvaAbc() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider.value(
              // O CurvaAbcScreen (db:221) precisa do ProdutoProvider
              value: Provider.of<ProdutoProvider>(context, listen: false),
              child: const CurvaAbcScreen(),
            ),
      ),
    );
    // Não precisa de recarregar o dashboard depois
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    // --- CORREÇÃO (1/3) ---
    // As variáveis agora são "nullable" (podem ser nulas).
    IconData? fabIcon;
    String? fabTooltip;
    // --- FIM DA CORREÇÃO ---
    VoidCallback? fabOnPressed; // Nulo para esconder o botão

    if (authService.hasAnyRole([
      UserRole.SUPER_USER,
      UserRole.ADMIN,
      UserRole.LOGISTICA,
    ])) {
      fabIcon = Icons.sync_alt;
      fabTooltip = 'Movimentar Estoque';
      fabOnPressed = _navigateToMovimentarEstoque;
    } else if (authService.hasAnyRole([UserRole.FINANCEIRO])) {
      fabIcon = Icons.pie_chart_outline;
      fabTooltip = 'Relatório Curva ABC';
      fabOnPressed = _navigateToCurvaAbc;
    } else {
      fabOnPressed = null;
      // (Agora é seguro deixar fabIcon e fabTooltip como nulos)
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        actions: [
          Consumer<ProdutoProvider>(
            builder: (context, produtoProvider, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none),
                    if (produtoProvider.temNotificacaoEstoqueBaixo)
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notificacoes');
                },
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(index: _selectedIndex, children: _telas),

      floatingActionButton:
          (fabOnPressed == null)
              ? null // Esconde o botão
              : FloatingActionButton(
                onPressed: fabOnPressed,
                // --- CORREÇÃO (2/3) ---
                // Usamos '!' para dizer ao Dart: "Eu sei que isto não é nulo
                // porque 'fabOnPressed' não é nulo".
                tooltip: fabTooltip!,
                elevation: 2.0,
                // --- CORREÇÃO (3/3) ---
                // (Corrigido o aviso de 'sort_child_properties_last')
                child: Icon(fabIcon!),
                // --- FIM DAS CORREÇÕES ---
              ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4.0,
        height: 60.0,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(
              Icons.dashboard_outlined,
              Icons.dashboard,
              'Início',
              0,
            ),
            _buildNavItem(
              Icons.inventory_2_outlined,
              Icons.inventory_2,
              'Estoque',
              1,
            ),
            const SizedBox(width: 40), // Espaço para o FAB
            _buildNavItem(
              Icons.checklist_rtl_outlined,
              Icons.checklist_rtl,
              'Inventário',
              2,
            ),
            _buildNavItem(
              Icons.bar_chart_outlined,
              Icons.bar_chart,
              'Relatórios',
              3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final bool isSelected = _selectedIndex == index;
    final Color color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;
    return IconButton(
      tooltip: label,
      icon: Icon(isSelected ? activeIcon : icon, color: color, size: 24),
      onPressed: () => _onItemTapped(index + (index >= 2 ? 1 : 0)),
    );
  }
}
