import 'package:flutter/material.dart';

/// MemurBank genelinde tüm boşluk, iç/dış kenar boşluğu (padding/margin),
/// köşe yuvarlaklığı (border radius) ve sabit boyutları barındıran tek merkez.
/// Ekran ve widget'larda rastgele EdgeInsets veya SizedBox yazılması yasaktır.
class AppPaddings {
  const AppPaddings._();

  // Sayısal Boşluk Değerleri
  static const double xxs = 4.0;
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Köşe Yuvarlaklık Değerleri (Radius)
  static const double rXs = 6.0;
  static const double rSm = 8.0;
  static const double rMd = 12.0;
  static const double rLg = 16.0;
  static const double rXl = 20.0;
  static const double rXxl = 24.0;
  static const double rFull = 999.0;

  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(rXs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(rSm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(rMd));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(rLg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(rXl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(rXxl));
  static const BorderRadius radiusFull = BorderRadius.all(
    Radius.circular(rFull),
  );
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(rXxl),
  );
  static const BorderRadius heroBottomRadius = BorderRadius.vertical(
    bottom: Radius.circular(rXxl),
  );

  // Genel EdgeInsets Sabitleri
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets allXxs = EdgeInsets.all(xxs);
  static const EdgeInsets allXs = EdgeInsets.all(xs);
  static const EdgeInsets allSm = EdgeInsets.all(sm);
  static const EdgeInsets allMd = EdgeInsets.all(md);
  static const EdgeInsets allLg = EdgeInsets.all(lg);
  static const EdgeInsets allXl = EdgeInsets.all(xl);
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  // Sayfa ve Kart Paddingleri
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(xl);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: xs,
  );
  static const EdgeInsets sectionMargin = EdgeInsets.fromLTRB(lg, md, lg, xs);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(lg, lg, lg, xl);
  static const EdgeInsets pinnedHeaderPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: xs,
  );
  static const EdgeInsets badgePadding = EdgeInsets.symmetric(
    horizontal: sm,
    vertical: xxs,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets buttonPaddingCompact = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(
    xl,
    lg,
    xl,
    xxl,
  );
  static const EdgeInsets listBottomSpacerPadding = EdgeInsets.only(
    bottom: xxxl,
  );

  // Hazır const SizedBox Boşlukları (Dikey)
  static const SizedBox vGapXxs = SizedBox(height: xxs);
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);
  static const SizedBox vGapXxxl = SizedBox(height: xxxl);

  // Hazır const SizedBox Boşlukları (Yatay)
  static const SizedBox hGapXxs = SizedBox(width: xxs);
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: sm);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);

  // İkon ve Bileşen Boyutları
  static const double iconXs = 14.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 28.0;
  static const double iconHero = 44.0;
  static const double avatarSm = 36.0;
  static const double avatarMd = 44.0;
  static const double avatarLg = 56.0;
  static const double logoSplashSize = 104.0;
  static const double splashOrbitInnerSize = 152.0;
  static const double splashOrbitOuterSize = 188.0;
  static const double logoLoginSize = 72.0;
  static const double qrCodeBoxSize = 148.0;
  static const double progressHeight = 8.0;
  static const double chartBarMaxHeight = 88.0;
  static const double chartBarWidth = 28.0;
  static const double pinnedFilterHeight = 64.0;
}
