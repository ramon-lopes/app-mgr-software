import 'package:app_mgr_software/dtos/usuario_request_dto.dart';
import 'package:app_mgr_software/models/user_role.dart';
import 'package:app_mgr_software/providers/usuario_provider.dart';
import 'package:app_mgr_software/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CrudUsuarioScreen extends StatefulWidget {
  const CrudUsuarioScreen({super.key});

  @override
  State<CrudUsuarioScreen> createState() => _CrudUsuarioScreenState();
}

class _CrudUsuarioScreenState extends State<CrudUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  // --- CAMPO ADICIONADO ---
  late TextEditingController
  _nomeUsuarioController; // Para o login (ex: 'joao.silva')
  // --- FIM DA ADIÇÃO ---
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  UserRole? _funcaoSelecionada;
  bool _isSaving = false;

  List<UserRole> _funcoesDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    // --- CAMPO ADICIONADO ---
    _nomeUsuarioController = TextEditingController(); // Inicializa o controller
    // --- FIM DA ADIÇÃO ---
    _emailController = TextEditingController();
    _senhaController = TextEditingController();

    // Define as funções que o utilizador atual pode criar
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.userRole == UserRole.SUPER_USER) {
      // Super User pode criar qualquer tipo, exceto outro Super User por segurança
      _funcoesDisponiveis = [
        UserRole.ADMIN,
        UserRole.FINANCEIRO,
        UserRole.LOGISTICA,
      ];
    } else if (authService.userRole == UserRole.ADMIN) {
      // Admin só pode criar Financeiro e Logística
      _funcoesDisponiveis = [UserRole.FINANCEIRO, UserRole.LOGISTICA];
    }
  }

  Future<void> _salvarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final dto = UsuarioRequestDto(
      nome: _nomeController.text,
      // --- CAMPO ADICIONADO ---
      // Passa o nome de usuário (login) para o DTO
      nomeUsuario: _nomeUsuarioController.text,
      // --- FIM DA ADIÇÃO ---
      email: _emailController.text,
      senha: _senhaController.text,
      funcao: _funcaoSelecionada!,
    );

    try {
      final provider = Provider.of<UsuarioProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      await provider.criarUsuario(dto);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Utilizador criado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    } catch (e) {
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _showErrorSnackbar('Erro: $errorMessage');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nomeUsuarioController.dispose(); // Adicionado ao dispose
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Utilizador')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                        ),
                        validator:
                            (v) => v!.isEmpty ? 'O nome é obrigatório' : null,
                      ),
                      const SizedBox(height: 16),

                      // --- NOVO TEXTFORMFIELD ADICIONADO ---
                      TextFormField(
                        controller: _nomeUsuarioController,
                        decoration: const InputDecoration(
                          labelText: 'Nome de Usuário (Login)',
                        ),
                        validator:
                            (v) =>
                                v!.isEmpty
                                    ? 'O nome de usuário é obrigatório'
                                    : null,
                      ),

                      // --- FIM DA ADIÇÃO ---
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'O email é obrigatório';
                          if (!v.contains('@')) return 'Email inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        decoration: const InputDecoration(
                          labelText: 'Senha Provisória',
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'A senha é obrigatória';
                          if (v.length < 6)
                            return 'A senha deve ter no mínimo 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<UserRole>(
                        value: _funcaoSelecionada,
                        decoration: const InputDecoration(labelText: 'Função'),
                        items:
                            _funcoesDisponiveis.map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(role.name), // Mostra (ex: 'ADMIN')
                              );
                            }).toList(),
                        onChanged:
                            (v) => setState(() => _funcaoSelecionada = v),
                        validator:
                            (v) => v == null ? 'A função é obrigatória' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _salvarUsuario,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save_outlined),
                label: const Text('Salvar Utilizador'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
