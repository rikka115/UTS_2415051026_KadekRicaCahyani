import 'package:flutter/foundation.dart';
import '../models/quote_model.dart';
import '../repositories/quote_repository.dart';

enum QuoteState { initial, loading, loaded, error }

class QuoteProvider extends ChangeNotifier {
  final QuoteRepository _repository;

  QuoteProvider({QuoteRepository? repository})
      : _repository = repository ?? QuoteRepository();

  QuoteModel? _quote;
  QuoteState _state = QuoteState.initial;
  String _errorMessage = '';

  QuoteModel? get quote => _quote;
  QuoteState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> fetchDailyQuote() async {
    _state = QuoteState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _quote = await _repository.getDailyQuote();
      _state = QuoteState.loaded;
    } catch (e) {
      _state = QuoteState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }
}