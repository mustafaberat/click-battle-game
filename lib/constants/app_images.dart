/// Raster comic art (1x / 2.0x / 3.0x variants live under assets/images/).
class AppImages {
  static const _p = 'assets/images';
  static const homeHero = '$_p/home_hero.png';
  static const homeHeroNoText = '$_p/home_hero_notext.png';
  static const titleLogo = '$_p/title_logo.png';
  static const halftoneNavy = '$_p/halftone_bg_navy.png';
  static const halftoneRed = '$_p/halftone_bg_red.png';
  static const halftoneBlue = '$_p/halftone_bg_blue.png';
  static const halftoneDots = '$_p/halftone_dots_overlay.png';
  static const speedLines = '$_p/speed_lines_overlay.png';
  static const lightningDivider = '$_p/lightning_divider.png';
  static const burstBig = '$_p/burst_big.png';
  static const burstPlus1 = '$_p/burst_plus1.png';
  static const sparkStar = '$_p/spark_star.png';
  static const plus1 = '$_p/plus1_text.png';
  static const trophy = '$_p/trophy.png';
  static const trophyRays = '$_p/trophy_rays.png';

  /// Large images worth decoding before first use.
  static const precache = [
    homeHero,
    halftoneNavy,
    halftoneRed,
    halftoneBlue,
    speedLines,
    lightningDivider,
    burstBig,
    sparkStar,
    plus1,
    trophy,
    trophyRays,
  ];
}
