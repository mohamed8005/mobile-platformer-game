import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:platform_jumper/components/Chicken.dart';
import 'package:platform_jumper/components/background_tile.dart';
import 'package:platform_jumper/components/checkpoint.dart';
import 'package:platform_jumper/components/collision_block.dart';
import 'package:platform_jumper/components/fruit.dart';
import 'package:platform_jumper/components/player.dart';
import 'package:platform_jumper/components/saw.dart';
import 'package:platform_jumper/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  late TiledComponent level;
  final String levelName;
  final Player player;
  Level({required this.levelName, required this.player});
  List<CollisionBlock> collisionBlocks = [];
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2(16, 16));
    priority = -1;
    add(level);

    if (this.levelName != "level-01") {
      gameRef.cam.follow(player);
    }

    _scrollingBackground();
    _spawningObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backgroundLayer = level.tileMap.getLayer('background');
    const tilesize = 64;

    // final numTilesY = (game.size.y / tilesize).floor();
    // final numTilesX = (game.size.x / tilesize).floor();

    if (backgroundLayer != null) {
      final backgroundColor =
          backgroundLayer.properties.getValue('BackgroundColor');

      for (double y = 0; y < game.size.y / tilesize; y++) {
        for (double x = 0; x < game.size.x / tilesize; x++) {
          final backgroundTile = BackgroundTile(
              color: backgroundColor ?? 'Gray',
              position: Vector2(x * tilesize, y * tilesize - tilesize));
          add(backgroundTile);
        }
      }
    }
  }

  void _spawningObjects() {
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            // player.anchor = Anchor.center;
            player.scale.x = 1;
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
                fruit: spawnPoint.name,
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2.all(32));
            add(fruit);
            break;
          case 'Saw':
            final isVertical = spawnPoint.properties.getValue("isVertical");
            final offNeg = spawnPoint.properties.getValue("offNeg");
            final offPos = spawnPoint.properties.getValue("offPos");
            final saw = Saw(
                position: Vector2(
                  spawnPoint.x,
                  spawnPoint.y,
                ),
                size: Vector2.all(32),
                isVertical: isVertical,
                offNeg: offNeg,
                offPos: offPos);
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2.all(64));
            add(checkpoint);
            break;
          case 'Chicken':
            final offNeg = spawnPoint.properties.getValue("offNeg");
            final offPos = spawnPoint.properties.getValue("offPos");
            final chicken = Chicken(
                position: Vector2(spawnPoint.x, spawnPoint.y),
                size: Vector2(spawnPoint.width, spawnPoint.height),
                offNeg: offNeg,
                offPos: offPos);
            add(chicken);

            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>("Collision");
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height),
                isPlatform: true);
            collisionBlocks.add(platform);
            add(platform);
            break;
          default:
            final platform = CollisionBlock(
                position: Vector2(collision.x, collision.y),
                size: Vector2(collision.width, collision.height));
            collisionBlocks.add(platform);
            add(platform);
            break;
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
