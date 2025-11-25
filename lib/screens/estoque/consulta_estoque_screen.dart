import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/produto.dart';
import '../../models/user_role.dart';
import '../../providers/categoria_provider.dart';
import '../../providers/produto_provider.dart';
import '../../services/auth_service.dart';
import 'entrada_produto_screen.dart';

class ConsultaEstoqueScreen extends StatefulWidget {
  const ConsultaEstoqueScreen({super.key});

  @override
  State<ConsultaEstoqueScreen> createState() => _ConsultaEstoqueScreenState();
}

class _ConsultaEstoqueScreenState extends State<ConsultaEstoqueScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _searchController.addListener(() {
      setState(() {});
    });

    final provider = Provider.of<ProdutoProvider>(context, listen: false);
    if (provider.produtos.isEmpty && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.buscarProdutosIniciais();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProdutoProvider>().buscarMaisProdutos();
    }
  }

  Future<void> _navegarParaEditar(Produto produto) async {
    final bool? recarregar = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(
                  value: Provider.of<ProdutoProvider>(context, listen: false),
                ),
                ChangeNotifierProvider.value(
                  value: Provider.of<CategoriaProvider>(context, listen: false),
                ),
              ],
              child: EntradaProdutoScreen(produtoParaEditar: produto),
            ),
      ),
    );

    if (recarregar == true && mounted) {
      // (O Provider já recarrega, não precisamos fazer nada)
    }
  }

  Future<void> _deletarProduto(
    BuildContext context,
    ProdutoProvider provider,
    Produto produto,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar Inativação'),
            content: Text(
              'Você tem certeza que deseja inativar o produto "${produto.nome}"?\n\nEsta ação é permanente.',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              TextButton(
                child: Text(
                  'Confirmar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );

    if (confirmado != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await provider.deletarProduto(produto.id);

      if (context.mounted) Navigator.of(context).pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Produto "${produto.nome}" inativado com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar Estoque')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por Nome, SKU ou Cód. Barras',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                          },
                        )
                        : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer2<ProdutoProvider, AuthService>(
              builder: (context, produtoProvider, authService, child) {
                final provider = produtoProvider;

                if (provider.isLoading && provider.produtos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.hasError && provider.produtos.isEmpty) {
                  return Center(
                    child: Text('Erro ao carregar: ${provider.errorMessage}'),
                  );
                }

                final filtro = _searchController.text.toLowerCase();
                final produtosFiltrados =
                    provider.produtos.where((produto) {
                      final nome = produto.nome.toLowerCase();
                      final sku = produto.sku.toLowerCase();
                      final codBarras =
                          produto.codigoDeBarras?.toLowerCase() ?? '';

                      return nome.contains(filtro) ||
                          sku.contains(filtro) ||
                          codBarras.contains(filtro);
                    }).toList();

                if (produtosFiltrados.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => provider.buscarProdutosIniciais(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(
                            MediaQuery.of(context).size.height * 0.2,
                          ),
                          child: Center(
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'Nenhum produto cadastrado.'
                                  : 'Nenhum produto encontrado para "$filtro"',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.buscarProdutosIniciais(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        provider.hasNextPage
                            ? produtosFiltrados.length + 1
                            : produtosFiltrados.length,
                    itemBuilder: (ctx, index) {
                      if (index >= produtosFiltrados.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final produto = produtosFiltrados[index];

                      final bool podeEditar = authService.hasAnyRole([
                        UserRole.SUPER_USER,
                        UserRole.ADMIN,
                        UserRole.LOGISTICA,
                      ]);

                      final bool podeDeletar = authService.hasAnyRole([
                        UserRole.SUPER_USER,
                        UserRole.ADMIN,
                        UserRole.LOGISTICA,
                      ]);

                      final bool estoqueEstaZerado =
                          produto.quantidadeEmEstoque == 0.0;
                      final bool podeMostrarBotaoDeletar =
                          podeDeletar && estoqueEstaZerado;

                      Widget? trailingWidget;
                      if (podeMostrarBotaoDeletar) {
                        trailingWidget = IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed:
                              () => _deletarProduto(context, provider, produto),
                          tooltip: 'Inativar Produto (Estoque Zerado)',
                        );
                      } else if (podeEditar) {
                        trailingWidget = Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: Colors.grey[600],
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            produto.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'SKU: ${produto.sku}\nEstoque: ${produto.quantidadeEmEstoque.toString().replaceAll(RegExp(r'\.0$'), '')}',
                          ),
                          isThreeLine: true,
                          onTap:
                              podeEditar
                                  ? () => _navegarParaEditar(produto)
                                  : null,
                          trailing: trailingWidget,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
