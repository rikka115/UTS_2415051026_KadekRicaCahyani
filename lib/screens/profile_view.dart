import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/quest_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil petualang berhasil diunggah!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ubah Avatar Petualang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded, color: Colors.amber),
                title: const Text('Ambil Foto Kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Colors.blueAccent),
                title: const Text('Pilih dari Galeri HP'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  title: const Text('Hapus Foto Profil'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final questProvider = context.watch<QuestProvider>();
    final isDark = themeProvider.isDarkMode;

    // Warna teks adaptif untuk mode terang dan gelap
    final textPrimary = isDark ? Colors.white : const Color(0xFF1E1E24);
    final textSecondary = isDark ? Colors.grey.shade400 : const Color(0xFF616161);
    final statBoxColor = isDark ? Colors.white.withAlpha(15) : const Color(0xFFEDEEF3);

    final totalQuests = questProvider.quests.length;
    final completedQuests = questProvider.quests.where((q) => q.isCompleted).length;
    final completionRate = totalQuests > 0
        ? ((completedQuests / totalQuests) * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        // TIDAK PAKAI CONST AGAR BISA MEMAKAI GOOGLEFONTS
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              'PROFIL PETUALANG',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // AVATAR PETUALANG DENGAN BADGE KAMERA
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.amber.shade700,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person_rounded, size: 68, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _showImagePickerOptions,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade800,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            // NAMA PETUALANG DENGAN GOOGLE FONTS
            Text(
              'Kadek Rica Cahyani',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(isDark ? 40 : 50),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade700, width: 0.8),
              ),
              child: Text(
                'Level ${questProvider.currentLevel} • ${questProvider.rankTitle}',
                style: TextStyle(
                  color: isDark ? Colors.amber.shade300 : Colors.amber.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // STATISTIK PETUALANGAN
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: statBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.amber.withAlpha(60) : Colors.amber.shade200),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.amber, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          '${questProvider.totalExp}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        Text('Total EXP', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: statBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.green.withAlpha(60) : Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt_rounded, color: isDark ? Colors.greenAccent : Colors.green.shade700, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          '$completedQuests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.greenAccent : Colors.green.shade800,
                          ),
                        ),
                        Text('Misi Selesai', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: statBoxColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? Colors.blue.withAlpha(60) : Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline_rounded, color: isDark ? Colors.lightBlueAccent : Colors.blue.shade700, size: 22),
                        const SizedBox(height: 4),
                        Text(
                          '$completionRate%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.lightBlueAccent : Colors.blue.shade800,
                          ),
                        ),
                        Text('Rasio Sukses', style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // KARTU IDENTITAS LENGKAP MAHASISWA & USER
            CustomCard(
              borderColor: Colors.amber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.badge_rounded, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Akun & Mahasiswa',
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildProfileRow(Icons.person_pin_circle_rounded, 'Nama Lengkap', 'Kadek Rica Cahyani', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.pin_rounded, 'NIM', '2415051026', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.school_rounded, 'Program Studi', 'Pendidikan Teknik Informatika (S1)', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.account_balance_rounded, 'Fakultas / Kampus', 'FTK - Undiksha', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.calendar_month_rounded, 'Angkatan / Smt', '2024 / Semester 4', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.alternate_email_rounded, 'Email Kampus', 'kadek.rica@student.undiksha.ac.id', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.terminal_rounded, 'Mata Kuliah', 'Pemrograman Aplikasi Mobile (UTS)', textPrimary, textSecondary),
                  const SizedBox(height: 10),
                  _buildProfileRow(Icons.military_tech_rounded, 'Status Petualang', 'Aktif Menjelajah', textPrimary, textSecondary),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // KARTU PENGATURAN TAMPILAN
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.palette_rounded, color: Colors.deepPurpleAccent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Preferensi Aplikasi',
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tema Gelap (Dark Mode)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary),
                    ),
                    subtitle: Text(
                      isDark ? 'Tema Gelap aktif' : 'Tema Terang aktif',
                      style: TextStyle(color: textSecondary),
                    ),
                    secondary: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: Colors.amber,
                    ),
                    value: isDark,
                    onChanged: (val) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'QuestLog TaskMate v2.0 • UTS Mobile 2026',
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value, Color textPrimary, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary, fontSize: 13),
          ),
        ),
        Text(': ', style: TextStyle(color: textSecondary)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
          ),
        ),
      ],
    );
  }
}