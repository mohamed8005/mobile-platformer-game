import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_jumper/pixel_adventure.dart';

PixelAdventure _game = PixelAdventure();

class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
