import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/ad_helper.dart';
import 'app_theme.dart';
import 'providers/color_analysis_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // AdMob SDK 초기화 (필요한 광고만 웜업)
  await AdHelper.instance.initialize();

  runApp(const ProviderScope(child: ColorFitApp()));
}

class ColorFitApp extends ConsumerWidget {
  const ColorFitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 분석 결과에 따라 테마 시드 컬러가 동적으로 변경됨
    final seedColor = ref.watch(themeSeedColorProvider);

    return AnimatedTheme(
      data: AppTheme.buildTheme(seedColor),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: MaterialApp(
        title: 'ColorFit 퍼스널 컬러',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.buildTheme(seedColor),
        home: const HomeScreen(),
      ),
    );
  }
}
