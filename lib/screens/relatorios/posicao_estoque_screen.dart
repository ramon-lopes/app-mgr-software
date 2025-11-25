import 'package:app_mgr_software/models/posicao_estoque.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/produto_provider.dart';

class PosicaoEstoqueScreen extends StatefulWidget {
  const PosicaoEstoqueScreen({super.key});

  @override
  State<PosicaoEstoqueScreen> createState() => _PosicaoEstoqueScreenState();
}

class _PosicaoEstoqueScreenState extends State<PosicaoEstoqueScreen> {
  // --- ESTADO REMOVIDO ---
  // O Provider agora gere o 'future' e os dados
  // late Future<List<Produto>> _futureProdutos; // (Usava o modelo errado)
  // late final ProdutoService _produtoService;
  // --- FIM DA REMOÇÃO ---

  int? _sortColumnIndex;
  bool _isAscending = true;
  String _errorMessage = ''; // Guarda o erro localmente

  @override
  void initState() {
    super.initState();
    // --- LÓGICA ATUALIZADA ---
    // Apenas chama o Provider para buscar os dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recarregarDados();
    });
    // --- FIM DA ATUALIZAÇÃO ---
  }

  Future<void> _recarregarDados() async {
    // --- LÓGICA ATUALIZADA ---
    // Limpa o erro local e chama o provider
    setState(() => _errorMessage = '');
    try {
      await Provider.of<ProdutoProvider>(
        context,
        listen: false,
      ).buscarPosicaoEstoque(); // Chama o novo método
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
    // --- FIM DA ATUALIZAÇÃO ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posição Atual do Estoque')),
      // --- LÓGICA ATUALIZADA (Usa Consumer) ---
      body: Consumer<ProdutoProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _recarregarDados,
            child: _buildContent(
              context,
              provider,
            ), // Chama o widget de conteúdo
          );
        },
      ),
      // --- FIM DA ATUALIZAÇÃO ---
    );
  }

  // O FutureBuilder foi substituído por este método
  Widget _buildContent(BuildContext context, ProdutoProvider provider) {
    // 1. Estado de Carregamento
    if (provider.isLoadingPosicaoEstoque) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de Erro (usa o erro local)
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Erro ao carregar o relatório: $_errorMessage'),
        ),
      );
    }

    // 3. Estado Vazio (Sucesso, mas sem dados)
    if (provider.posicaoEstoque.isEmpty) {
      // Permite o "Puxar para atualizar" mesmo se a lista estiver vazia
      return RefreshIndicator(
        onRefresh: _recarregarDados,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.3,
              ),
              child: const Center(child: Text('Nenhum produto em estoque.')),
            ),
          ],
        ),
      );
    }

    // 4. Estado de Sucesso (com dados)
    // (O seu código de UI original começa aqui)
    final produtos = provider.posicaoEstoque; // Usa a lista correta do provider
    final totalItens = produtos.fold<double>(
      0.0,
      (sum, p) => sum + p.quantidadeEmEstoque,
    );

    // Ordena a lista de produtos (lógica de UI local)
    if (_sortColumnIndex != null) {
      produtos.sort((a, b) {
        late final int result;
        switch (_sortColumnIndex) {
          case 0: // Nome
            result = a.nome.compareTo(b.nome);
            break;
          case 1: // SKU
            result = a.sku.compareTo(b.sku);
            break;
          case 2: // Quantidade
            result = a.quantidadeEmEstoque.compareTo(b.quantidadeEmEstoque);
            break;
          default:
            result = 0;
        }
        return _isAscending ? result : -result;
      });
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical, // Permite scroll vertical
      child: Column(
        children: [
          _buildResumoCard(
            totalItens: totalItens.toInt(),
            totalProdutos: produtos.length,
          ),

          // --- A CORREÇÃO DE OVERFLOW ESTÁ AQUI ---
          // O DataTable precisa de estar dentro de um SingleChildScrollView
          // horizontal para não quebrar em ecrãs pequenos.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildDataTable(produtos),
          ),

          // --- FIM DA CORREÇÃO ---
          const SizedBox(height: 20), // Espaço no fundo
        ],
      ),
    );
  }

  Widget _buildResumoCard({
    required int totalItens,
    required int totalProdutos,
  }) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResumoItem('Produtos Únicos', totalProdutos.toString()),
            _buildResumoItem('Total de Itens', totalItens.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDataTable(List<RelatorioPosicaoEstoque> produtos) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      // O DataTable não precisa de um SizedBox, ele adapta-se
      child: DataTable(
        columnSpacing: 16.0,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _isAscending,
        columns: [
          DataColumn(
            label: const Text(
              'Produto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onSort: (index, asc) => _onSort(index, asc, 0),
          ),
          // --- COLUNA SKU ADICIONADA ---
          DataColumn(
            label: const Text(
              'SKU',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onSort: (index, asc) => _onSort(index, asc, 1),
          ),
          // --- FIM DA ADIÇÃO ---
          DataColumn(
            label: const Text(
              'Qtd.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            numeric: true,
            onSort: (index, asc) => _onSort(index, asc, 2),
          ),
        ],
        rows:
            produtos.map((produto) {
              return DataRow(
                cells: [
                  DataCell(Text(produto.nome)),
                  DataCell(Text(produto.sku)), // Célula do SKU
                  DataCell(
                    Text(produto.quantidadeEmEstoque.toStringAsFixed(0)),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  void _onSort(int columnIndex, bool ascending, int columnInternalIndex) {
    setState(() {
      _sortColumnIndex = columnInternalIndex; // Usa o índice interno (0, 1, 2)
      _isAscending = ascending;
    });
  }
}
