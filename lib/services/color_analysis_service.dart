import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/personal_color_result.dart';

class ColorAnalysisService {
  Future<PersonalColorResult> analyze(XFile imageFile) async {
    await Future.delayed(const Duration(milliseconds: 2800));

    final hash = imageFile.name.hashCode.abs() ^ imageFile.path.hashCode.abs();
    final toneIndex = hash % SeasonalTone.values.length;
    final tone = SeasonalTone.values[toneIndex];

    switch (tone) {
      case SeasonalTone.springWarm:
        return PersonalColorResult(
          tone: SeasonalTone.springWarm,
          subToneName: '봄 라이트 브라이트',
          summary: '밝고 따뜻한 옐로 베이스의 화사한 톤입니다. 피부에 생기를 더하는 파스텔 웜 컬러가 가장 잘 어울립니다.',
          bestColors: const [
            Color(0xFFFFB7B2), Color(0xFFFFDAC1),
            Color(0xFFE2F0CB), Color(0xFFFFE5B4),
            Color(0xFFF8C8DC), Color(0xFFFFD166),
          ],
          worstColors: const [
            Color(0xFF1F2937), Color(0xFF4C1D95), Color(0xFF064E3B),
          ],
          fashionTips: [
            '코랄·피치·크림 베이지 계열 톤온톤 코디가 찰떡',
            '리넨·시폰 같은 가벼운 소재가 봄 웜톤의 밝은 에너지와 시너지',
            '올블랙 착장보다 오프화이트+파스텔 포인트가 훨씬 생기있어 보임',
          ],
          makeupTips: [
            '립: 코랄 핑크, 피치 글로우 계열 틴트',
            '블러셔: 웜 피치 또는 살구빛 블러셔',
            '아이: 샴페인 골드 펄, 라이트 브라운 그라데이션',
          ],
          lipRecommendations: const [
            ProductRecommendation(brand: 'MAC', product: 'Lustre Lipstick', shade: 'See Sheer', color: Color(0xFFE8967D)),
            ProductRecommendation(brand: 'YSL', product: 'Volupté Shine', shade: '#15 Corail Spontini', color: Color(0xFFF4845F)),
            ProductRecommendation(brand: 'Romand', product: 'Juicy Lasting Tint', shade: '#09 Litchi Coral', color: Color(0xFFE87F72)),
          ],
          shadowRecommendations: const [
            ProductRecommendation(brand: 'NARS', product: 'Quad Eyeshadow', shade: 'Orgasm', color: Color(0xFFD4A276)),
            ProductRecommendation(brand: 'Etude', product: 'Play Color Eyes', shade: 'Peach Farm', color: Color(0xFFE8B298)),
          ],
        );
      case SeasonalTone.summerCool:
        return PersonalColorResult(
          tone: SeasonalTone.summerCool,
          subToneName: '여름 뮤트 라벤더',
          summary: '은은하고 맑은 블루 베이스의 우아한 쿨톤입니다. 파스텔 쿨 컬러가 피부의 투명감을 극대화합니다.',
          bestColors: const [
            Color(0xFFB5EAD7), Color(0xFFC7CEEA),
            Color(0xFFE8AEB7), Color(0xFFD8BFD8),
            Color(0xFFB8D4E3), Color(0xFFE6C3C3),
          ],
          worstColors: const [
            Color(0xFF8B4513), Color(0xFFFF4500), Color(0xFFDAA520),
          ],
          fashionTips: [
            '라벤더·스카이블루·로즈핑크 파스텔 코디 추천',
            '실버 주얼리 및 화이트골드 포인트가 쿨톤과 완벽 조화',
            '머스타드·카키 등 웜한 탁색은 얼굴을 칙칙해 보이게 할 수 있음',
          ],
          makeupTips: [
            '립: 모브 핑크, 베리 로즈 계열',
            '블러셔: 딸기우유 핑크, 연보라 블러셔',
            '아이: 애쉬 핑크·모브 음영 팔레트',
          ],
          lipRecommendations: const [
            ProductRecommendation(brand: 'Dior', product: 'Addict Lip Glow', shade: '#006 Berry', color: Color(0xFFB76E9A)),
            ProductRecommendation(brand: 'Chanel', product: 'Rouge Allure', shade: '#174 Rouge Angelique', color: Color(0xFFCC7B8E)),
            ProductRecommendation(brand: 'Romand', product: 'Glasting Melting Balm', shade: '#04 Vintage Rose', color: Color(0xFFC47A8A)),
          ],
          shadowRecommendations: const [
            ProductRecommendation(brand: 'Tom Ford', product: 'Eye Quad', shade: 'Seductive Rose', color: Color(0xFFCBA0AA)),
            ProductRecommendation(brand: 'Clio', product: 'Pro Eye Palette', shade: 'Botanic Mauve', color: Color(0xFFB899A4)),
          ],
        );
      case SeasonalTone.autumnWarm:
        return PersonalColorResult(
          tone: SeasonalTone.autumnWarm,
          subToneName: '가을 딥 뮤트',
          summary: '차분하고 깊은 골드 오렌지 베이스의 고급스러운 웜톤입니다. 어스톤과 테라코타 컬러가 최고의 조합입니다.',
          bestColors: const [
            Color(0xFFD4A373), Color(0xFFCCD5AE),
            Color(0xFFE9EDC9), Color(0xFFBC6C25),
            Color(0xFF9C6644), Color(0xFFA68A64),
          ],
          worstColors: const [
            Color(0xFF00FFFF), Color(0xFFFF00FF), Color(0xFFE0E7FF),
          ],
          fashionTips: [
            '베이지·카키·테라코타·번트오렌지 코디가 시그니처',
            '가죽·스웨이드·울 소재와 어스톤 조합이 고급스러움 극대화',
            '네온·형광 컬러와 쿨한 파스텔은 피하는 것이 좋음',
          ],
          makeupTips: [
            '립: MLBB 마른 장미, 칠리 브릭 레드',
            '블러셔: 웜 베이지, 어스 코랄',
            '아이: 딥 브라운 & 카키 멀티 팔레트',
          ],
          lipRecommendations: const [
            ProductRecommendation(brand: 'Charlotte Tilbury', product: 'Matte Revolution', shade: 'Walk of No Shame', color: Color(0xFFAA4A44)),
            ProductRecommendation(brand: 'Bobbi Brown', product: 'Crushed Lip Color', shade: 'Cranberry', color: Color(0xFF9B2D30)),
            ProductRecommendation(brand: 'Hera', product: 'Sensual Powder Matte', shade: '#333 Seoul', color: Color(0xFFA85150)),
          ],
          shadowRecommendations: const [
            ProductRecommendation(brand: 'Urban Decay', product: 'Naked Heat', shade: 'Scorched', color: Color(0xFF8B5E3C)),
            ProductRecommendation(brand: 'Innisfree', product: 'My Eyeshadow', shade: 'Camel Brown', color: Color(0xFFC19A6B)),
          ],
        );
      case SeasonalTone.winterCool:
        return PersonalColorResult(
          tone: SeasonalTone.winterCool,
          subToneName: '겨울 클리어 비비드',
          summary: '명암 대비가 뚜렷하고 선명한 블루 베이스 쿨톤입니다. 강렬하고 비비드한 원색이 인상을 살립니다.',
          bestColors: const [
            Color(0xFF2B2D42), Color(0xFF8D99AE),
            Color(0xFFD90429), Color(0xFFEDF2F4),
            Color(0xFF7209B7), Color(0xFF00B4D8),
          ],
          worstColors: const [
            Color(0xFFDAA520), Color(0xFFD2691E), Color(0xFFF4A460),
          ],
          fashionTips: [
            '블랙·화이트·비비드 체리 레드로 강한 콘트라스트 연출',
            '모노톤 + 한 가지 비비드 포인트 컬러 공식이 최강',
            '베이지·카키 등 중간톤은 인상이 흐려질 수 있으니 주의',
          ],
          makeupTips: [
            '립: 플럼 버건디, 체리 레드, 클래식 레드',
            '블러셔: 라즈베리 핑크 (최소량만)',
            '아이: 실버·블랙·딥 퍼플 스모키',
          ],
          lipRecommendations: const [
            ProductRecommendation(brand: 'MAC', product: 'Retro Matte', shade: 'Ruby Woo', color: Color(0xFFC2272D)),
            ProductRecommendation(brand: 'NARS', product: 'Powermatte Lip Pigment', shade: 'Starwoman', color: Color(0xFF8B1A4A)),
            ProductRecommendation(brand: 'Espoir', product: 'Couture Lip Tint', shade: 'Garnet', color: Color(0xFF9B2335)),
          ],
          shadowRecommendations: const [
            ProductRecommendation(brand: 'Chanel', product: 'Les 4 Ombres', shade: 'Blurry Grey', color: Color(0xFF6C7A89)),
            ProductRecommendation(brand: 'Peripera', product: 'All Take Mood Palette', shade: 'Moonlight Rooftop', color: Color(0xFF9A8C98)),
          ],
        );
    }
  }
}
