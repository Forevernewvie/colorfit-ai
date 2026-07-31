import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/color_analysis_provider.dart';
import '../core/ad_helper.dart';
import 'result_screen.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  int _stepIndex = 0;
  bool _analysisDone = false;

  final _steps = const [
    '피부 톤 스캔 중...',
    '웜톤·쿨톤 밸런스 체크 중...',
    '사계절 톤 매칭 중...',
    '베스트 팔레트 완성!',
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    // 단계별 텍스트 전환
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _stepIndex = i);
    }

    // AI 분석 수행
    final image = ref.read(selectedImageProvider);
    if (image == null) return;

    final service = ref.read(colorAnalysisServiceProvider);
    final result = await service.analyze(image);

    ref.read(analysisResultProvider.notifier).state = result;
    ref.read(themeSeedColorProvider.notifier).state = result.tone.seedColor;

    if (mounted) setState(() => _analysisDone = true);

    // 분석 완료 직후 → 전면 광고(Interstitial) 호출
    // 유저가 결과를 가장 기대하는 순간이므로 이탈률 최소
    AdHelper.instance.showInterstitialAd(
      onComplete: () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ResultScreen()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated Scanner Ring ──
                AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (context, child) {
                    return Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [cs.primary, cs.tertiary, cs.secondary, cs.primary],
                          transform: GradientRotation(_animCtrl.value * 6.2832),
                        ),
                        boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.35), blurRadius: 30, spreadRadius: 3)],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Color(0xFF0B0F1A), shape: BoxShape.circle),
                        child: Icon(
                          _analysisDone ? Icons.check_circle_rounded : Icons.face_retouching_natural_rounded,
                          size: 58,
                          color: _analysisDone ? const Color(0xFF34D399) : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 44),

                // ── Title ──
                Text(
                  _analysisDone ? '분석 완료!' : '컬러 분석 중',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                ),
                const SizedBox(height: 16),

                // ── Step Text ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: Text(
                    _steps[_stepIndex],
                    key: ValueKey<int>(_stepIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Progress Bar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 220,
                    child: LinearProgressIndicator(
                      value: (_stepIndex + 1) / _steps.length,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '잠시만 기다려 주세요',
                  style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.35)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
