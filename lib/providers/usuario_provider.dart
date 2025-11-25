import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../dtos/usuario_request_dto.dart';
import '../services/usuario_service.dart';

// Enum de Status (boa prática, mantido)
enum StatusCarregamento { Ocioso, Carregando, Sucesso, Erro }

class UsuarioProvider with ChangeNotifier {
  // --- ATUALIZAÇÃO ARQUITETURAL ---
  // Não depende mais do AuthService
  // Instancia o UsuarioService diretamente
  final UsuarioService _usuarioService = UsuarioService();
  // --- FIM DA ATUALIZAÇÃO ---

  List<Usuario> _usuarios = [];
  StatusCarregamento _statusLista = StatusCarregamento.Ocioso;
  String _erroLista = '';

  // --- ESTADO DE PAGINAÇÃO (NECESSÁRIO) ---
  // O UsuarioService (db:145) retorna um objeto 'PaginaUsuarios'
  int _currentPage = 0;
  bool _hasNextPage = true;
  int _totalUsuarios = 0;
  // --- FIM DA ADIÇÃO ---

  // Getters
  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _statusLista == StatusCarregamento.Carregando;
  bool get hasError => _statusLista == StatusCarregamento.Erro;
  String get errorMessage => _erroLista;
  bool get hasNextPage => _hasNextPage; // Adicionado
  int get totalUsuarios => _totalUsuarios; // Adicionado

  // Construtor agora é simples
  UsuarioProvider() {
    // Carrega a lista de usuários ao iniciar
    buscarUsuariosIniciais();
  }

  // --- MÉTODOS DE BUSCA (PAGINAÇÃO) ---

  /// Busca a primeira página de usuários.
  Future<void> buscarUsuariosIniciais() async {
    _usuarios = [];
    _currentPage = 0;
    _hasNextPage = true;
    _statusLista = StatusCarregamento.Ocioso;
    _totalUsuarios = 0;
    _erroLista = '';
    notifyListeners();
    // Inicia a busca pela primeira página
    await buscarMaisUsuarios();
  }

  /// Busca a próxima página de usuários.
  Future<void> buscarMaisUsuarios() async {
    // Evita buscas duplicadas ou desnecessárias
    if (isLoading || !_hasNextPage) return;

    _statusLista = StatusCarregamento.Carregando;
    notifyListeners();

    try {
      // --- CORREÇÃO DE LÓGICA ---
      // Chama o serviço com a página atual
      final pagina = await _usuarioService.listarUsuarios(page: _currentPage);
      // --- FIM DA CORREÇÃO ---

      _usuarios.addAll(pagina.usuarios);
      _currentPage++;
      _totalUsuarios = pagina.totalElements;
      // Verifica se ainda há mais páginas para carregar
      _hasNextPage = _usuarios.length < pagina.totalElements;
      _statusLista = StatusCarregamento.Sucesso;
    } catch (e) {
      _erroLista = e.toString().replaceAll('Exception: ', '');
      _statusLista = StatusCarregamento.Erro;
    } finally {
      // Garante que o status não fique "Carregando" se houver erro
      if (_statusLista == StatusCarregamento.Carregando) {
        _statusLista = StatusCarregamento.Ocioso;
      }
      notifyListeners();
    }
  }
  // --- FIM DOS MÉTODOS DE BUSCA ---

  // --- Métodos CRUD (Atualizados para recarregar a lista) ---
  Future<void> criarUsuario(UsuarioRequestDto dto) async {
    try {
      await _usuarioService.criarUsuario(dto);
      await buscarUsuariosIniciais(); // Recarrega a lista do zero
    } catch (e) {
      rethrow; // Propaga o erro para a UI (ex: CrudUsuarioScreen)
    }
  }

  Future<void> inativarUsuario(int id) async {
    try {
      await _usuarioService.inativarUsuario(id);
      // Resposta visual imediata
      _usuarios.removeWhere((u) => u.id == id);
      _totalUsuarios--;
      notifyListeners();
      // NOTA: Para garantir 100% de consistência na paginação,
      // o ideal seria chamar 'buscarUsuariosIniciais()'
      // mas a remoção local é mais rápida.
    } catch (e) {
      rethrow; // Propaga o erro
    }
  }
}
