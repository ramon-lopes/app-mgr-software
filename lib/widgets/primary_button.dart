import 'package:flutter/material.dart';

/// Um botão principal reutilizável com estilo padronizado para o aplicativo.
///
/// Recebe o [text] a ser exibido e uma função [onPressed] a ser executada
/// quando o botão é pressionado. O callback [onPressed] pode ser nulo para
/// desabilitar o botão.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.text, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Centralize o estilo do seu botão principal aqui.
        // Assim, qualquer alteração afetará todos os botões do app.
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        // Adicione outras customizações de estilo se desejar.
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(12),
        // ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
