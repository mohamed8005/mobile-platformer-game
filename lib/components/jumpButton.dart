import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:platform_jumper/pixel_adventure.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<PixelAdventure>, TapCallbacks {
  JumpButton();

  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/JumpButton.png'));
    position = Vector2(game.size.x - 32 - 64, game.size.y - 32 - 64);
    priority = 1000000000000000000;
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;

    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
