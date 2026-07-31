import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/personal_color_result.dart';
import '../services/color_analysis_service.dart';
import '../app_theme.dart';

// ── 이미지 선택 상태 (XFile 기반 웹/앱 공통 지원) ──
final selectedImageProvider = StateProvider<XFile?>((ref) => null);

// ── 분석 결과 상태 ──
final analysisResultProvider = StateProvider<PersonalColorResult?>((ref) => null);

// ── 리워드 광고 해금 상태 ──
final isRewardUnlockedProvider = StateProvider<bool>((ref) => false);

// ── 동적 테마 시드 컬러 ──
final themeSeedColorProvider = StateProvider<Color>((ref) => AppTheme.defaultSeedColor);

// ── 분석 서비스 싱글톤 ──
final colorAnalysisServiceProvider = Provider((ref) => ColorAnalysisService());
