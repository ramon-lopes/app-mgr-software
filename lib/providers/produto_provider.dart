import 'package:app_mgr_software/models/posicao_estoque.dart';
import 'package:flutter/material.dart';

import '../dtos/movimento_dto.dart';
import '../dtos/produto_request_dto.dart';
import '../models/produto.dart';
import '../models/abc_produto.dart';

import '../services/produto_service.dart';

enum StatusCarregamento { Ocioso, Carregando, Sucesso, Erro }

class ProdutoProvider with ChangeNotifier {
  final ProdutoService _produtoService = ProdutoService();

  List<Produto> _produtos = [];
  StatusCarregamento _statusLista = StatusCarregamento.Ocioso;
  String _erroLista = '';

  int _currentPage = 0;
  bool _hasNextPage = true;
  int _totalProdutos = 0;

  Produto? _produtoSelecionado;
  StatusCarregamento _statusBusca = StatusCarregamento.Ocioso;
  String _erroBusca = '';

  List<Produto> _produtosEstoqueBaixo = [];
  bool _isLoadingEstoqueBaixo = false;

  List<AbcProduto> _curvaAbc = [];
  bool _isLoadingCurvaAbc = false;

  // --- ESTADO ADICIONADO PARA A POSIÇÃO DE ESTOQUE ---
  List<RelatorioPosicaoEstoque> _posicaoEstoque = [];
  bool _isLoadingPosicaoEstoque = false;
  // --- FIM DA ADIÇÃO ---

  // Getters
  List<Produto> get produtos => _produtos;
  bool get isLoading => _statusLista == StatusCarregamento.Carregando;
  bool get hasError => _statusLista == StatusCarregamento.Erro;
  String get errorMessage => _erroLista;
  bool get hasNextPage => _hasNextPage;
  int get totalProdutos => _totalProdutos;
  Produto? get produtoSelecionado => _produtoSelecionado;
  bool get isBuscandoProduto => _statusBusca == StatusCarregamento.Carregando;
  bool get hasErroBusca => _statusBusca == StatusCarregamento.Erro;
  String get erroBusca => _erroBusca;
  List<Produto> get produtosEstoqueBaixo => _produtosEstoqueBaixo;
  bool get isLoadingEstoqueBaixo => _isLoadingEstoqueBaixo;
  bool get temNotificacaoEstoqueBaixo => _produtos.any(
    (p) => p.estoqueMinimo > 0 && p.quantidadeEmEstoque <= p.estoqueMinimo,
  );
  List<AbcProduto> get curvaAbc => _curvaAbc;
  bool get isLoadingCurvaAbc => _isLoadingCurvaAbc;

  // --- GETTERS ADICIONADOS ---
  List<RelatorioPosicaoEstoque> get posicaoEstoque => _posicaoEstoque;
  bool get isLoadingPosicaoEstoque => _isLoadingPosicaoEstoque;
  // --- FIM DA ADIÇÃO ---

  ProdutoProvider() {
    buscarProdutosIniciais();
  }

  // --- (Métodos de buscarProdutos, CRUD, buscarPorSku, movimentarEstoque, EstoqueBaixo, CurvaAbc inalterados) ---

  // ... (código db:205 - buscarProdutosIniciais) ...
  Future<void> buscarProdutosIniciais() async {
    _produtos = [];
    _currentPage = 0;
    _hasNextPage = true;
    _statusLista = StatusCarregamento.Ocioso;
    _totalProdutos = 0;
    _erroLista = '';
    notifyListeners();
    await buscarMaisProdutos();
  }

  // ... (código db:205 - buscarMaisProdutos) ...
  Future<void> buscarMaisProdutos() async {
    if (isLoading || !_hasNextPage) return;
    _statusLista = StatusCarregamento.Carregando;
    notifyListeners();
    try {
      final pagina = await _produtoService.buscarProdutos(page: _currentPage);
      _produtos.addAll(pagina.produtos);
      _currentPage++;
      _totalProdutos = pagina.totalElements;
      _hasNextPage = _produtos.length < pagina.totalElements;
      _statusLista = StatusCarregamento.Sucesso;
    } catch (e) {
      _erroLista = e.toString().replaceAll('Exception: ', '');
      _statusLista = StatusCarregamento.Erro;
    } finally {
      if (_statusLista == StatusCarregamento.Carregando) {
        _statusLista = StatusCarregamento.Ocioso;
      }
      notifyListeners();
    }
  }

