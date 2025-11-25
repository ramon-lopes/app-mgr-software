import 'package:app_mgr_software/models/usuario.dart';
import 'package:app_mgr_software/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GerenciarUsuariosScreen extends StatefulWidget {
  const GerenciarUsuariosScreen({super.key});

  @override
  State<GerenciarUsuariosScreen> createState() =>
      _GerenciarUsuariosScreenState();
}

class _GerenciarUsuariosScreenState extends State<GerenciarUsuariosScreen> {
  // --- ADICIONADO ---
  // Controller para detetar o fim da lista (paginação)
  final ScrollController _scrollController = ScrollController();
  // --- FIM DA ADIÇÃO ---

  @override
  void initState() {
    super.initState();

    // --- ADICIONADO ---
    _scrollController.addListener(_onScroll);
    // --- FIM DA ADIÇÃO ---

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // --- CORRIGIDO ---
      // Chama o método de paginação inicial
      Provider.of<UsuarioProvider>(
        context,
        listen: false,
      ).buscarUsuariosIniciais();
      // --- FIM DA CORREÇÃO ---
    });
  }

  // --- ADICIONADO ---
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Se o utilizador chegou ao fim da lista, busca mais usuários
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UsuarioProvider>().buscarMaisUsuarios();
    }
  }
  // --- FIM DA ADIÇÃO ---

  Future<void> _inativarUsuario(BuildContext context, Usuario usuario) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<UsuarioProvider>(context, listen: false);

    final bool confirmar =
        await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Confirmar Ação'),
                content: Text(
                  'Tem a certeza que deseja INATIVAR o utilizador "${usuario.nome}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => navigator.pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => navigator.pop(true),
                    child: const Text(
                      'Inativar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmar) {
      try {
        await provider.inativarUsuario(usuario.id);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Utilizador inativado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        messenger.showSnackBar(
          SnackBar(
            content: Text('Erro: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerir Utilizadores')),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, child) {
          // Mostra o spinner apenas no carregamento inicial
          if (provider.isLoading && provider.usuarios.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.hasError && provider.usuarios.isEmpty) {
            return Center(child: Text('Erro: ${provider.errorMessage}'));
          }
          if (provider.usuarios.isEmpty) {
            return const Center(child: Text('Nenhum utilizador encontrado.'));
          }

          return RefreshIndicator(
            // --- CORRIGIDO ---
            onRefresh: () => provider.buscarUsuariosIniciais(),
            // --- FIM DA CORREÇÃO ---
            child: ListView.builder(
              // --- ADICIONADO ---
              controller: _scrollController, // Liga o controller ao ListView
              // Adiciona +1 item se houver mais páginas (para o spinner)
              itemCount:
                  provider.hasNextPage
                      ? provider.usuarios.length + 1
                      : provider.usuarios.length,
              // --- FIM DA ADIÇÃO ---
              itemBuilder: (context, index) {
                // --- ADICIONADO (Lógica de Paginação) ---
                // Se for o último item E houver mais páginas, mostra o spinner
                if (index >= provider.usuarios.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                // --- FIM DA ADIÇÃO ---

                final usuario = provider.usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      // Mostra as iniciais (ex: "JP")
                      child: Text(
                        usuario.nome
                            .split(' ')
                            .map((e) => e.isNotEmpty ? e[0] : '')
                            .take(2)
                            .join(),
                      ),
                    ),
                    title: Text(
                      usuario.nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      // Mostra o nome de login (ex: 'admin') e a função
                      'Login: ${usuario.nomeUsuario}\nFunção: ${usuario.funcao.name}',
                    ),
                    isThreeLine: true,
                    trailing:
                        usuario.ativo
                            ? IconButton(
                              icon: const Icon(
                                Icons.person_off_outlined,
                                color: Colors.red,
                              ),
                              tooltip: 'Inativar Utilizador',
                              onPressed:
                                  () => _inativarUsuario(context, usuario),
                            )
                            : const Chip(
                              label: Text('Inativo'),
                              backgroundColor: Colors.grey,
                            ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/crud_usuario').then((_) {
            // Quando o ecrã de CRUD fechar, recarrega a lista
            Provider.of<UsuarioProvider>(
              context,
              listen: false,
            ).buscarUsuariosIniciais();
          });
        },
        tooltip: 'Adicionar Utilizador',
        child: const Icon(Icons.add),
      ),
    );
  }
}
