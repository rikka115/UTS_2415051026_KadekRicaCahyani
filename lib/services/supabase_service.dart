import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _tableName = 'quests';

  /// READ: Mengambil seluruh record quest dari Supabase
  Future<List<Map<String, dynamic>>> getQuests() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('SupabaseService [GET] Exception: $e');
    }
  }

  /// CREATE: Menyimpan record baru
  Future<Map<String, dynamic>> insertQuest(Map<String, dynamic> payload) async {
    try {
      final response = await _client
          .from(_tableName)
          .insert(payload)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('SupabaseService [INSERT] Exception: $e');
    }
  }

  /// UPDATE: Memperbarui record berdasarkan ID (UUID / String)
  Future<Map<String, dynamic>> updateQuest(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _client
          .from(_tableName)
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (e) {
      throw Exception('SupabaseService [UPDATE] Exception: $e');
    }
  }

  /// DELETE: Menghapus record berdasarkan ID
  Future<void> deleteQuest(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('SupabaseService [DELETE] Exception: $e');
    }
  }
}