  // ... (código db:205 - CRUD) ...
  Future<void> criarProduto(ProdutoRequestDto dto) async {
    try {
      await _produtoService.criarProduto(dto);
      await buscarProdutosIniciais();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> atualizarProduto(int id, ProdutoRequestDto dto) async {
    try {
      await _produtoService.atualizarProduto(id, dto);
      await buscarProdutosIniciais();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletarProduto(int produtoId) async {
    try {
      await _produtoService.deletarProduto(produtoId);
      _produtos.removeWhere((produto) => produto.id == produtoId);
      _totalProdutos--;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // ... (código db:205 - buscarProdutoPorSku) ...
  Future<void> buscarProdutoPorSku(String sku) async {
    _statusBusca = StatusCarregamento.Carregando;
    _produtoSelecionado = null;
    _erroBusca = '';
    notifyListeners();
    try {
      final produto = await _produtoService.buscarProdutoPorSku(sku);
      _produtoSelecionado = produto;
      if (produto == null) {
        _erroBusca = 'Produto não encontrado com este SKU.';
        _statusBusca = StatusCarregamento.Erro;
      } else {
        _statusBusca = StatusCarregamento.Sucesso;
      }
    } catch (e) {
      _erroLista = e.toString().replaceAll('Exception: ', '');
      _statusBusca = StatusCarregamento.Erro;
    } finally {
      notifyListeners();
    }
  }

  // EM: produto_provider.dart

  // ... (abaixo do método buscarProdutoPorSku)

  /// Busca um produto pelo seu CÓDIGO DE BARRAS.
  Future<void> buscarProdutoPorCodigoDeBarras(String barcode) async {
    _statusBusca = StatusCarregamento.Carregando;
    _produtoSelecionado = null;
    _erroBusca = '';
    notifyListeners();
    try {
      //
      // !!! ATENÇÃO !!!
      // Você DEVE criar este método 'buscarProdutoPorCodigoDeBarras'
      // no seu 'ProdutoService' (e na sua API Spring Boot).
      //
      final produto = await _produtoService.buscarProdutoPorCodigoDeBarras(
        barcode,
      );

      _produtoSelecionado = produto;
      if (produto == null) {
        // A mensagem de erro agora é correta:
        _erroBusca = 'Produto não encontrado com este CÓDIGO DE BARRAS.';
        _statusBusca = StatusCarregamento.Erro;
      } else {
        _statusBusca = StatusCarregamento.Sucesso;
      }
    } catch (e) {
      _erroBusca = e.toString().replaceAll('Exception: ', '');
      _statusBusca = StatusCarregamento.Erro;
    } finally {
      notifyListeners();
    }
  }

  // ... (código db:205 - movimentarEstoque) ...
  Future<void> movimentarEstoque(
    int produtoId,
    MovimentoDto dto, {
    bool recarregarLista = true,
  }) async {
    try {
      await _produtoService.movimentarEstoque(produtoId, dto);
      if (recarregarLista) {
        await buscarProdutosIniciais();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ... (código db:205 - buscarProdutosEstoqueBaixo) ...
  Future<void> buscarProdutosEstoqueBaixo() async {
    _isLoadingEstoqueBaixo = true;
    notifyListeners();
    try {
      _produtosEstoqueBaixo = await _produtoService.buscarProdutosComAlerta();
    } finally {
      _isLoadingEstoqueBaixo = false;
      notifyListeners();
    }
  }

  // ... (código db:205 - limparBuscaProduto) ...
  void limparBuscaProduto() {
    _produtoSelecionado = null;
    _statusBusca = StatusCarregamento.Ocioso;
    _erroBusca = '';
    notifyListeners();
  }

  // ... (código db:205 - buscarCurvaAbc) ...
  Future<void> buscarCurvaAbc() async {
    _isLoadingCurvaAbc = true;
    notifyListeners();
    try {
      _curvaAbc = await _produtoService.buscarDadosCurvaAbc();
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingCurvaAbc = false;
      notifyListeners();
    }
  }

  // --- NOVO MÉTODO ADICIONADO ---
  /// Busca os dados do relatório de Posição de Estoque
  Future<void> buscarPosicaoEstoque() async {
    _isLoadingPosicaoEstoque = true;
    notifyListeners();

    try {
      // O ProdutoService (db:245) já tem este método
      _posicaoEstoque = await _produtoService.buscarTodosParaRelatorio();
    } catch (e) {
      // Propaga o erro (o ecrã de Posição de Estoque vai mostrá-lo)
      rethrow;
    } finally {
      _isLoadingPosicaoEstoque = false;
      notifyListeners();
    }
  }
}
