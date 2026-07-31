import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/color_analysis_provider.dart';
import 'analysis_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );
      if (file != null) {
        ref.read(selectedImageProvider.notifier).state = file;
        ref.read(analysisResultProvider.notifier).state = null;
        ref.read(isRewardUnlockedProvider.notifier).state = false;
      }
    } catch (e) {
      debugPrint('[HomeScreen] Image pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'ColorFit',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Text(
                'Personal Color Diagnosis',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.35),
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 32),

              // ── Main Visual Card ──
              Container(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161D2F),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 계절 톤 미니 팔레트 데코
                    Row(
                      children: [
                        _miniDot(const Color(0xFFFF9A76)),
                        _miniDot(const Color(0xFF7EB6D8)),
                        _miniDot(const Color(0xFFD4955A)),
                        _miniDot(const Color(0xFFA855F7)),
                        const SizedBox(width: 10),
                        Text(
                          'SPRING · SUMMER · AUTUMN · WINTER',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.3),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '나에게 어울리는\n컬러를 찾아보세요',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '사진 한 장으로 퍼스널 컬러를 진단하고,\n나만의 베스트 팔레트와 스타일링 가이드를 받아보세요.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Photo Display / Placeholder ──
              GestureDetector(
                onTap: selectedImage == null ? () => _showPickerSheet(context) : null,
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161D2F),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selectedImage != null ? cs.primary.withOpacity(0.6) : Colors.white.withOpacity(0.06),
                      width: selectedImage != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: selectedImage != null
                      ? Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: kIsWeb
                                ? Image.network(selectedImage.path, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                                : Image.file(File(selectedImage.path), width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                          ),
                          // 오버레이 하단 그라데이션
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 18,
                            child: Text(
                              '사진이 등록되었어요',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => ref.read(selectedImageProvider.notifier).state = null,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                              ),
                            ),
                          ),
                        ])
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 44, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(height: 14),
                            const Text(
                              '사진을 등록해 주세요',
                              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '자연광 아래 정면 셀카가 가장 정확해요',
                              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Camera / Gallery Buttons ──
              Row(children: [
                Expanded(child: _PickerButton(icon: Icons.camera_alt_outlined, label: '카메라', onTap: () => _pickImage(ImageSource.camera))),
                const SizedBox(width: 10),
                Expanded(child: _PickerButton(icon: Icons.image_outlined, label: '앨범', onTap: () => _pickImage(ImageSource.gallery))),
              ]),
              const SizedBox(height: 22),

              // ── Start Analysis CTA ──
              AnimatedOpacity(
                opacity: selectedImage != null ? 1.0 : 0.35,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selectedImage != null ? cs.primary : Colors.white.withOpacity(0.08),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: selectedImage != null
                          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisScreen()))
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 17),
                        child: Center(
                          child: Text(
                            '퍼스널 컬러 진단하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2236),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              _SheetOption(icon: Icons.camera_alt_outlined, label: '카메라로 촬영', onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
              const SizedBox(height: 10),
              _SheetOption(icon: Icons.image_outlined, label: '앨범에서 선택', onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF161D2F),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white60, size: 19),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(children: [
            Icon(icon, color: Colors.white60, size: 22),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
        ),
      ),
    );
  }
}
