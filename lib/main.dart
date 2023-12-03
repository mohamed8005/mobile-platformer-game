import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:platform_jumper/pixel_adventure.dart';
import 'package:platform_jumper/screens/mainMenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  // PixelAdventure game = PixelAdventure();
  // runApp(GameWidget(
  //   game: kDebugMode ? PixelAdventure() : game,
  // ));
  runApp(
    MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: MainMenu(),
    ),
  );
}
