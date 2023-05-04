import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:torch_light/torch_light.dart';

late ImageMap _imageMap;
AudioPlayer lightsaberOpenPlayer = AudioPlayer();
AudioPlayer lightsaberClosePlayer = AudioPlayer();
AudioPlayer lightsaberHumPlayer = AudioPlayer();
AudioPlayer lightsaberHum2Player = AudioPlayer();

main() async {
  // We need to call ensureInitialized if we are loading images before runApp
  // is called.
  // TODO: This should be refactored to use a loading screen
  WidgetsFlutterBinding.ensureInitialized();

  _imageMap = ImageMap();

  await _imageMap.load(<String>[
    'assets/images/starfield.png',
    'assets/images/lightsaber-off.png',
    'assets/images/lightsaber-on.png',
  ]);

  lightsaberOpenPlayer.setReleaseMode(ReleaseMode.stop);
  lightsaberOpenPlayer.setSourceAsset("sounds/lightsaber-open.wav");
  lightsaberOpenPlayer.setPlaybackRate(1.2);
  lightsaberOpenPlayer.setVolume(0.75);

  lightsaberClosePlayer.setReleaseMode(ReleaseMode.stop);
  lightsaberClosePlayer.setSourceAsset("sounds/lightsaber-close.wav");
  lightsaberClosePlayer.setPlaybackRate(1.2);
  lightsaberClosePlayer.setVolume(0.75);

  lightsaberHumPlayer.setReleaseMode(ReleaseMode.stop);
  lightsaberHumPlayer.setSourceAsset("sounds/lightsaber-hum.wav");
  lightsaberHumPlayer.setPlaybackRate(1);

  lightsaberHum2Player.setReleaseMode(ReleaseMode.stop);
  lightsaberHum2Player.setSourceAsset("sounds/lightsaber-hum.wav");
  lightsaberHum2Player.setPlaybackRate(1);

  runApp(const MyLightsaberApp());
}

class MyLightsaberApp extends StatelessWidget {
  const MyLightsaberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Epic Lightsaber',
      home: Lightsaber(),
    );
  }
}

class Lightsaber extends StatefulWidget {
  const Lightsaber({super.key});

  @override
  LightsaberState createState() => LightsaberState();
}

class LightsaberState extends State<Lightsaber> {
  bool isLightsaberOn = false;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  int humPosition = 0;
  int hum2Position = 0;

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    lightsaberHumPlayer.onPositionChanged.listen((event) {
      humPosition = event.inMilliseconds;
    });

    lightsaberHum2Player.onPositionChanged.listen((event) {
      hum2Position = event.inMilliseconds;
    });

    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) async {
          var speed = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
          if (speed > 4 && isLightsaberOn) {
            if (humPosition == 0) {
              await lightsaberHumPlayer.resume();
            }

            if (humPosition > 600 && hum2Position == 0) {
              await lightsaberHum2Player.resume();
            }
          }
          if (speed > 5 && isLightsaberOn) {}
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/starfield.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: MediaQuery.of(context).size.width / 2 - 24,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: isLightsaberOn
                      ? Image.asset(
                          "assets/images/lightsaber-on.png",
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/lightsaber-off-2.png",
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: MediaQuery.of(context).size.width / 2 - 24,
                child: GestureDetector(
                  onTapDown: (_) async {
                    setState(() {
                      isLightsaberOn = true;
                    });
                    await lightsaberOpenPlayer.resume();

                    await _enableTorch();
                  },
                  onTapUp: (_) => _closeLightsaber(),
                  // TODO: Improve touch/tap experience
                  onTapCancel: () => _closeLightsaber(),
                  child: Container(
                    height: 200.0,
                    width: 52.0,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Container(),
                  ),
                ),
              ),
              // const LaserDisplay(),
            ],
          )),
    );
  }

  Future<void> _closeLightsaber() async {
    setState(() {
      isLightsaberOn = false;
    });
    await lightsaberClosePlayer.resume();
    await lightsaberHumPlayer.stop();
    await lightsaberHum2Player.stop();

    await _disableTorch();
  }

  Future<void> _enableTorch() async {
    try {
      await TorchLight.enableTorch();
    } on Exception catch (_) {
      //
    }
  }

  Future<void> _disableTorch() async {
    try {
      await TorchLight.disableTorch();
    } on Exception catch (_) {
      //
    }
  }
}
