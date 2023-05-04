import 'package:flutter/material.dart';
import 'package:lightsaber_may_4/repeated_image.dart';
import 'package:spritewidget/spritewidget.dart';

late ImageMap _imageMap;

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  MyWidgetState createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  late NodeWithSize rootNode;

  @override
  void initState() {
    super.initState();
    double scale = 1;

    rootNode = NodeWithSize(Size(320.0 * scale, 320.0 * scale));
  }

  @override
  Widget build(BuildContext context) {
    final background = RepeatedImage(_imageMap["assets/images/starfield.png"]!);
    rootNode.addChild(background);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/starfield.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: const LaserDisplay(),
      ),
    );
  }
}

class LaserDisplay extends StatelessWidget {
  const LaserDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 320.0,
        height: 320.0,
        child: SpriteWidget(Lightsaber()),
      ),
    );
  }
}

class Lightsaber extends NodeWithSize {
  Sprite lightsaber =
      Sprite.fromImage(_imageMap["assets/images/lightsaber-off.png"]!);

  Lightsaber() : super(const Size(288.0, 288.0)) {
    userInteractionEnabled = true;
    // Node placementNode = Node();
    // placementNode.position = const Offset(8.0, 8.0);
    // placementNode.scale = 0.7;
    // addChild(placementNode);
    lightsaber.position = const Offset(144, 400);
    addChild(lightsaber);
  }

  @override
  handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerEventType.down) {
      removeChild(lightsaber);
      lightsaber =
          Sprite.fromImage(_imageMap["assets/images/lightsaber-on.png"]!);
      lightsaber.position = const Offset(144, 149);
      addChild(lightsaber);
    } else if (event.type == PointerEventType.up) {
      removeChild(lightsaber);
      lightsaber =
          Sprite.fromImage(_imageMap["assets/images/lightsaber-off.png"]!);
      lightsaber.position = const Offset(144, 400);
      addChild(lightsaber);
    }

    return true;
  }
}
