import 'package:app_mgr_software/screens/debug/url_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';
// import 'package:flutter/foundation.dart'; // kDebugMode já não é necessário

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nomeUsuarioController = TextEditingController(
    text: 'Ramon',
  );
  final TextEditingController _senhaController = TextEditingController(
    text: 'senhaForte123',
  );
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _senhaVisivel = false;
  bool _isLoading = false;

  Future<void> _realizarLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    if (!mounted) {
      setState(() => _isLoading = false);
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final navigator = Navigator.of(context);

    try {
      await authService.login(
        _nomeUsuarioController.text,
        _senhaController.text,
      );
      navigator.pushReplacementNamed(HomeScreen.routeName);
    } on Exception catch (e) {
      _showErrorDialog(message: e.toString().replaceFirst('Exception: ', ''));
    } catch (e) {
      _showErrorDialog(message: 'Ocorreu um erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog({String? message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          icon: Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 48,
          ),
          title: Text(
            'Erro de Login',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message ?? 'Ocorreu um erro desconhecido.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _navigateToUrlSetup() {
    Navigator.of(context).pushNamed(UrlEntryScreen.routeName);
  }

  @override
  void dispose() {
    _nomeUsuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // --- CORREÇÃO AQUI ---
          // O 'if (kDebugMode)' foi REMOVIDO.
          // A engrenagem ⚙️ agora vai aparecer SEMPRE (em Debug e Release).
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurar URL da API',
            onPressed: _navigateToUrlSetup,
          ),
          // --- FIM DA CORREÇÃO ---
        ],
      ),
      body: Container(
        // (O resto do seu UI 'body' (db:253) permanece 100% inalterado)
        // ...
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.3),
              theme.scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.4],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Bem-vindo ao Gestor',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faça login para continuar',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nomeUsuarioController,
                          decoration: const InputDecoration(
                            labelText: "Nome de Usuário",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'O campo nome de usuário é obrigatório.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _senhaController,
                          obscureText: !_senhaVisivel,
                          decoration: InputDecoration(
                            labelText: "Senha",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _senhaVisivel
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _senhaVisivel = !_senhaVisivel,
                                  ),
                            ),
                          ),
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? "O campo senha é obrigatório."
                                      : null,
                        ),
                        const SizedBox(height: 32),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _realizarLogin,
                              child: const Text("Entrar"),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
