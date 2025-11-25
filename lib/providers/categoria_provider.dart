import 'package:app_mgr_software/dtos/categoria_request_dto.dart';
import 'package:app_mgr_software/models/categoria.dart';
import 'package:app_mgr_software/services/categoria_service.dart';
import 'package:flutter/material.dart';

/*
 * ATUALIZADO: Este provider não depende mais do AuthService.
 * Ele chama diretamente o CategoriaService, que usa o ApiService central.
 */
class CategoriaProvider with ChangeNotifier {
  // O Service agora é instanciado diretamente.
  final CategoriaService _categoriaService = CategoriaService();

  List<Categoria> _categorias = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  // O construtor agora é simples e não precisa de argumentos.
  CategoriaProvider() {
    // Carrega as categorias assim que o provider é inicializado
    buscarCategorias();
  }

  /// Limpa o estado de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// (READ) Busca/Recarrega todas as categorias da API
  Future<void> buscarCategorias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categorias = await _categoriaService.buscarCategorias();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- MÉTODOS CRUD ADICIONADOS ---

  /// (CREATE) Cria uma nova categoria e recarrega a lista
  Future<bool> criarCategoria(CategoriaRequestDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _categoriaService.criarCategoria(dto);
      // Sucesso! Recarrega a lista para mostrar o novo item
      await buscarCategorias();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
    // 'finally' é desnecessário aqui, pois buscarCategorias() já gere o 'finally'
  }

  /// (UPDATE) Atualiza uma categoria e recarrega a lista
  Future<bool> atualizarCategoria(int id, CategoriaRequestDto dto) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _categoriaService.atualizarCategoria(id, dto);
      // Sucesso! Recarrega a lista para mostrar a atualização
      await buscarCategorias();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// (DELETE) Deleta uma categoria e recarrega a lista
  Future<bool> deletarCategoria(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _categoriaService.deletarCategoria(id);
      // Sucesso! Remove o item da lista localmente (ou recarrega)
      _categorias.removeWhere((cat) => cat.id == id);
      // Se preferir recarregar da API (mais seguro):
      // await buscarCategorias();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // Retorna 'true' se a operação foi concluída sem erros
    return _errorMessage == null;
  }
}
