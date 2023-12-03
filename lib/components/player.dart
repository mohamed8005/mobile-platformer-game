import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:platform_jumper/components/Chicken.dart';
import 'package:platform_jumper/components/checkpoint.dart';
import 'package:platform_jumper/components/collision_block.dart';
import 'package:platform_jumper/components/custom_hitbox.dart';
import 'package:platform_jumper/components/fruit.dart';
import 'package:platform_jumper/components/saw.dart';
import 'package:platform_jumper/components/utils.dart';
import 'package:platform_jumper/pixel_adventure.dart';

enum PlayerStates {
  idle,
  running,
  jumping,
  falling,
  hit,
  appearing,
  disappearing
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({position, this.character = "Ninja Frog"}) : super(position: position);

  final double stepTime = 0.05;
  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;

  double moveSpeed = 100;
  Vector2 startingPosition = Vector2.zero();
  double horizontalMovement = 0;
  double _gravity = 9.8;
  double _jumpForce = 260;
  double _terminalVelocity = 300;
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  Vector2 velocity = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  bool isFacingRight = true;
  bool reachedCheckpoint = false;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  CustomHitBox playerHitBox =
      CustomHitBox(offsetX: 10, offsetY: 4, height: 28, width: 14);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // debugMode = true;
    startingPosition = Vector2(position.x, position.y);
    add(RectangleHitbox(
        position: Vector2(playerHitBox.offsetX, playerHitBox.offsetY),
        size: Vector2(playerHitBox.width, playerHitBox.height)));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt;
    while (accumulatedTime >= fixedDeltaTime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerState();
        _updatePlayerMovement(fixedDeltaTime);
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltaTime);
        _checkVerticalCollisions();
        if (position.y > 360) {
          _respawn();
        }
      }
      accumulatedTime -= fixedDeltaTime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    hasJumped = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;
    return super.onKeyEvent(event, keysPressed);
  }

  // @override
  // void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   // if (!reachedCheckpoint) {
  //   //   if (other is Fruit) {
  //   //     other.collidedWithPlayer();
  //   //   } else if (other is Saw) {
  //   //     _respawn();
  //   //   } else if (other is Checkpoint) {
  //   //     _reachedCheckpoint();
  //   //   }
  //   // }
  //   super.onCollision(intersectionPoints, other);
  // }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) {
        // if (game.playSound) {
        //   FlameAudio.play("pickupCoin.wav", volume: game.soundVolume);
        // }
        other.collidedWithPlayer();
      } else if (other is Saw) {
        _respawn();
      } else if (other is Checkpoint) {
        _reachedCheckpoint();
      } else if (other is Chicken) {
        other.collidedWithPlayer();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _loadAllAnimations() {
    idleAnimation = _spriteAnimation('Idle', 11);

    runningAnimation = _spriteAnimation('Run', 12);
    jumpingAnimation = _spriteAnimation('Jump', 1);
    fallingAnimation = _spriteAnimation('Fall', 1);
    hitAnimation = _spriteAnimation('Hit', 7);
    appearingAnimation = _specialSpriteAnimation('Appearing', 7);
    disappearingAnimation = _specialSpriteAnimation('Desappearing', 7);
    animations = {
      PlayerStates.idle: idleAnimation,
      PlayerStates.running: runningAnimation,
      PlayerStates.jumping: jumpingAnimation,
      PlayerStates.falling: fallingAnimation,
      PlayerStates.hit: hitAnimation,
      PlayerStates.appearing: appearingAnimation,
      PlayerStates.disappearing: disappearingAnimation,
    };

    current = PlayerStates.running;
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$character/$state (32x32).png"),
        SpriteAnimationData.sequenced(
            amount: amount, stepTime: stepTime, textureSize: Vector2.all(32)));
  }

  SpriteAnimation _specialSpriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
        game.images.fromCache("Main Characters/$state (96x96).png"),
        SpriteAnimationData.sequenced(
            amount: amount,
            stepTime: stepTime,
            textureSize: Vector2.all(96),
            loop: false));
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }
    // if (velocity.y > _gravity) {
    //   isOnGround = false;
    // }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _updatePlayerState() {
    PlayerStates playerState = PlayerStates.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    if (velocity.x > 0 || velocity.x < 0) {
      playerState = PlayerStates.running;
    }

    if (velocity.y > _gravity) {
      playerState = PlayerStates.falling;
    }
    if (velocity.y < 0) {
      playerState = PlayerStates.jumping;
    }

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - playerHitBox.offsetX - playerHitBox.width;
            break;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x +
                block.width +
                playerHitBox.offsetX +
                playerHitBox.width;
            break;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - playerHitBox.offsetY - playerHitBox.height;
            isOnGround = true;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - playerHitBox.offsetY - playerHitBox.height;
            isOnGround = true;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - playerHitBox.offsetY;
            break;
          }
        }
      }
    }
  }

  void _playerJump(double dt) {
    if (game.playSound) {
      FlameAudio.play('jump.wav', volume: game.soundVolume);
    }
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    hasJumped = false;
    isOnGround = false;
  }

  void _respawn() async {
    if (game.playSound) {
      FlameAudio.play("hitHurt.wav", volume: game.soundVolume);
    }
    const hitDuration = Duration(milliseconds: 50 * 7);
    gotHit = true;
    current = PlayerStates.hit;

    // await animationTicker?.completed;
    Future.delayed(hitDuration, () {
      position = startingPosition - Vector2.all(96 - 64);

      current = PlayerStates.appearing;
      scale.x = 1;
      Future.delayed(Duration(milliseconds: 50 * 7), () {
        position = startingPosition;
        velocity = Vector2(0, 0);
        _updatePlayerState();
        gotHit = false;
      });
    });
  }

  Future<void> _reachedCheckpoint() async {
    if (game.playSound) {
      FlameAudio.play("powerUp.wav", volume: game.soundVolume);
    }
    reachedCheckpoint = true;
    if (scale.x > 0) {
      position = position - Vector2.all(96 - 64);
    } else {
      position = position + Vector2(32, -32);
    }
    current = PlayerStates.disappearing;
    await animationTicker?.completed;
    animationTicker?.reset();
    reachedCheckpoint = false;
    position = Vector2.all(-640);
    Future.delayed(const Duration(seconds: 3), () {
      game.loadNextLevel();
    });
  }

  void collidedWithEnemy() {
    _respawn();
  }
}
