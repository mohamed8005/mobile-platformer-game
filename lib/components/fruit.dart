import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:platform_jumper/components/custom_hitbox.dart';
import 'package:platform_jumper/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  final CustomHitBox fruitHitBox =
      CustomHitBox(offsetX: 10, offsetY: 10, height: 12, width: 12);
  Fruit({position, size, this.fruit = "Apple"})
      : super(position: position, size: size);
  bool _collected = false;
  final double stepTime = 0.05;
  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = 5;
    add(RectangleHitbox(
      position: Vector2(fruitHitBox.offsetX, fruitHitBox.offsetY),
      size: Vector2(fruitHitBox.width, fruitHitBox.height),
    ));
    animation = SpriteAnimation.fromFrameData(
        game.images.fromCache('Items/Fruits/$fruit.png'),
        SpriteAnimationData.sequenced(
            amount: 17, stepTime: stepTime, textureSize: size));
    return super.onLoad();
  }

  void collidedWithPlayer() {
    if (!_collected) {
      if (game.playSound) {
        FlameAudio.play("pickupCoin.wav", volume: game.soundVolume);
      }
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache('Items/Fruits/Collected.png'),
          SpriteAnimationData.sequenced(
              amount: 6, stepTime: stepTime, textureSize: size, loop: false));
      _collected = true;
    }
    Future.delayed(const Duration(milliseconds: 400), () => removeFromParent());
  }
}
