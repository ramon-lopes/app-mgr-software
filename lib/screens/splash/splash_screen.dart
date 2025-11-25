import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

// Esta tela é a nova porta de entrada do aplicativo.
// Ela verifica o status de login e redireciona o usuário.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarStatusLogin();
  }

  Future<void> _verificarStatusLogin() async {
    // Aguarda um instante para garantir que a UI inicial seja construída
    await Future.delayed(const Duration(milliseconds: 100));

    // CORREÇÃO: Usa o Provider para aceder à instância global do AuthService
    final authService = Provider.of<AuthService>(context, listen: false);

    // CORREÇÃO: Chama o método correto 'tryAutoLogin'
    final estaLogado = await authService.tryAutoLogin();

    if (mounted) {
      if (estaLogado) {
        // Se encontrou um token válido, vai para a tela principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Se não, vai para a tela de login
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostra um indicador de carregamento enquanto a verificação acontece.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
