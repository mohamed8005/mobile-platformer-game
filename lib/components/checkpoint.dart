import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:platform_jumper/components/player.dart';
import 'package:platform_jumper/pixel_adventure.dart';

const double stepTime = 0.05;
bool isReached = false;

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
    priority = 5;
    add(RectangleHitbox(position: Vector2(18, 56), size: Vector2(12, 8)));

    animation = SpriteAnimation.fromFrameData(
        game.images
            .fromCache('Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png'),
        SpriteAnimationData.sequenced(
            amount: 1, stepTime: stepTime, textureSize: Vector2.all(64)));
    return super.onLoad();
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   if (other is Player) {
  //     _reachedCheckpoint();
  //   }
  //   super.onCollision(intersectionPoints, other);
  // }
  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachedCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _reachedCheckpoint() {
    if (!isReached) {
      isReached = true;
      animation = SpriteAnimation.fromFrameData(
          game.images.fromCache(
              'Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png'),
          SpriteAnimationData.sequenced(
              amount: 26, stepTime: stepTime, textureSize: Vector2.all(64)));

      Future.delayed(Duration(milliseconds: 50 * 26), () {
        animation = SpriteAnimation.fromFrameData(
            game.images.fromCache(
                'Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png'),
            SpriteAnimationData.sequenced(
                amount: 10, stepTime: stepTime, textureSize: Vector2.all(64)));
      });
    }
  }
}
