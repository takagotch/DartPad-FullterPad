import 'package:flutter/material.dart';

const String FIREBASE = 'https://firebasestorage.googleapis.com';
const String IMG_BG =
    '$FIREBASE/v0/b/qandtena.appspot.com/o/background.jpg?alt=media';

void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '{Q&10A}',
      home: Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(IMG_BG, fit: BoxFit.cover),
            Opacity(
              opacity: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF512DA8), Color(0xFFF57C00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                actions: [
                  SimpleButton('About Us'),
                  SimpleButton('Contact'),
                ],
              ),
            ),
            PoweredBy(),
            Center(
              child: HoverButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class HoverButton extends StatefulWidget {
  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  double localX = 0;
  double localY = 0;
  bool defaultPosition = true;
  bool downButton = false;

  double scaleX = 1;
  double scaleY = 1;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() => setState(() {
          scaleX = animation.value;
          scaleY = animation.value;
        }));
    animation = Tween<double>(begin: 1, end: 0.9).animate(CurvedAnimation(
      curve: Curves.decelerate,
      parent: animationController,
    ));
  }

  void _scaleAnimation() {
    animationController.forward();
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => downButton = true);
        animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final percentageX = (localX / (size.width * 0.45) / 2) * 100;
    final percentageY = (localY / ((size.height / 2) + 70) / 1.5) * 100;

    double screen = (size.width - 150) / (1280 - 150);
    screen = screen > 1.0 ? 1.0 : screen < 0 ? 0 : screen;
    final limits = ((screen * 100) * (0.4 - 0.75) / 100) + 0.75;
    final fontSize = ((screen * 100) * (1.0 - 0.3) / 100) + 0.3;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(defaultPosition ? 0 : (1.2 * (percentageY / 50) + -1.2))
        ..rotateY(defaultPosition ? 0 : (-0.3 * (percentageX / 50) + 0.3)),
      alignment: FractionalOffset.center,
      child: MouseRegion(
        onEnter: (_) => setState(() => defaultPosition = false),
        onExit: (_) => setState(() {
          localY = (size.height) / 2;
          localX = (size.width * 0.45) / 2;
          defaultPosition = true;
        }),
        onHover: (details) {
          if (mounted) setState(() => defaultPosition = false);
          if (details.localPosition.dx > 0 && details.localPosition.dy > 0) {
            if (details.localPosition.dx < (size.width * 0.45) * 1.5 &&
                details.localPosition.dy > 0) {
              localX = details.localPosition.dx;
              localY = details.localPosition.dy;
            }
          }
        },
        child: GestureDetector(
          onTapDown: (_) => _scaleAnimation(),
          onTapUp: (_) {},
          child: Transform(
            transform: Matrix4.identity()..scale(scaleX, scaleY),
            alignment: FractionalOffset.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: 140,
                  maxWidth: size.width * limits),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x70000000),
                      blurRadius: 30,
                      spreadRadius: -30,
                      offset: Offset(0, 60),
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Align(
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: 0.8,
                    child: Stack(
                      children: [
                        Transform(
                          transform: Matrix4.identity()
                            ..translate(
                              defaultPosition
                                  ? 0.0
                                  : (70 * (percentageX / 50) + -70),
                              defaultPosition
                                  ? 0.0
                                  : (80 * (percentageY / 50) + -80),
                              0.0,
                            ),
                          alignment: FractionalOffset.center,
                          child: Text(
                            '{Q&10A}​',
                            style: TextStyle(
                              fontSize: 120 * fontSize,
                              fontFamily: 'Sans',
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PoweredBy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 150,
        child: Padding(
          padding: EdgeInsets.only(bottom: 20, top: 10),
          child: GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Powered by',
                  style: TextStyle(
                      fontFamily: 'Sans', fontSize: 16, color: Colors.white),
                ),
                SizedBox(width: 5),
                Semantics(
                  child: FlutterLogo(),
                  label: "Flutter",
                  readOnly: true,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleButton extends StatelessWidget {
  final String text;

  const SimpleButton(this.text);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}
