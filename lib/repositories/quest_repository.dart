import '../models/quest_model.dart';
import '../services/supabase_service.dart';

class QuestRepository {
  final SupabaseService _supabaseService;

  QuestRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<List<QuestModel>> fetchQuests() async {
    final rawList = await _supabaseService.getQuests();
    return rawList.map((map) => QuestModel.fromJson(map)).toList();
  }

  Future<QuestModel> addQuest(QuestModel quest) async {
    final rawInserted = await _supabaseService.insertQuest(quest.toJson());
    return QuestModel.fromJson(rawInserted);
  }

  Future<QuestModel> updateQuest(QuestModel quest) async {
    if (quest.id == null || quest.id!.isEmpty) {
      throw ArgumentError('ID Quest wajib ada untuk melakukan update.');
    }
    final rawUpdated = await _supabaseService.updateQuest(quest.id!, quest.toJson());
    return QuestModel.fromJson(rawUpdated);
  }

  Future<void> deleteQuest(String id) async {
    await _supabaseService.deleteQuest(id);
  }
}