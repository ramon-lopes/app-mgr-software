import 'package:app_mgr_software/providers/produto_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EstoqueBaixoScreen extends StatefulWidget {
  const EstoqueBaixoScreen({super.key});

  @override
  State<EstoqueBaixoScreen> createState() => _EstoqueBaixoScreenState();
}

class _EstoqueBaixoScreenState extends State<EstoqueBaixoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdutoProvider>(
        context,
        listen: false,
      ).buscarProdutosEstoqueBaixo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos com Estoque Baixo')),
      body: Consumer<ProdutoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingEstoqueBaixo) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.produtosEstoqueBaixo.isEmpty) {
            return const Center(
              child: Text('Nenhum produto com alerta de estoque.'),
            );
          }
          return ListView.builder(
            itemCount: provider.produtosEstoqueBaixo.length,
            itemBuilder: (context, index) {
              final produto = provider.produtosEstoqueBaixo[index];
              return ListTile(
                title: Text(produto.nome),
                subtitle: Text('SKU: ${produto.sku}'),
                trailing: Text(
                  'Qtd: ${produto.quantidadeEmEstoque}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
