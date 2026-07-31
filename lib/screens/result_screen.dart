import 'dart:io' show Directory, File;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/color_analysis_provider.dart';
import '../models/personal_color_result.dart';
import '../widgets/banner_ad_widget.dart';
import '../core/ad_helper.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final GlobalKey _shareCardKey = GlobalKey();

  // ── RepaintBoundary 캡처 → 이미지 공유 ──
  Future<void> _shareResultCard() async {
    try {
      final boundary = _shareCardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        await Share.shareXFiles(
          [XFile.fromData(bytes, mimeType: 'image/png', name: 'colorfit_result.png')],
          text: '✨ ColorFit으로 퍼스널 컬러 진단했어요! #퍼스널컬러 #ColorFit',
        );
      } else {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/colorfit_result_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: '✨ ColorFit으로 퍼스널 컬러 진단했어요! #퍼스널컬러 #ColorFit',
        );
      }
    } catch (e) {
      debugPrint('[ResultScreen] Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공유 중 오류가 발생했습니다.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // ── 리워드 광고 해금 ──
  void _unlockPremium() {
    AdHelper.instance.showRewardedAd(
      onResult: (rewarded) {
        if (rewarded) {
          ref.read(isRewardUnlockedProvider.notifier).state = true;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🎉 프리미엄 뷰티 팁이 해금되었습니다!'), backgroundColor: Color(0xFF10B981)),
            );
          }
        }
      },
      onError: (msg) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(analysisResultProvider);
    final isUnlocked = ref.watch(isRewardUnlockedProvider);
    final cs = Theme.of(context).colorScheme;

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('분석 결과가 없습니다.', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('돌아가기')),
          ]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            ref.read(selectedImageProvider.notifier).state = null;
            ref.read(analysisResultProvider.notifier).state = null;
            ref.read(isRewardUnlockedProvider.notifier).state = false;
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        title: const Text('컬러 리포트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: '결과 공유',
            onPressed: _shareResultCard,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ══════════════════════════════════════
                    //  공유용 컬러 팔레트 카드 (RepaintBoundary)
                    // ══════════════════════════════════════
                    RepaintBoundary(
                      key: _shareCardKey,
                      child: _ShareableCard(result: result),
                    ),
                    const SizedBox(height: 10),

                    // ── Share Button ──
                    OutlinedButton.icon(
                      onPressed: _shareResultCard,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('인스타·틱톡 공유하기', style: TextStyle(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.primary,
                        side: BorderSide(color: cs.primary.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Best Colors ──
                    _ColorChipSection(
                      title: '✨ Best 컬러 팔레트',
                      subtitle: '얼굴에 생기를 더해주는 찰떡 컬러',
                      colors: result.bestColors,
                    ),
                    const SizedBox(height: 18),

                    // ── Worst Colors ──
                    _ColorChipSection(
                      title: '⚠️ Worst 컬러',
                      subtitle: '피부를 칙칙하게 만드는 컬러',
                      colors: result.worstColors,
                    ),
                    const SizedBox(height: 18),

                    // ── Free Fashion & Makeup Tips ──
                    _TipCard(
                      icon: Icons.checkroom_rounded,
                      iconColor: cs.primary,
                      title: '👗 패션 코디 가이드',
                      items: result.fashionTips,
                    ),
                    const SizedBox(height: 14),
                    _TipCard(
                      icon: Icons.face_retouching_natural_rounded,
                      iconColor: cs.tertiary,
                      title: '💄 메이크업 가이드',
                      items: result.makeupTips,
                    ),
                    const SizedBox(height: 26),

                    // ══════════════════════════════════════
                    //  프리미엄 영역 (리워드 광고 해금)
                    // ══════════════════════════════════════
                    _PremiumSection(
                      isUnlocked: isUnlocked,
                      result: result,
                      onUnlock: _unlockPremium,
                    ),
                    const SizedBox(height: 24),

                    // ── Re-test Button ──
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(selectedImageProvider.notifier).state = null;
                        ref.read(analysisResultProvider.notifier).state = null;
                        ref.read(isRewardUnlockedProvider.notifier).state = false;
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white54),
                      label: const Text('다른 사진으로 다시 진단', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── Sticky Bottom Banner ──
            const Padding(padding: EdgeInsets.only(bottom: 4), child: BannerAdWidget()),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  공유용 팔레트 카드 위젯 (RepaintBoundary 내부)
// ══════════════════════════════════════════════════════════
class _ShareableCard extends StatelessWidget {
  final PersonalColorResult result;
  const _ShareableCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            result.tone.seedColor.withOpacity(0.35),
            const Color(0xFF0B0F1A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: result.tone.seedColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: result.tone.seedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: result.tone.seedColor),
            ),
            child: Text(
              result.subToneName,
              style: TextStyle(color: result.tone.seedColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),

          // Season Type
          Text(
            result.tone.label,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
          ),
          const SizedBox(height: 6),
          Text(
            '"${result.tone.vibe}"',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.75), fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 14),
          Text(
            result.summary,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: Colors.white.withOpacity(0.6), height: 1.45),
          ),
          const SizedBox(height: 20),

          // Color Palette Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: result.bestColors.map((c) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 8)],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Watermark
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.palette_outlined, color: Colors.white.withOpacity(0.3), size: 14),
              const SizedBox(width: 4),
              Text(
                'ColorFit',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  컬러 칩 섹션
// ══════════════════════════════════════════════════════════
class _ColorChipSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;
  const _ColorChipSection({required this.title, required this.subtitle, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151B2C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.45))),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: colors.map((color) {
              final hex = '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
              return Column(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(hex, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              ]);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  팁 카드
// ══════════════════════════════════════════════════════════
class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;
  const _TipCard({required this.icon, required this.iconColor, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF151B2C), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          ]),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('• ', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, height: 1.35))),
                ]),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  프리미엄 제품 추천 영역 (리워드 해금)
// ══════════════════════════════════════════════════════════
class _PremiumSection extends StatelessWidget {
  final bool isUnlocked;
  final PersonalColorResult result;
  final VoidCallback onUnlock;
  const _PremiumSection({required this.isUnlocked, required this.result, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151B2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF10B981).withOpacity(0.6) : cs.primary.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isUnlocked ? const Color(0xFF10B981).withOpacity(0.1) : cs.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(children: [
              Icon(
                isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                color: isUnlocked ? const Color(0xFF34D399) : cs.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    isUnlocked ? '제품 추천 해금됨' : '나에게 찰떡인 립·섀도우 제품 추천',
                    style: TextStyle(
                      color: isUnlocked ? const Color(0xFF34D399) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnlocked ? '나에게 딱 맞는 제품 목록' : '광고 1회 시청으로 무료 확인',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  ),
                ]),
              ),
            ]),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: isUnlocked ? _buildUnlockedContent(context, result) : _buildLockedContent(context, cs),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedContent(BuildContext context, ColorScheme cs) {
    return Column(children: [
      Text(
        '내 퍼스널 컬러에 가장 잘 어울리는 립스틱·아이섀도우 제품과 컬러 셰이드를 확인하세요.',
        style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 13, height: 1.4),
      ),
      const SizedBox(height: 18),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [cs.primary, cs.tertiary]),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onUnlock,
            borderRadius: BorderRadius.circular(16),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text(
                    '무료 광고 시청 후 전체 해금',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildUnlockedContent(BuildContext context, PersonalColorResult result) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Lip Recommendations
      const Text('💋 추천 립스틱', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 10),
      ...result.lipRecommendations.map((p) => _ProductTile(product: p)),
      const Divider(color: Colors.white10, height: 28),
      // Shadow Recommendations
      const Text('👁️ 추천 아이섀도우', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 10),
      ...result.shadowRecommendations.map((p) => _ProductTile(product: p)),
    ]);
  }
}

class _ProductTile extends StatelessWidget {
  final ProductRecommendation product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: product.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            boxShadow: [BoxShadow(color: product.color.withOpacity(0.3), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${product.brand} · ${product.product}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              product.shade,
              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
            ),
          ]),
        ),
      ]),
    );
  }
}
