import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/produto_provider.dart';
import '../../providers/categoria_provider.dart'; // Necessário para a navegação

import '../estoque/entrada_produto_screen.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  // --- LÓGICA DE ESTADO REMOVIDA ---
  // O Provider agora gere o 'future' e os dados
  // late Future<List<Produto>> _futureAlertas;
  // late final ProdutoService _produtoService;
  // --- FIM DA REMOÇÃO ---

  @override
  void initState() {
    super.initState();
    // --- LÓGICA ATUALIZADA ---
    // Apenas chama o Provider para buscar os dados.
    // O Consumer no 'build' vai ouvir as mudanças.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdutoProvider>(
        context,
        listen: false,
      ).buscarProdutosEstoqueBaixo();
    });
    // --- FIM DA ATUALIZAÇÃO ---
  }

  Future<void> _recarregarAlertas() async {
    // --- LÓGICA ATUALIZADA ---
    // Chama o Provider
    await Provider.of<ProdutoProvider>(
      context,
      listen: false,
    ).buscarProdutosEstoqueBaixo();
    // --- FIM DA ATUALIZAÇÃO ---
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas de Estoque')),
      // --- LÓGICA ATUALIZADA (Usa Consumer) ---
      body: Consumer<ProdutoProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: _recarregarAlertas,
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

  // Widget de conteúdo (separado para mais clareza)
  Widget _buildContent(BuildContext context, ProdutoProvider provider) {
    // 1. Estado de Carregamento
    // (Usa o getter 'isLoadingEstoqueBaixo' do provider)
    if (provider.isLoadingEstoqueBaixo) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Estado de Erro
    // (Usa o erro principal do provider, se houver)
    if (provider.hasError) {
      return Center(child: Text('Erro: ${provider.errorMessage}'));
    }

    // 3. Estado Vazio (Sucesso, mas lista vazia)
    // (Usa a lista 'produtosEstoqueBaixo' do provider)
    if (provider.produtosEstoqueBaixo.isEmpty) {
      return ListView(
        // Adicionado para permitir o RefreshIndicator
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.3,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tudo certo!\nNenhum produto com estoque baixo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 4. Estado de Sucesso (com dados)
    // (Usa a lista 'produtosEstoqueBaixo' do provider)
    final produtosComAlerta = provider.produtosEstoqueBaixo;
    produtosComAlerta.sort(
      (a, b) => a.quantidadeEmEstoque.compareTo(b.quantidadeEmEstoque),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: produtosComAlerta.length,
      itemBuilder: (context, index) {
        final produto = produtosComAlerta[index];
        final quantidade = produto.quantidadeEmEstoque;
        final estoqueMinimo = produto.estoqueMinimo;
        final bool estoqueZerado = quantidade == 0;

        final Color statusColor =
            estoqueZerado
                ? Theme.of(context).colorScheme.error
                : Colors.orange.shade800;

        final IconData statusIcon =
            estoqueZerado ? Icons.error_outline : Icons.warning_amber_rounded;

        // O seu widget de Card (está 100% correto)
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: statusColor.withOpacity(0.6), width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            leading: Icon(statusIcon, color: statusColor, size: 40),
            title: Text(
              produto.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Estoque Atual: '),
                  TextSpan(
                    text: '$quantidade',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const TextSpan(text: '  |  Mínimo: '),
                  TextSpan(
                    text: '$estoqueMinimo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),

            // --- NAVEGAÇÃO CORRIGIDA ---
            // (Assim como no consulta_estoque_screen.dart,
            // temos de passar os Providers para a próxima tela)
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(
                            value: Provider.of<ProdutoProvider>(
                              context,
                              listen: false,
                            ),
                          ),
                          ChangeNotifierProvider.value(
                            value: Provider.of<CategoriaProvider>(
                              context,
                              listen: false,
                            ),
                          ),
                        ],
                        child: EntradaProdutoScreen(produtoParaEditar: produto),
                      ),
                ),
              );
              if (result == true && mounted) {
                // Recarrega os alertas E a lista principal de produtos
                _recarregarAlertas();
                Provider.of<ProdutoProvider>(
                  context,
                  listen: false,
                ).buscarProdutosIniciais();
              }
            },
            // --- FIM DA CORREÇÃO ---
          ),
        );
      },
    );
  }
}
