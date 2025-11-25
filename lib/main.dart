import 'package:app_mgr_software/models/produto.dart';
import 'package:app_mgr_software/providers/categoria_provider.dart';
import 'package:app_mgr_software/providers/dashboard_provider.dart';
import 'package:app_mgr_software/providers/produto_provider.dart';
import 'package:app_mgr_software/providers/usuario_provider.dart';
import 'package:app_mgr_software/screens/auth/auth_check_screen.dart';
import 'package:app_mgr_software/screens/auth/login_screen.dart';
import 'package:app_mgr_software/screens/debug/url_entry_screen.dart';
import 'package:app_mgr_software/screens/estoque/baixa_produto_screen.dart';
import 'package:app_mgr_software/screens/estoque/consulta_estoque_screen.dart';
import 'package:app_mgr_software/screens/estoque/entrada_produto_screen.dart';
import 'package:app_mgr_software/screens/estoque/movimentar_estoque_screen.dart';
import 'package:app_mgr_software/screens/home/home_screen.dart';
import 'package:app_mgr_software/screens/menu/ajuda_suporte/ajuda_suporte_screen.dart';
import 'package:app_mgr_software/screens/menu/gerenciar_usuarios/crud_usuario_screen.dart';
import 'package:app_mgr_software/screens/menu/gerenciar_usuarios/gerenciar_usuarios_screen.dart';
import 'package:app_mgr_software/screens/menu/perfil/perfil_screen.dart';
import 'package:app_mgr_software/screens/menu/settings/settings_screen.dart';
import 'package:app_mgr_software/screens/notificacoes/notificacoes_screen.dart';
import 'package:app_mgr_software/services/auth_service.dart';
import 'package:app_mgr_software/theme/app_theme.dart';
import 'package:app_mgr_software/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers (sem dependências)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),

        // Providers (que não dependem de nada,
        // mas são usados por outros ecrãs)
        ChangeNotifierProvider(create: (_) => ProdutoProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MGR Software Gestor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: AuthCheckScreen.routeName, // Rota inicial (normalmente '/')
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AuthCheckScreen.routeName: // Rota '/'
            return MaterialPageRoute(builder: (_) => const AuthCheckScreen());

          case UrlEntryScreen.routeName: // Rota '/setup-url'
            return MaterialPageRoute(builder: (_) => const UrlEntryScreen());

          case LoginScreen.routeName: // Rota '/login'
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case HomeScreen.routeName: // Rota '/home'
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/estoque/entrada':
            return MaterialPageRoute(
              builder:
                  (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: Provider.of<ProdutoProvider>(context),
                      ),
                      ChangeNotifierProvider.value(
                        value: Provider.of<CategoriaProvider>(context),
                      ),
                    ],
                    child: EntradaProdutoScreen(
                      produtoParaEditar: settings.arguments as Produto?,
                    ),
                  ),
            );

          case '/estoque/baixa':
            return MaterialPageRoute(
              builder:
                  (_) => ChangeNotifierProvider.value(
                    value: Provider.of<ProdutoProvider>(context),
                    child: const BaixaProdutoScreen(),
                  ),
            );

          case '/estoque/consulta':
            return MaterialPageRoute(
              builder: (_) => const ConsultaEstoqueScreen(),
            );
          case '/estoque/movimentar':
            return MaterialPageRoute(
              builder: (_) => const MovimentarEstoqueScreen(),
            );

          // (Rotas do Menu)
          case '/gerenciar_usuarios':
            return MaterialPageRoute(
              builder: (_) => const GerenciarUsuariosScreen(),
            );
          case '/crud_usuario':
            return MaterialPageRoute(builder: (_) => const CrudUsuarioScreen());
          case '/perfil':
            return MaterialPageRoute(builder: (_) => const PerfilScreen());
          case '/settings':
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case '/ajuda_suporte':
            return MaterialPageRoute(
              builder: (_) => const AjudaSuporteScreen(),
            );

          // --- ROTA ADICIONADA ---
          // O seu DashboardScreen e RelatoriosScreen
          // agora conseguem encontrar este ecrã.
          case '/notificacoes':
            return MaterialPageRoute(
              builder:
                  (_) => MultiProvider(
                    providers: [
                      // O ecrã de Notificações precisa de ambos os providers:
                      // 1. ProdutoProvider (para ler a lista de alertas)
                      ChangeNotifierProvider.value(
                        value: Provider.of<ProdutoProvider>(context),
                      ),
                      // 2. CategoriaProvider (para poder navegar para a edição do produto)
                      ChangeNotifierProvider.value(
                        value: Provider.of<CategoriaProvider>(context),
                      ),
                    ],
                    child: const NotificacoesScreen(),
                  ),
            );
          // --- FIM DA ADIÇÃO ---

          default:
            // Rota de fallback
            return MaterialPageRoute(
              builder:
                  (_) => Scaffold(
                    body: Center(
                      child: Text('Rota não encontrada: ${settings.name}'),
                    ),
                  ),
            );
        }
      },
    );
  }
}
