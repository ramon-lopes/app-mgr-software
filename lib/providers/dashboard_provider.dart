import 'package:app_mgr_software/models/dashboard.dart';
import 'package:app_mgr_software/services/dashboard_service.dart';
import 'package:flutter/material.dart';

/*
 * O Modelo 'DashboardSummary' foi movido para o seu próprio ficheiro em /models/
 */

/*
 * ATUALIZADO: Este provider não depende mais do AuthService.
 * Ele chama diretamente o DashboardService, que usa o ApiService central.
 */
class DashboardProvider with ChangeNotifier {
  // Instancia o novo serviço
  final DashboardService _dashboardService = DashboardService();

  DashboardSummary? _summary;
  bool _isLoading = false;
  String _errorMessage = '';

  DashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage.isNotEmpty;
  String get errorMessage => _errorMessage;

  // O construtor agora é simples e não precisa do AuthService
  DashboardProvider() {
    // Carrega o resumo assim que o provider é inicializado
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // --- LÓGICA ATUALIZADA ---
      // Chama o novo serviço
      _summary = await _dashboardService.fetchSummary();
      // --- FIM DA ATUALIZAÇÃO ---
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
