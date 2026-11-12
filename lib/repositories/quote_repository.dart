import '../models/quote_model.dart';
import '../services/api_service.dart';

class QuoteRepository {
  final ApiService _apiService;

  QuoteRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<QuoteModel> getDailyQuote() async {
    final rawJson = await _apiService.fetchDailyQuote();
    return QuoteModel.fromJson(rawJson);
  }
}