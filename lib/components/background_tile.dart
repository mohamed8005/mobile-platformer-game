import 'dart:async';

import 'package:flame/components.dart';

import 'package:platform_jumper/pixel_adventure.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<PixelAdventure> {
  final String color;
  BackgroundTile({position, this.color = "Gray"}) : super(position: position);

  final double scrollspeed = 0.5;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache('Background/$color.png'));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.y += scrollspeed;
    double tilesize = 64;
    int scrollheight = (game.size.y / tilesize).floor();
    if (position.y > scrollheight * tilesize) position.y = -tilesize;
    super.update(dt);
  }
}
