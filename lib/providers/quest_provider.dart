import 'package:flutter/foundation.dart';
import '../models/quest_model.dart';
import '../repositories/quest_repository.dart';

enum ViewState { initial, loading, loaded, error }
enum SortCriteria { deadline, exp, newest }

class QuestProvider extends ChangeNotifier {
  final QuestRepository _repository;

  QuestProvider({QuestRepository? repository})
      : _repository = repository ?? QuestRepository();

  List<QuestModel> _quests = [];
  ViewState _state = ViewState.initial;
  String _errorMessage = '';
  SortCriteria _currentSort = SortCriteria.deadline;

  List<QuestModel> get quests => _quests;
  ViewState get state => _state;
  String get errorMessage => _errorMessage;
  SortCriteria get currentSort => _currentSort;

  // Ubah kriteria pengurutan
  void setSortCriteria(SortCriteria criteria) {
    _currentSort = criteria;
    notifyListeners();
  }

  // Ambil quest yang telah disortir
  List<QuestModel> getSortedQuests(String filterStatus) {
    List<QuestModel> result = List.from(_quests);

    if (filterStatus == 'Aktif') {
      result = result.where((q) => !q.isCompleted).toList();
    } else if (filterStatus == 'Selesai') {
      result = result.where((q) => q.isCompleted).toList();
    }

    switch (_currentSort) {
      case SortCriteria.deadline:
        result.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case SortCriteria.exp:
        result.sort((a, b) => b.expReward.compareTo(a.expReward));
        break;
      case SortCriteria.newest:
        result.sort((a, b) {
          if (a.createdAt == null || b.createdAt == null) return 0;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
    }
    return result;
  }

  // RPG Level & EXP
  int get totalExp => _quests.where((q) => q.isCompleted).fold(0, (sum, q) => sum + q.expReward);
  int get currentLevel => (totalExp ~/ 100) + 1;
  int get currentLevelExpProgress => totalExp % 100;

  // GETTER rankTitle YANG SEBELUMNYA HILANG
  String get rankTitle {
    if (currentLevel >= 5) return 'Legendary Dragon Slayer';
    if (currentLevel >= 4) return 'Master Paladin';
    if (currentLevel >= 3) return 'Elite Vanguard';
    if (currentLevel >= 2) return 'Apprentice Warrior';
    return 'Novice Adventurer';
  }

  // READ
  Future<void> loadQuests() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _quests = await _repository.fetchQuests();
      _state = ViewState.loaded;
    } catch (e) {
      _state = ViewState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  // CREATE DENGAN PARAMETER DEADLINE
  Future<bool> createQuest({
    required String title,
    required String description,
    required int expReward,
    DateTime? deadline,
  }) async {
    try {
      final newQuest = QuestModel(
        title: title,
        description: description,
        expReward: expReward,
        deadline: deadline,
      );
      final created = await _repository.addQuest(newQuest);
      _quests.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // UPDATE
  Future<bool> editQuest(QuestModel quest) async {
    try {
      final updated = await _repository.updateQuest(quest);
      final index = _quests.indexWhere((q) => q.id == updated.id);
      if (index != -1) {
        _quests[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // TOGGLE
  Future<bool> toggleQuestCompletion(QuestModel quest) async {
    final updated = quest.copyWith(isCompleted: !quest.isCompleted);
    return await editQuest(updated);
  }

  // DELETE
  Future<bool> removeQuest(String id) async {
    try {
      await _repository.deleteQuest(id);
      _quests.removeWhere((q) => q.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // DATA DUMMY DEMO
  Future<void> seedDummyQuests() async {
    final now = DateTime.now();
    final defaultQuests = [
      {
        'title': 'Selesaikan Laporan UTS Mobile',
        'desc': 'Kumpulkan proyek tepat waktu dengan nilai A!',
        'exp': 100,
        'deadline': now.add(const Duration(days: 1)),
      },
      {
        'title': 'Kuasai Provider State Management',
        'desc': 'Gunakan ChangeNotifier & Consumer secara mahir.',
        'exp': 50,
        'deadline': now.add(const Duration(days: 3)),
      },
      {
        'title': 'Minum Ramuan Stamina (Air 2L)',
        'desc': 'Jaga kondisi tubuh dan stamina petualang.',
        'exp': 25,
        'deadline': now.add(const Duration(hours: 5)),
      },
      {
        'title': 'Eksplorasi Database Supabase',
        'desc': 'Integrasi database cloud PostgreSQL.',
        'exp': 75,
        'deadline': now.add(const Duration(days: 7)),
      },
    ];

    for (final item in defaultQuests) {
      await createQuest(
        title: item['title'] as String,
        description: item['desc'] as String,
        expReward: item['exp'] as int,
        deadline: item['deadline'] as DateTime,
      );
    }
  }
}