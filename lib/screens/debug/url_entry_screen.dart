import 'package:app_mgr_software/screens/auth/auth_check_screen.dart';
import 'package:app_mgr_software/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
 * CORRIGIDO: Este ecrã agora é chamado no início (em Debug) 
 * para permitir que o utilizador COLE o URL do ngrok do dia.
 */
class UrlEntryScreen extends StatefulWidget {
  const UrlEntryScreen({Key? key}) : super(key: key);

  // Define a Rota
  static const String routeName = '/setup-url';

  @override
  _UrlEntryScreenState createState() => _UrlEntryScreenState();
}

class _UrlEntryScreenState extends State<UrlEntryScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // CORRIGIDO: Carrega o URL do dia anterior para facilitar a colagem
    _loadPreviousUrl();
  }

  Future<void> _loadPreviousUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('ngrok_url');
    if (url != null) {
      // Remove o /api para facilitar a cópia do ngrok
      _controller.text = url.replaceAll('/api', '');
    }
  }

  Future<void> _saveUrl() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String url = _controller.text.trim(); // Remove espaços

      // Validação simples
      if (!url.startsWith('https://') || !url.contains('ngrok-free.app')) {
        throw Exception('URL inválido. Deve ser https://....ngrok-free.app');
      }

      // O ApiService é quem vai adicionar o /api, não esta tela.
      /*
        if (!url.endsWith('/api')) {
          url = '$url/api';
        }
      */

      // Salva o URL permanentemente
      await ApiService.saveBaseUrl(url);

      // Envia o utilizador de volta para o ecrã de verificação de auth
      Navigator.of(context).pushReplacementNamed(AuthCheckScreen.routeName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Configurar API (Debug)',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Text(
                  "Inicie o 'ngrok http 8080' no seu PC e cole o URL (https://...ngrok-free.app) abaixo:",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'URL do Ngrok (com https://)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um URL';
                    }
                    if (!value.startsWith('https://')) {
                      return 'O URL deve começar com https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _saveUrl,
                    child: const Text('Salvar e Continuar'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
