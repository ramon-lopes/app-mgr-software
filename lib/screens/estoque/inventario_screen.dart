import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para input formatters
import 'package:provider/provider.dart';

import '../../dtos/movimento_dto.dart'; // O DTO de Movimento
import '../../models/produto.dart';
import '../../models/user_role.dart'; // <-- IMPORTAÇÃO ADICIONADA
import '../../providers/produto_provider.dart'; // O Provider
import '../../services/auth_service.dart'; // <-- IMPORTAÇÃO ADICIONADA
// import '../../services/produto_service.dart'; // REMOVIDO

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final Map<int, TextEditingController> _controllers = {};
  bool _isSaving = false;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);

    final provider = Provider.of<ProdutoProvider>(context, listen: false);
    if (provider.produtos.isEmpty && !provider.isLoading) {
      provider.buscarProdutosIniciais();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<ProdutoProvider>(context, listen: false).buscarMaisProdutos();
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _confirmarAjuste() async {
    final produtosProvider = Provider.of<ProdutoProvider>(
      context,
      listen: false,
    );
    final List<Map<String, dynamic>> ajustes = [];

    // (Lógica de _confirmarAjuste inalterada...)
    for (var produto in produtosProvider.produtos) {
      final controller = _controllers[produto.id];
      if (controller != null) {
        final contagemSistema = produto.quantidadeEmEstoque;
        final contagemFisica =
            double.tryParse(controller.text) ?? contagemSistema;

        if (contagemSistema != contagemFisica) {
          ajustes.add({'produto': produto, 'novaQuantidade': contagemFisica});
        }
      }
    }

    if (ajustes.isEmpty) {
      _showSnackbar(
        'Nenhuma alteração de estoque para registrar.',
        isError: false,
      );
      return;
    }

    final bool confirmar =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar Ajuste de Estoque'),
                content: Text(
                  '${ajustes.length} produto(s) serão atualizados. Deseja continuar?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmar) {
      await _salvarAjustes(ajustes, produtosProvider);
    }
  }

  Future<void> _salvarAjustes(
    List<Map<String, dynamic>> ajustes,
    ProdutoProvider produtosProvider,
  ) async {
    setState(() => _isSaving = true);

    try {
      final List<Future> updates = [];
      for (var ajuste in ajustes) {
        final Produto produto = ajuste['produto'];
        final double novaQuantidade = ajuste['novaQuantidade'];
        final double diferenca = novaQuantidade - produto.quantidadeEmEstoque;

        final dto = MovimentoDto(
          tipoMovimento:
              diferenca > 0
                  ? TipoMovimentoAPI.AJUSTE_POSITIVO
                  : TipoMovimentoAPI.AJUSTE_NEGATIVO,
          quantidade: diferenca.abs(),
          observacao: 'Ajuste de inventário via App',
          versao: produto.versao,
          precoCusto: null,
        );

        updates.add(
          produtosProvider.movimentarEstoque(
            produto.id,
            dto,
            recarregarLista: false,
          ),
        );
      }

      await Future.wait(updates);
      _showSnackbar('Estoque ajustado com sucesso!', isError: false);

      if (mounted) {
        produtosProvider.buscarProdutosIniciais();
      }
    } catch (e) {
      _showSnackbar(
        'Erro ao ajustar estoque: ${e.toString().replaceAll('Exception: ', '')}',
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // --- CORREÇÃO (Início) ---
    // Ouve o AuthService E o ProdutoProvider
    return Consumer2<ProdutoProvider, AuthService>(
      builder: (context, provider, authService, child) {
        // Define a permissão
        final bool podeAjustar = authService.hasAnyRole([
          UserRole.SUPER_USER,
          UserRole.ADMIN,
          UserRole.LOGISTICA,
        ]);
        // --- FIM DA CORREÇÃO ---

        return Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Pesquisar por nome ou SKU...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  Expanded(
                    // --- CORREÇÃO ---
                    // O Consumer já não é necessário aqui,
                    // pois já o temos no topo.
                    // --- FIM DA CORREÇÃO ---
                    child: Builder(
                      // Substituído por um Builder simples
                      builder: (context) {
                        // Usa o 'provider' do Consumer2
                        if (provider.isLoading && provider.produtos.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (provider.hasError && provider.produtos.isEmpty) {
                          return Center(
                            child: Text('Erro: ${provider.errorMessage}'),
                          );
                        }
                        if (provider.produtos.isEmpty) {
                          return const Center(
                            child: Text('Nenhum produto para inventariar.'),
                          );
                        }

                        for (var produto in provider.produtos) {
                          if (!_controllers.containsKey(produto.id)) {
                            _controllers[produto.id] = TextEditingController(
                              text: produto.quantidadeEmEstoque.toString(),
                            );
                          }
                        }

                        final produtosFiltrados =
                            provider.produtos.where((p) {
                              final query =
                                  _searchController.text.toLowerCase();
                              return p.nome.toLowerCase().contains(query) ||
                                  p.sku.toLowerCase().contains(query);
                            }).toList();

                        return RefreshIndicator(
                          onRefresh: () => provider.buscarProdutosIniciais(),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                            itemCount:
                                provider.hasNextPage
                                    ? produtosFiltrados.length + 1
                                    : produtosFiltrados.length,
                            itemBuilder: (context, index) {
                              if (index >= produtosFiltrados.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final produto = produtosFiltrados[index];
                              final controller = _controllers[produto.id]!;
                              final quantidadeSistema =
                                  produto.quantidadeEmEstoque;
                              final quantidadeContada =
                                  double.tryParse(controller.text) ??
                                  quantidadeSistema;
                              final divergencia =
                                  quantidadeContada - quantidadeSistema;

                              final bool hasDivergence = divergencia != 0;

                              return Card(
                                color:
                                    hasDivergence ? Colors.amber.shade50 : null,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              produto.nome,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        hasDivergence
                                                            ? Colors.black87
                                                            : theme
                                                                .textTheme
                                                                .titleMedium
                                                                ?.color,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),

                                            Text(
                                              'Sistema: $quantidadeSistema',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        hasDivergence
                                                            ? Colors.black
                                                                .withOpacity(
                                                                  0.7,
                                                                )
                                                            : theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.color,
                                                  ),
                                            ),

                                            if (hasDivergence) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Divergência: ${divergencia > 0 ? "+$divergencia" : divergencia}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      divergencia > 0
                                                          ? Colors
                                                              .green
                                                              .shade700
                                                          : Colors.red.shade700,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          controller: controller,
                                          textAlign: TextAlign.center,
                                          // --- CORREÇÃO DE PERMISSÃO ---
                                          // O campo de texto só é editável
                                          // se o utilizador puder ajustar.
                                          enabled: podeAjustar,
                                          // --- FIM DA CORREÇÃO ---
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d+\.?\d{0,2}'),
                                            ),
                                          ],
                                          onChanged: (value) => setState(() {}),
                                          decoration: const InputDecoration(
                                            labelText: 'Contagem',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
            ),

            // --- CORREÇÃO DE PERMISSÃO ---
            // O botão flutuante SÓ aparece se o utilizador
            // tiver permissão para o usar.
            if (podeAjustar)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: _isSaving ? null : _confirmarAjuste,
                  label:
                      _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Finalizar Inventário'),
                  icon: const Icon(Icons.check_circle_outline),
                ),
              ),
            // --- FIM DA CORREÇÃO ---
          ],
        );
      }, // Fim do builder do Consumer2
    );
  }
}
