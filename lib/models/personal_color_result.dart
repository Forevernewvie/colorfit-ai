import 'package:flutter/material.dart';

enum SeasonalTone {
  springWarm('봄 웜톤', '화사하고 생기 넘치는', Color(0xFFFF9A76)),
  summerCool('여름 쿨톤', '청량하고 우아한', Color(0xFF7EB6D8)),
  autumnWarm('가을 웜톤', '깊고 고급스러운', Color(0xFFD4955A)),
  winterCool('겨울 쿨톤', '선명하고 도시적인', Color(0xFFA855F7));

  final String label;
  final String vibe;
  final Color seedColor;
  const SeasonalTone(this.label, this.vibe, this.seedColor);
}

class ProductRecommendation {
  final String brand;
  final String product;
  final String shade;
  final Color color;
  const ProductRecommendation({
    required this.brand,
    required this.product,
    required this.shade,
    required this.color,
  });
}

class PersonalColorResult {
  final SeasonalTone tone;
  final String subToneName;
  final String summary;
  final List<Color> bestColors;
  final List<Color> worstColors;
  final List<String> fashionTips;
  final List<String> makeupTips;
  final List<ProductRecommendation> lipRecommendations;
  final List<ProductRecommendation> shadowRecommendations;

  const PersonalColorResult({
    required this.tone,
    required this.subToneName,
    required this.summary,
    required this.bestColors,
    required this.worstColors,
    required this.fashionTips,
    required this.makeupTips,
    required this.lipRecommendations,
    required this.shadowRecommendations,
  });
}
