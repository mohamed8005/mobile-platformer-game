import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:platform_jumper/components/player.dart';
import 'package:platform_jumper/pixel_adventure.dart';

enum State { idle, run, hit }

class Chicken extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final double offNeg;
  final double offPos;
  Chicken({position, size, this.offNeg = 0, this.offPos = 0})
      : super(position: position, size: size);

  static const stepTime = 0.05;
  final textureSize = Vector2(32, 34);
  late final SpriteAnimation _idleAnimation;
  late final SpriteAnimation _runAnimation;
  late final SpriteAnimation _hitAnimation;
  late final Player player;
  double rangeNeg = 0;
  double rangePos = 0;
  double moveDirection = 1;
  double targetDirection = -1;
  static const runSpeed = 80;
  bool gotstomped = false;
  Vector2 velocity = Vector2.zero();
  @override
  FutureOr<void> onLoad() {
    debugMode = false;
    add(
      RectangleHitbox(position: Vector2(4, 6), size: Vector2(24, 26)),
    );
    player = game.player;
    _loadAllAnimations();
    _calculateRange();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gotstomped) {
    } else {
      _updateState();
      _movement(dt);
      super.update(dt);
    }
  }

  void _loadAllAnimations() {
    _idleAnimation = _spriteAnimation('Idle', 13);
    _runAnimation = _spriteAnimation('Run', 14);
    _hitAnimation = _spriteAnimation('Hit', 15)..loop = false;
    animations = {
      State.idle: _idleAnimation,
      State.run: _runAnimation,
      State.hit: _hitAnimation,
    };

    current = State.idle;
  }

  SpriteAnimation _spriteAnimation(
    String state,
    int amount,
  ) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache('Enemies/Chicken/$state (32x34).png'),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: textureSize));
  }

  void _calculateRange() {
    rangeNeg = position.x - offNeg * 16;
    rangePos = position.x + offPos * 16;
  }

  void _movement(dt) {
    velocity.x = 0;
    velocity.y = 0;
    double playerOffset = (player.scale.x > 0) ? 0 : -player.width;
    double chickenOffset = (scale.x > 0) ? 0 : -width;

    if (playerInRange()) {
      player.x - position.x < 0 ? velocity.x = -60 : velocity.x = 60;
      targetDirection =
          (player.x + playerOffset < position.x + chickenOffset) ? -1 : 1;
      velocity.x = targetDirection * runSpeed;
      moveDirection = lerpDouble(moveDirection, targetDirection, 0.1) ?? 1;
    }
    position.x += velocity.x * dt;
    position.y += velocity.y * dt;
  }

  bool playerInRange() {
    double playerOffset = (player.scale.x > 0) ? 0 : -player.scale.x;

    return player.x + playerOffset >= rangeNeg &&
        player.x + playerOffset <= rangePos &&
        player.y + player.height > position.y &&
        player.y < position.y + height;
  }

  void _updateState() {
    current = (velocity.x != 0) ? State.run : State.idle;
    if ((moveDirection > 0 && scale.x > 0) ||
        (moveDirection < 0 && scale.x < 0)) {
      flipHorizontallyAroundCenter();
    }
  }

  void collidedWithPlayer() async {
    if (player.velocity.y > 0 && player.y + player.height > position.y) {
      if (game.playSound) {
        FlameAudio.play('powerUp.wav', volume: game.soundVolume);
      }
      gotstomped = true;
      current = State.hit;
      player.velocity.y = -260;
      Future.delayed(Duration(milliseconds: 50 * 5), () {
        removeFromParent();
      });
    } else {
      player.collidedWithEnemy();
    }
  }
}
