/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/Prompt-Black.ttf
  String get promptBlack => 'assets/fonts/Prompt-Black.ttf';

  /// File path: assets/fonts/Prompt-BlackItalic.ttf
  String get promptBlackItalic => 'assets/fonts/Prompt-BlackItalic.ttf';

  /// File path: assets/fonts/Prompt-Bold.ttf
  String get promptBold => 'assets/fonts/Prompt-Bold.ttf';

  /// File path: assets/fonts/Prompt-BoldItalic.ttf
  String get promptBoldItalic => 'assets/fonts/Prompt-BoldItalic.ttf';

  /// File path: assets/fonts/Prompt-ExtraBold.ttf
  String get promptExtraBold => 'assets/fonts/Prompt-ExtraBold.ttf';

  /// File path: assets/fonts/Prompt-ExtraBoldItalic.ttf
  String get promptExtraBoldItalic => 'assets/fonts/Prompt-ExtraBoldItalic.ttf';

  /// File path: assets/fonts/Prompt-ExtraLight.ttf
  String get promptExtraLight => 'assets/fonts/Prompt-ExtraLight.ttf';

  /// File path: assets/fonts/Prompt-ExtraLightItalic.ttf
  String get promptExtraLightItalic =>
      'assets/fonts/Prompt-ExtraLightItalic.ttf';

  /// File path: assets/fonts/Prompt-Italic.ttf
  String get promptItalic => 'assets/fonts/Prompt-Italic.ttf';

  /// File path: assets/fonts/Prompt-Light.ttf
  String get promptLight => 'assets/fonts/Prompt-Light.ttf';

  /// File path: assets/fonts/Prompt-LightItalic.ttf
  String get promptLightItalic => 'assets/fonts/Prompt-LightItalic.ttf';

  /// File path: assets/fonts/Prompt-Medium.ttf
  String get promptMedium => 'assets/fonts/Prompt-Medium.ttf';

  /// File path: assets/fonts/Prompt-MediumItalic.ttf
  String get promptMediumItalic => 'assets/fonts/Prompt-MediumItalic.ttf';

  /// File path: assets/fonts/Prompt-Regular.ttf
  String get promptRegular => 'assets/fonts/Prompt-Regular.ttf';

  /// File path: assets/fonts/Prompt-SemiBold.ttf
  String get promptSemiBold => 'assets/fonts/Prompt-SemiBold.ttf';

  /// File path: assets/fonts/Prompt-SemiBoldItalic.ttf
  String get promptSemiBoldItalic => 'assets/fonts/Prompt-SemiBoldItalic.ttf';

  /// File path: assets/fonts/Prompt-Thin.ttf
  String get promptThin => 'assets/fonts/Prompt-Thin.ttf';

  /// File path: assets/fonts/Prompt-ThinItalic.ttf
  String get promptThinItalic => 'assets/fonts/Prompt-ThinItalic.ttf';

  /// List of all assets
  List<String> get values => [
        promptBlack,
        promptBlackItalic,
        promptBold,
        promptBoldItalic,
        promptExtraBold,
        promptExtraBoldItalic,
        promptExtraLight,
        promptExtraLightItalic,
        promptItalic,
        promptLight,
        promptLightItalic,
        promptMedium,
        promptMediumItalic,
        promptRegular,
        promptSemiBold,
        promptSemiBoldItalic,
        promptThin,
        promptThinItalic
      ];
}

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/acute.svg
  String get acute => 'assets/icons/acute.svg';

  /// File path: assets/icons/acute_solid.svg
  String get acuteSolid => 'assets/icons/acute_solid.svg';

  /// File path: assets/icons/calendar-check-solid.svg
  String get calendarCheckSolid => 'assets/icons/calendar-check-solid.svg';

  /// File path: assets/icons/calendar-check.svg
  String get calendarCheck => 'assets/icons/calendar-check.svg';

  /// File path: assets/icons/category.svg
  String get category => 'assets/icons/category.svg';

  /// File path: assets/icons/category_solid.svg
  String get categorySolid => 'assets/icons/category_solid.svg';

  /// File path: assets/icons/settings.svg
  String get settings => 'assets/icons/settings.svg';

  /// File path: assets/icons/settings_solid.svg
  String get settingsSolid => 'assets/icons/settings_solid.svg';

  /// File path: assets/icons/today.svg
  String get today => 'assets/icons/today.svg';

  /// File path: assets/icons/today_solid.svg
  String get todaySolid => 'assets/icons/today_solid.svg';

  /// List of all assets
  List<String> get values => [
        acute,
        acuteSolid,
        calendarCheckSolid,
        calendarCheck,
        category,
        categorySolid,
        settings,
        settingsSolid,
        today,
        todaySolid
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/add.png
  AssetGenImage get add => const AssetGenImage('assets/images/add.png');

  /// File path: assets/images/gemini.png
  AssetGenImage get gemini => const AssetGenImage('assets/images/gemini.png');

  /// File path: assets/images/moolah_lottie.json
  String get moolahLottie => 'assets/images/moolah_lottie.json';

  /// File path: assets/images/wallet_coins_lottie.json
  String get walletCoinsLottie => 'assets/images/wallet_coins_lottie.json';

  /// List of all assets
  List<dynamic> get values => [add, gemini, moolahLottie, walletCoinsLottie];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
