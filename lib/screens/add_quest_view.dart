import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quest_provider.dart';
import '../widgets/custom_text_field.dart';

class AddQuestView extends StatefulWidget {
  const AddQuestView({super.key});

  @override
  State<AddQuestView> createState() => _AddQuestViewState();
}

class _AddQuestViewState extends State<AddQuestView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _expController = TextEditingController(text: '25');
  DateTime? _selectedDeadline;
  bool _isLoading = false;

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

  void _setPresetDeadline(int daysOffset, int hour, int minute) {
    final now = DateTime.now();
    final target = now.add(Duration(days: daysOffset));
    setState(() {
      _selectedDeadline = DateTime(target.year, target.month, target.day, hour, minute);
    });
  }

  String _getCountdownText() {
    if (_selectedDeadline == null) return 'Belum ada batas waktu';
    final now = DateTime.now();
    final diff = _selectedDeadline!.difference(now);

    if (diff.isNegative) return 'Waktu telah terlewat!';
    if (diff.inDays > 0) return 'Tenggat dalam ${diff.inDays} hari lagi';
    if (diff.inHours > 0) return 'Tenggat dalam ${diff.inHours} jam lagi';
    return 'Tenggat dalam ${diff.inMinutes} menit lagi!';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await context.read<QuestProvider>().createQuest(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          expReward: int.tryParse(_expController.text.trim()) ?? 10,
          deadline: _selectedDeadline,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quest baru dengan deadline berhasil diposting! ⚔️'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah quest: ${context.read<QuestProvider>().errorMessage}'),
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
            Icon(Icons.add_task_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Posting Quest Baru'),
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
                hint: 'Contoh: Selesaikan Makalah Jaringan Komputer',
                prefixIcon: Icons.auto_stories_rounded,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Judul quest tidak boleh kosong!';
                  }
                  if (val.trim().length < 3) {
                    return 'Judul minimal 3 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Objektif & Rincian Tugas',
                hint: 'Rincian tugas petualangan...',
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

              // KOTAK KALENDER & TENGGAT WAKTU LENGKAP
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber.shade700, width: 1.2),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.amber.withOpacity(0.08),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.alarm_rounded, color: Colors.amber),
                        const SizedBox(width: 8),
                        const Text(
                          'Tenggat Waktu Misi (Deadline):',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        if (_selectedDeadline != null)
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18, color: Colors.redAccent),
                            tooltip: 'Hapus deadline',
                            onPressed: () => setState(() => _selectedDeadline = null),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedDeadline == null ? Icons.calendar_today_rounded : Icons.event_available_rounded,
                            color: _selectedDeadline == null ? Colors.grey : Colors.amber,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedDeadline == null
                                      ? 'Belum dipilih (Tugas Fleksibel)'
                                      : '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year} pukul ${_selectedDeadline!.hour.toString().padLeft(2, '0')}:${_selectedDeadline!.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: _selectedDeadline != null ? Colors.amber.shade300 : null,
                                  ),
                                ),
                                if (_selectedDeadline != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _getCountdownText(),
                                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: _pickDeadline,
                            icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                            label: Text(_selectedDeadline == null ? 'Pilih' : 'Ubah'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // PRESET TOMBOL CEPAT
                    const Text('Pilihan Cepat:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.flash_on_rounded, size: 14, color: Colors.amber),
                            label: const Text('Hari Ini (23:59)', style: TextStyle(fontSize: 11)),
                            onPressed: () => _setPresetDeadline(0, 23, 59),
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            avatar: const Icon(Icons.forward_rounded, size: 14, color: Colors.orange),
                            label: const Text('Besok', style: TextStyle(fontSize: 11)),
                            onPressed: () => _setPresetDeadline(1, 23, 59),
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            avatar: const Icon(Icons.schedule_rounded, size: 14, color: Colors.lightBlue),
                            label: const Text('3 Hari Lagi', style: TextStyle(fontSize: 11)),
                            onPressed: () => _setPresetDeadline(3, 23, 59),
                          ),
                          const SizedBox(width: 6),
                          ActionChip(
                            avatar: const Icon(Icons.date_range_rounded, size: 14, color: Colors.green),
                            label: const Text('1 Minggu', style: TextStyle(fontSize: 11)),
                            onPressed: () => _setPresetDeadline(7, 23, 59),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.amber.shade800,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_task_rounded),
                label: Text(
                  _isLoading ? 'Menyimpan...' : 'Posting Quest ke Board',
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