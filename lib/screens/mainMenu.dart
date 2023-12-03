import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_jumper/screens/gameplay.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  'platformer Escape',
                  style: TextStyle(fontSize: 50),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const GamePlay()));
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                child: const Text('Play'),
              ),
            ),
            ElevatedButton(onPressed: () {}, child: const Text('Options')),
          ],
        ),
      ),
    );
  }
}
