import 'package:app_mgr_software/screens/auth/login_screen.dart';
import 'package:app_mgr_software/screens/home/home_screen.dart';
import 'package:app_mgr_software/services/api_service.dart';
import 'package:app_mgr_software/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode

// O UrlEntryScreen JÁ NÃO É importado aqui

/*
 * ATUALIZADO (FLUXO PROFISSIONAL):
 * Este ecrã agora NUNCA mostra o UrlEntryScreen.
 * 1. Tenta carregar o URL (de prod ou debug).
 * 2. Tenta fazer o auto-login.
 * 3. Se algo falhar (URL inválido, token expirado), ele SEMPRE
 * envia o utilizador para o LoginScreen.
 */
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  static const String routeName = '/';

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarUrlEAutenticacao();
    });
  }

  Future<void> _verificarUrlEAutenticacao() async {
    final navigator = Navigator.of(context);

    try {
      // --- 1. VERIFICAÇÃO DO URL (SILENCIOSA) ---
      if (kDebugMode) {
        // Em modo DEBUG, apenas TENTA carregar o URL guardado
        final prefs = await SharedPreferences.getInstance();
        final ngrokUrl = prefs.getString('ngrok_url');

        if (ngrokUrl == null || ngrokUrl.isEmpty) {
          // Se o URL estiver vazio, não fazemos nada. O login VAI falhar
          // (o que é o esperado) e o utilizador vai para o LoginScreen.
          // Não o enviamos para o /setup-url.
        } else {
          // Se tivermos um URL, carregamo-lo no ApiService.
          // O auto-login (abaixo) vai testar se este URL ainda é válido.
          await ApiService.loadBaseUrl();
        }
      } else {
        // Em modo RELEASE (Produção), carregamos o URL fixo
        await ApiService.loadBaseUrl();
      }

      // --- 2. VERIFICAÇÃO DE LOGIN (A SUA LÓGICA ORIGINAL) ---
      final authService = Provider.of<AuthService>(context, listen: false);

      // Tenta o auto-login.
      // Se o URL (do ngrok) estiver errado/antigo, o tryAutoLogin
      // vai falhar (corretamente) e vai para o 'catch'.
      final bool isLogged = await authService.tryAutoLogin();

      if (isLogged) {
        navigator.pushReplacementNamed(HomeScreen.routeName);
      } else {
        // Se o token expirou (ou nunca existiu), vai para o Login
        navigator.pushReplacementNamed(LoginScreen.routeName);
      }
    } catch (e) {
      // Se TUDO falhar (ex: API (Java) desligada, URL do ngrok morto),
      // o tryAutoLogin() vai lançar uma exceção.
      // O comportamento correto é ir para o LoginScreen.
      debugPrint('AuthCheckScreen falhou (isto é normal se o URL mudou): $e');
      navigator.pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
