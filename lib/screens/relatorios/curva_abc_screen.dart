import 'package:app_mgr_software/models/abc_produto.dart';
import 'package:app_mgr_software/providers/produto_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CurvaAbcScreen extends StatefulWidget {
  const CurvaAbcScreen({super.key});

  @override
  State<CurvaAbcScreen> createState() => _CurvaAbcScreenState();
}

class _CurvaAbcScreenState extends State<CurvaAbcScreen> {
  // --- ESTADO REMOVIDO ---
  // O Provider agora gere o 'future' e os dados
  // late Future<List<AbcProduto>> _futureCurvaAbc;
  // late final ProdutoService _produtoService;
  // --- FIM DA REMOÇÃO ---

  int touchedIndex = -1;
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
      ).buscarCurvaAbc();
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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Curva ABC de Produtos')),
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
      ),
    );
  }

  // O FutureBuilder foi substituído por este método
  Widget _buildContent(BuildContext context, ProdutoProvider provider) {
    // 1. Estado de Carregamento
    if (provider.isLoadingCurvaAbc) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de Erro (usa o erro local)
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Erro: $_errorMessage'),
        ),
      );
    }

    // 3. Estado Vazio (Sucesso, mas sem dados)
    if (provider.curvaAbc.isEmpty) {
      return const Center(child: Text('Não há produtos para analisar.'));
    }

    // 4. Estado de Sucesso (com dados)
    // (O seu código de UI original começa aqui, inalterado)
    final produtosAnalisados = provider.curvaAbc; // Usa o provider
    final valorTotalGlobal = produtosAnalisados.fold(
      0.0,
      (sum, p) => sum + p.valorTotalItem,
    );
    final produtosA = produtosAnalisados.where((p) => p.classe == 'A').toList();
    final produtosB = produtosAnalisados.where((p) => p.classe == 'B').toList();
    final produtosC = produtosAnalisados.where((p) => p.classe == 'C').toList();

    final double valorA = produtosA.fold(
      0.0,
      (sum, p) => sum + p.valorTotalItem,
    );
    final double valorB = produtosB.fold(
      0.0,
      (sum, p) => sum + p.valorTotalItem,
    );
    final double valorC = produtosC.fold(
      0.0,
      (sum, p) => sum + p.valorTotalItem,
    );

    return Column(
      children: [
        _buildPieChartCard(valorA, valorB, valorC, valorTotalGlobal),
        const TabBar(
          tabs: [
            Tab(text: 'Classe A'),
            Tab(text: 'Classe B'),
            Tab(text: 'Classe C'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildClasseView(produtosA, 'A', valorTotalGlobal),
              _buildClasseView(produtosB, 'B', valorTotalGlobal),
              _buildClasseView(produtosC, 'C', valorTotalGlobal),
            ],
          ),
        ),
      ],
    );
  }

  // --- O resto do seu ficheiro (a sua UI do Gráfico e das Listas) ---
  // --- está 100% correto e permanece inalterado. ---

  Widget _buildPieChartCard(
    double valorA,
    double valorB,
    double valorC,
    double valorTotal,
  ) {
    if (valorTotal == 0) return const SizedBox.shrink();

    final double percentA = (valorA / valorTotal) * 100;
    final double percentB = (valorB / valorTotal) * 100;
    final double percentC = (valorC / valorTotal) * 100;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Composição do Valor do Estoque",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          _buildChartSection(percentA, Colors.blue, 0),
                          _buildChartSection(percentB, Colors.amber, 1),
                          _buildChartSection(percentC, Colors.red, 2),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend(
                        Colors.blue,
                        'Classe A (${percentA.toStringAsFixed(1)}%)',
                      ),
                      const SizedBox(height: 4),
                      _buildLegend(
                        Colors.amber,
                        'Classe B (${percentB.toStringAsFixed(1)}%)',
                      ),
                      const SizedBox(height: 4),
                      _buildLegend(
                        Colors.red,
                        'Classe C (${percentC.toStringAsFixed(1)}%)',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildChartSection(double value, Color color, int index) {
    final isTouched = index == touchedIndex;
    return PieChartSectionData(
      color: color,
      value: value,
      title: '${value.toStringAsFixed(0)}%',
      radius: isTouched ? 60.0 : 50.0,
      titleStyle: TextStyle(
        fontSize: isTouched ? 16.0 : 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _buildClasseView(
    List<AbcProduto> produtos,
    String classe,
    double valorTotalGlobal,
  ) {
    if (produtos.isEmpty) {
      return Center(
        child: Text('Nenhum produto encontrado na Classe $classe.'),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final double valorTotalClasse = produtos.fold(
      0.0,
      (sum, p) => sum + p.valorTotalItem,
    );
    final double percentualClasse =
        valorTotalGlobal > 0
            ? (valorTotalClasse / valorTotalGlobal) * 100
            : 0.0;

    return Column(
      children: [
        _buildSummaryCard(
          classe: classe,
          totalProdutos: produtos.length,
          valorTotal: valorTotalClasse,
          percentual: percentualClasse,
          currencyFormat: currencyFormat,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final item = produtos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      item.classe,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(item.nomeProduto),
                  subtitle: Text(
                    'Valor em Estoque: ${currencyFormat.format(item.valorTotalItem)}',
                  ),
                  trailing: Text(
                    '${item.percentualAcumulado.toStringAsFixed(1)}% Acum.',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String classe,
    required int totalProdutos,
    required double valorTotal,
    required double percentual,
    required NumberFormat currencyFormat,
  }) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Resumo da Classe $classe',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResumoItem('Produtos', totalProdutos.toString()),
                _buildResumoItem('Valor', currencyFormat.format(valorTotal)),
                _buildResumoItem(
                  '% do Total',
                  '${percentual.toStringAsFixed(1)}%',
                ),
              ],
            ),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
