import 'package:flutter/material.dart';
import '../models/produto.dart';

/// Um widget que exibe um resumo de um [Produto] em formato de Card.
///
/// ATUALIZADO: O 'onTap' agora é opcional (nullable). Se 'onTap' for nulo,
/// o card não será clicável e o ícone de seta (>) não aparecerá.
class ProdutoListCard extends StatelessWidget {
  // --- CORREÇÃO AQUI ---
  // O onTap agora é opcional (pode ser nulo)
  const ProdutoListCard({super.key, required this.produto, this.onTap});

  final Produto produto;
  final VoidCallback? onTap;
  // --- FIM DA CORREÇÃO ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantidade = produto.quantidadeEmEstoque;
    final estoqueMinimo = produto.estoqueMinimo;

    final Color quantidadeColor;
    if (quantidade <= 0) {
      quantidadeColor = theme.colorScheme.error;
    } else if (quantidade <= estoqueMinimo) {
      quantidadeColor = Colors.orange.shade700;
    } else {
      quantidadeColor = theme.colorScheme.primary;
    }

    // --- CORREÇÃO AQUI ---
    // Verifica se o card é clicável
    final bool isClickable = onTap != null;
    // --- FIM DA CORREÇÃO ---

    return Card(
      child: InkWell(
        // Se 'onTap' for nulo, o InkWell é desativado
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Indicador de quantidade
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: quantidadeColor.withAlpha(25), // 10% de opacidade
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      quantidade.toStringAsFixed(0), // Mostra como inteiro
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: quantidadeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SKU: ${produto.sku}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // --- CORREÇÃO AQUI ---
              // Só mostra a seta (>) se o card for clicável
              if (isClickable)
                const Icon(Icons.chevron_right, color: Colors.grey),
              // --- FIM DA CORREÇÃO ---
            ],
          ),
        ),
      ),
    );
  }
}
