import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
// import 'package:flame/events.dart';
// import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:platform_jumper/components/jumpButton.dart';
import 'package:platform_jumper/components/level.dart';
import 'package:platform_jumper/components/player.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late CameraComponent cam;
  Player player = Player(character: "Mask Dude");

  late JoystickComponent joystick;
  bool showControls = true;
  bool playSound = false;
  double soundVolume = 1.0;
  List<String> levelNames = ["level-02", "level-01"];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    _loadLevel();
    if (showControls) {
      addJoistick();
      add(JumpButton());
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showControls) {
      updateJoystick();
    }
    super.update(dt);
  }

  void addJoistick() {
    joystick = JoystickComponent(
        priority: 1000000000000000000,
        knob: SpriteComponent(sprite: Sprite(images.fromCache("HUD/Knob.png"))),
        background: SpriteComponent(
            sprite: Sprite(images.fromCache("HUD/Joystick.png"))),
        margin: const EdgeInsets.only(left: 32, bottom: 32));
    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        player.horizontalMovement = 0;
    }
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 1), () {
      Level world =
          Level(player: player, levelName: levelNames[currentLevelIndex]);

      cam = CameraComponent.withFixedResolution(
          world: world, width: 640, height: 360);

      if (currentLevelIndex != 0) {
        cam.viewfinder.anchor = Anchor.topLeft;
      } else {
        cam.viewfinder.anchor = Anchor.center;
      }
      addAll([cam, world]);
    });
  }
}
