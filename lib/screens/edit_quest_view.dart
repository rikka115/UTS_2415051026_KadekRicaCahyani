import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest_model.dart';
import '../providers/quest_provider.dart';
import '../widgets/custom_text_field.dart';

class EditQuestView extends StatefulWidget {
  final QuestModel quest;

  const EditQuestView({super.key, required this.quest});

  @override
  State<EditQuestView> createState() => _EditQuestViewState();
}

class _EditQuestViewState extends State<EditQuestView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _expController;
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quest.title);
    _descriptionController = TextEditingController(text: widget.quest.description);
    _expController = TextEditingController(text: widget.quest.expReward.toString());
    _selectedDeadline = widget.quest.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedDeadline != null
            ? TimeOfDay(hour: _selectedDeadline!.hour, minute: _selectedDeadline!.minute)
            : const TimeOfDay(hour: 23, minute: 59),
      );

      setState(() {
        if (pickedTime != null) {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _selectedDeadline = pickedDate;
        }
      });
    }
  }

  Future<void> _updateForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedQuest = widget.quest.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      expReward: int.tryParse(_expController.text.trim()) ?? widget.quest.expReward,
      deadline: _selectedDeadline,
    );

    final success = await context.read<QuestProvider>().editQuest(updatedQuest);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan quest berhasil disimpan! ⚔️'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui: ${context.read<QuestProvider>().errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Edit Quest'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Judul Quest / Misi',
                hint: 'Ubah judul quest...',
                prefixIcon: Icons.auto_stories_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul quest tidak boleh kosong!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Objektif & Rincian Tugas',
                hint: 'Ubah rincian tugas...',
                prefixIcon: Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _expController,
                label: 'Reward EXP (Poin)',
                hint: 'Contoh: 50',
                prefixIcon: Icons.diamond_rounded,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Reward EXP wajib diisi!';
                  }
                  final numVal = int.tryParse(val.trim());
                  if (numVal == null || numVal <= 0) {
                    return 'EXP harus berupa angka positif.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // EDIT DEADLINE INTERAKTIF
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent.shade200),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.withOpacity(0.08),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_rounded, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tenggat Waktu (Deadline):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            _selectedDeadline == null
                                ? 'Belum ditentukan (Fleksibel)'
                                : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year} pukul ${_selectedDeadline!.hour.toString().padLeft(2, '0')}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _pickDeadline,
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(_selectedDeadline == null ? 'Set' : 'Ubah'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _updateForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan Perubahan Quest',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}