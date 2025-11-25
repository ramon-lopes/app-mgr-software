import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para input formatters e PlatformException
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../dtos/movimento_dto.dart';
import '../../models/produto.dart';
import '../../providers/produto_provider.dart';

class MovimentarEstoqueScreen extends StatefulWidget {
  const MovimentarEstoqueScreen({super.key});

  @override
  State<MovimentarEstoqueScreen> createState() =>
      _MovimentarEstoqueScreenState();
}

class _MovimentarEstoqueScreenState extends State<MovimentarEstoqueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _observacaoController = TextEditingController();

  TipoMovimentoAPI _tipoMovimento = TipoMovimentoAPI.ENTRADA;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProdutoProvider>().limparBuscaProduto();
    });
  }

  Future<void> _scanBarcode() async {
    var status = await Permission.camera.request();
    if (!status.isGranted) {
      _showSnackbar('Permissão da câmara negada.', Colors.red);
      return;
    }

    try {
      var result = await BarcodeScanner.scan();
      if (!mounted ||
          result.type == ResultType.Cancelled ||
          result.rawContent.isEmpty) {
        return;
      }
      _skuController.text = result.rawContent;

      await context.read<ProdutoProvider>().buscarProdutoPorCodigoDeBarras(
        result.rawContent,
      );
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        _showSnackbar('Permissão da câmera negada.');
      } else {
        _showSnackbar('Erro ao iniciar o scanner: $e');
      }
    } catch (e) {
      _showSnackbar('Ocorreu um erro ao ler o código.');
    }
  }

  Future<void> _buscarProduto() async {
    if (_skuController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    await context.read<ProdutoProvider>().buscarProdutoPorSku(
      _skuController.text,
    );
  }

  Future<void> _salvarMovimento() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProdutoProvider>();
    if (provider.produtoSelecionado == null) {
      _showSnackbar('Busque e encontre um produto primeiro.', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);
    final produto = provider.produtoSelecionado!;
    final quantidade = double.parse(_quantidadeController.text);

    final dto = MovimentoDto(
      tipoMovimento: _tipoMovimento,
      quantidade: quantidade,
      observacao: _observacaoController.text,
      versao: produto.versao,
      precoCusto: null,
    );

    try {
      await provider.movimentarEstoque(produto.id, dto);
      _showSnackbar('Movimento de estoque salvo com sucesso!', Colors.green);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showSnackbar(
        'Erro: ${e.toString().replaceAll('Exception: ', '')}',
        Colors.red,
      );
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
      appBar: AppBar(
        title: const Text('Movimentar Estoque'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBuscaProdutoSection(),
              const SizedBox(height: 24),
              Consumer<ProdutoProvider>(
                builder: (context, provider, child) {
                  if (provider.isBuscandoProduto) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (provider.hasErroBusca) {
                    return Center(
                      child: Text(
                        provider.erroBusca,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (provider.produtoSelecionado != null) {
                    return _buildMovimentoSection(provider.produtoSelecionado!);
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Busque um produto para começar.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              _buildBotaoSalvar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBuscaProdutoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextFormField(
              controller: _skuController,
              decoration: InputDecoration(
                labelText: 'Buscar por SKU ou Cód. Barras',
                border: const OutlineInputBorder(),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                  tooltip: 'Ler Código de Barras',
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _buscarProduto,
                  tooltip: 'Buscar Manualmente',
                ),
              ),
              onFieldSubmitted: (_) => _buscarProduto(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimentoSection(Produto produto) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: const Icon(Icons.inventory_2_outlined),
              ),
              title: Text(
                produto.nome,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Estoque Atual: ${produto.quantidadeEmEstoque.toString().replaceAll(RegExp(r'\.0$'), '')}',
              ),
            ),
            const Divider(height: 32),
            DropdownButtonFormField<TipoMovimentoAPI>(
              value: _tipoMovimento,
              decoration: const InputDecoration(
                labelText: 'Tipo de Movimento',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: TipoMovimentoAPI.ENTRADA,
                  child: Text('Entrada no Estoque'),
                ),
                DropdownMenuItem(
                  value: TipoMovimentoAPI.SAIDA,
                  child: Text('Baixa no Estoque'),
                ),
                DropdownMenuItem(
                  value: TipoMovimentoAPI.AJUSTE_POSITIVO,
                  child: Text('Ajuste Positivo'),
                ),
                DropdownMenuItem(
                  value: TipoMovimentoAPI.AJUSTE_NEGATIVO,
                  child: Text('Ajuste Negativo'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _tipoMovimento = val);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantidadeController,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Campo obrigatório.';
                final val = double.tryParse(v);
                if (val == null || val <= 0) {
                  return 'Insira um valor numérico positivo.';
                }
                if ((_tipoMovimento == TipoMovimentoAPI.SAIDA ||
                        _tipoMovimento == TipoMovimentoAPI.AJUSTE_NEGATIVO) &&
                    val > produto.quantidadeEmEstoque) {
                  return 'Quantidade maior que o estoque atual.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacaoController,
              decoration: const InputDecoration(
                labelText: 'Observação (Opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoSalvar() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _salvarMovimento,
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
              : const Icon(Icons.save_outlined),
      label: const Text('Salvar Movimento'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }

  void _showSnackbar(String message, [Color color = Colors.grey]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
