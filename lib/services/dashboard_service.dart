import 'dart:convert';
import 'package:app_mgr_software/models/dashboard.dart';
import 'package:app_mgr_software/services/api_service.dart';
import 'package:http/http.dart' as http;

/*
 * Este é o Serviço (Service) que fala com o endpoint /api/dashboard
 * usando o ApiService centralizado.
 */
class DashboardService {
  final ApiService _api = ApiService();
  final String _endpoint = 'dashboard';

  // Função auxiliar para tratar erros (padrão)
  Exception _handleError(http.Response response) {
    try {
      final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
      final errorMessage =
          errorBody['message'] ??
          errorBody['error'] ??
          'Ocorreu um erro desconhecido.';
      return Exception(errorMessage);
    } catch (e) {
      return Exception(
        'Falha ao comunicar com o servidor. Código: ${response.statusCode}',
      );
    }
  }

  /// Busca o resumo de dados do dashboard
  Future<DashboardSummary> fetchSummary() async {
    try {
      // Chama o endpoint da API: GET /api/dashboard/summary
      final response = await _api.get('$_endpoint/summary');

      if (response.statusCode == 200) {
        return DashboardSummary.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      rethrow;
    }
  }
}
