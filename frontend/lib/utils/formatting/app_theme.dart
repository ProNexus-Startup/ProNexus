import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xff375dfb);
const Color greenButtonColor = Color(0xff38c793);
const Color lightGrey = Color(0xfff2f4f6);
const Color darkGrey = Color(0xff999999);
const Color lightGreyLight = Color(0xffF6B4BA);
const Color mustardYellow = Color(0xFFffdd00);
const Color offWhite = Color(0xffF2F4F6);
const Color redColor = Color(0xfff97071);

const FlexSubThemesData wgerSubThemeData = FlexSubThemesData(
  fabSchemeColor: SchemeColor.secondary,
  inputDecoratorBorderType: FlexInputBorderType.underline,
  inputDecoratorIsFilled: false,
  useTextTheme: true,
  appBarScrolledUnderElevation: 4,
  navigationBarIndicatorOpacity: 0.24,
  navigationBarHeight: 56,
);

const String mainFont = 'Inter';
const List<FontVariation> displayFontBoldWeight = <FontVariation>[
  FontVariation('wght', 600)
];
const List<FontVariation> displayFontHeavyWeight = <FontVariation>[
  FontVariation('wght', 800)
];

// Make a light ColorScheme from the seeds.
final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
  primary: primaryBlue,
  primaryKey: primaryBlue,
  secondaryKey: offWhite,
  secondary: offWhite,
  tertiaryKey: lightGrey,
  brightness: Brightness.light,
  tones: FlexTones.vivid(Brightness.light),
);

// Make a dark ColorScheme from the seeds.
final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
  primaryKey: primaryBlue,
  secondaryKey: lightGrey,
  secondary: lightGrey,
  brightness: Brightness.dark,
  tones: FlexTones.vivid(Brightness.dark),
);

// Make a high contrast light ColorScheme from the seeds
final ColorScheme schemeLightHc = SeedColorScheme.fromSeeds(
  primaryKey: primaryBlue,
  secondaryKey: lightGrey,
  brightness: Brightness.light,
  tones: FlexTones.ultraContrast(Brightness.light),
);

// Make a ultra contrast dark ColorScheme from the seeds.
final ColorScheme schemeDarkHc = SeedColorScheme.fromSeeds(
  primaryKey: primaryBlue,
  secondaryKey: lightGrey,
  brightness: Brightness.dark,
  tones: FlexTones.ultraContrast(Brightness.dark),
);

const wgerTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontHeavyWeight,
  ),
  displayMedium: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontHeavyWeight,
  ),
  displaySmall: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontHeavyWeight,
  ),
  headlineLarge: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontBoldWeight,
  ),
  headlineMedium: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontBoldWeight,
  ),
  headlineSmall: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontBoldWeight,
  ),
  titleLarge: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontBoldWeight,
  ),
  titleMedium: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontBoldWeight,
  ),
  titleSmall: TextStyle(
    fontFamily: mainFont,
    fontVariations: displayFontBoldWeight,
  ),
);

final wgerLightTheme = FlexThemeData.light(
  colorScheme: schemeLight,
  useMaterial3: true,
  appBarStyle: FlexAppBarStyle.primary,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
).copyWith(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: primaryBlue, // Text color
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

final wgerDarkTheme = FlexThemeData.dark(
  colorScheme: schemeDark,
  useMaterial3: true,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
).copyWith(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: primaryBlue, // Text color
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

final wgerLightThemeHc = FlexThemeData.light(
  colorScheme: schemeLightHc,
  useMaterial3: true,
  appBarStyle: FlexAppBarStyle.primary,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
).copyWith(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: primaryBlue, // Text color
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);

final wgerDarkThemeHc = FlexThemeData.dark(
  colorScheme: schemeDarkHc,
  useMaterial3: true,
  subThemesData: wgerSubThemeData,
  textTheme: wgerTextTheme,
).copyWith(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: primaryBlue, // Text color
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
