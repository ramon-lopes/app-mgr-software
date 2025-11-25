import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart'; // Pacote do seu pubspec
import 'package:permission_handler/permission_handler.dart'; // Pacote do seu pubspec

import '../../dtos/movimento_dto.dart';
import '../../providers/produto_provider.dart';

class BaixaProdutoScreen extends StatefulWidget {
  const BaixaProdutoScreen({super.key});

  @override
  State<BaixaProdutoScreen> createState() => _BaixaProdutoScreenState();
}

class _BaixaProdutoScreenState extends State<BaixaProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacaoController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdutoProvider>(context, listen: false).limparBuscaProduto();
    });
  }

  // --- LÓGICA DO SCANNER (barcode_scan2) ---
  Future<void> _escanearCodigo() async {
    // 1. Pede permissão da câmara
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _showSnackbar('Permissão da câmara negada.', Colors.red);
      return;
    }

    // 2. Tenta escanear
    try {
      final result = await BarcodeScanner.scan();
      if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
        // 3. Coloca o resultado no campo de texto (para o usuário ver)
        _skuController.text = result.rawContent;

        // 4. (AQUI ESTÁ A MUDANÇA!)
        // Chama o método NOVO de busca por CÓDIGO DE BARRAS,
        // em vez de chamar o _buscarProduto() (que busca por SKU).
        await Provider.of<ProdutoProvider>(
          context,
          listen: false,
        ).buscarProdutoPorCodigoDeBarras(result.rawContent);
      }
    } catch (e) {
      _showSnackbar('Erro ao escanear: $e', Colors.red);
    }
  }
  // --- FIM DA LÓGICA DO SCANNER ---

  // Este método (do botão de lupa) continua buscando por SKU.
  Future<void> _buscarProduto() async {
    FocusScope.of(context).unfocus();
    if (_skuController.text.isEmpty) return;
    await Provider.of<ProdutoProvider>(
      context,
      listen: false,
    ).buscarProdutoPorSku(_skuController.text);
  }

  Future<void> _darBaixa(ProdutoProvider provider) async {
    if (!_formKey.currentState!.validate() ||
        provider.produtoSelecionado == null)
      return;

    setState(() => _isSaving = true);

    final quantidade = double.tryParse(_quantidadeController.text) ?? 0.0;
    final produto = provider.produtoSelecionado!;

    // --- CORREÇÃO APLICADA (db:163) ---
    // Usa o enum TipoMovimentoAPI (do movimento_dto.dart)
    final dto = MovimentoDto(
      tipoMovimento: TipoMovimentoAPI.SAIDA,
      quantidade: quantidade,
      observacao: _observacaoController.text,
      versao: produto.versao,
      // precoCusto não é necessário na SAIDA
    );
    // --- FIM DA CORREÇÃO ---

    try {
      await provider.movimentarEstoque(produto.id, dto);
      _showSnackbar('Baixa de estoque realizada com sucesso!', Colors.green);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackbar(e.toString().replaceAll('Exception: ', ''), Colors.red);
      // Se der erro (ex: versão), busca o produto de novo para atualizar
      await provider.buscarProdutoPorSku(produto.sku);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _quantidadeController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Baixa de Estoque')),
      body: Consumer<ProdutoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBuscaProdutoCard(provider),
                if (provider.isBuscandoProduto)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (provider.hasErroBusca)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        provider.erroBusca,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                if (provider.produtoSelecionado != null)
                  _buildFormularioBaixaCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuscaProdutoCard(ProdutoProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _skuController,
          decoration: InputDecoration(
            labelText: 'SKU ou Código de Barras',
            hintText: 'Digite ou escaneie o código',
            // --- BOTÃO DO SCANNER ADICIONADO ---
            prefixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: provider.isBuscandoProduto ? null : _escanearCodigo,
            ),
            // --- FIM DO BOTÃO ---
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: provider.isBuscandoProduto ? null : _buscarProduto,
            ),
          ),
          onSubmitted:
              (_) => provider.isBuscandoProduto ? null : _buscarProduto(),
        ),
      ),
    );
  }

  Widget _buildFormularioBaixaCard(ProdutoProvider provider) {
    final produto = provider.produtoSelecionado!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                produto.nome,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Estoque Atual: ${produto.quantidadeEmEstoque.toString().replaceAll(RegExp(r'\.0$'), '')}',
              ),
              const Divider(height: 24),
              TextFormField(
                controller: _quantidadeController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade para Baixa',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Campo obrigatório';
                  }
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) {
                    return 'Insira uma quantidade válida';
                  }
                  if (val > produto.quantidadeEmEstoque) {
                    return 'Estoque insuficiente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observacaoController,
                decoration: const InputDecoration(
                  labelText: 'Observação (Opcional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _darBaixa(provider),
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
                        : const Icon(Icons.check_circle_outline),
                label: const Text('Confirmar Baixa'),
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

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
