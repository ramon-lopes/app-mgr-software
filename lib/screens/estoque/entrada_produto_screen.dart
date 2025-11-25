import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dtos/produto_request_dto.dart';
import '../../models/produto.dart';
import '../../providers/categoria_provider.dart';
import '../../providers/produto_provider.dart';

/// Esta tela é responsável por CADASTRAR um novo produto no catálogo
/// ou EDITAR os dados de um produto existente.
class EntradaProdutoScreen extends StatefulWidget {
  final Produto? produtoParaEditar;
  const EntradaProdutoScreen({super.key, this.produtoParaEditar});

  @override
  State<EntradaProdutoScreen> createState() => _EntradaProdutoScreenState();
}

class _EntradaProdutoScreenState extends State<EntradaProdutoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _skuController;
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _codigoBarrasController;
  late TextEditingController _estoqueMinimoController;

  int? _categoriaSelecionadaId;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // O 'listen: false' é importante no initState
      context.read<CategoriaProvider>().buscarCategorias();
    });

    _skuController = TextEditingController();
    _nomeController = TextEditingController();
    _descricaoController = TextEditingController();
    _codigoBarrasController = TextEditingController();
    _estoqueMinimoController = TextEditingController();

    if (widget.produtoParaEditar != null) {
      _isEditing = true;
      _preencherFormulario(widget.produtoParaEditar!);
    }
  }

  void _preencherFormulario(Produto produto) {
    _skuController.text = produto.sku;
    _nomeController.text = produto.nome;
    _descricaoController.text = produto.descricao ?? '';
    _codigoBarrasController.text = produto.codigoDeBarras ?? '';
    _estoqueMinimoController.text = produto.estoqueMinimo.toString();
    _categoriaSelecionadaId = produto.categoria?.id;
  }

  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final dto = ProdutoRequestDto(
      sku: _skuController.text, // O SKU é lido (mesmo se desativado)
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      codigoDeBarras: _codigoBarrasController.text,
      estoqueMinimo: double.tryParse(_estoqueMinimoController.text) ?? 0.0,
      idCategoria: _categoriaSelecionadaId!,
    );

    try {
      final provider = Provider.of<ProdutoProvider>(context, listen: false);
      if (_isEditing) {
        await provider.atualizarProduto(widget.produtoParaEditar!.id, dto);
        _showSuccessSnackbar('Produto atualizado com sucesso!');
      } else {
        await provider.criarProduto(dto);
        _showSuccessSnackbar('Produto cadastrado com sucesso!');
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
    _codigoBarrasController.dispose();
    _estoqueMinimoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionCard('Informações Principais', [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto',
                  ),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // --- CORREÇÃO (Bug 1 e Bug 2) ---
                TextFormField(
                  controller: _skuController,
                  enabled: !_isEditing,
                  // 1. 'const' removido porque '_isEditing' é uma variável
                  decoration: InputDecoration(
                    // 2. 'filled' movido para DENTRO do InputDecoration
                    filled: _isEditing,
                    labelText: 'SKU (Código Interno)',
                    hintText:
                        _isEditing
                            ? 'Não pode ser alterado após o cadastro'
                            : 'Ex: CAM-AZ-P',
                  ),
                  validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
                ),

                // --- FIM DA CORREÇÃO ---
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codigoBarrasController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Barras',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  maxLines: 3,
                ),
              ]),
              _buildSectionCard('Estoque e Organização', [
                TextFormField(
                  controller: _estoqueMinimoController,
                  decoration: const InputDecoration(
                    labelText: 'Estoque Mínimo',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Consumer<CategoriaProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (provider.hasError) {
                      return Text(
                        'Erro ao carregar categorias: ${provider.errorMessage}',
                      );
                    }
                    return DropdownButtonFormField<int>(
                      value: _categoriaSelecionadaId,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items:
                          provider.categorias
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nome),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (v) => setState(() => _categoriaSelecionadaId = v),
                      validator: (v) => v == null ? 'Obrigatório' : null,
                    );
                  },
                ),
              ]),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _salvarProduto,
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
                label: Text(
                  _isEditing ? 'Salvar Alterações' : 'Cadastrar Produto',
                ),
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

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
