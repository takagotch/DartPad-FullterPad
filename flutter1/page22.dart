import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'dart:math';

final speakerSprite = NetworkImage(
    "https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/product_detail_zoom%2Fspeaker_sprite.png?alt=media&token=caea503f-8e4a-4e82-80e5-bec89eecd765");

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const title = '3D Product Detail Zoom';
    return MaterialApp(
        title: title, themeMode: ThemeMode.dark, debugShowCheckedModeBanner: false, home: ProductDetailZoomDemo());
  }
}

class ProductDetailZoomDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductDetailZoomDemoState();
}

class _ProductDetailZoomDemoState extends State<ProductDetailZoomDemo> with SingleTickerProviderStateMixin {
  Size _screenSize;
  double _frameHeight;
  double _frameWidth;
  double _buttonAlpha = 0;

  TextStyle bodyStyle = TextStyle(fontFamily: 'WorkSans', fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2);

  @override
  void initState() {
    super.initState();
    _buttonAlpha = 0;
    _transitionIn();
  }

  @override
  void didChangeDependencies() {
    precacheImage(speakerSprite, context);
    super.didChangeDependencies();
  }

  void _transitionIn() async {
    setState(() => _buttonAlpha = 1);
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    _initFrameValues();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          //Create a Hero tagged to match the instance details view
          Hero(
            tag: 'hero-speaker',
            //Use a custom flightShuttleBuilder to control the hero transition
            flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
              return ProductDetailsHeroFlight(
                animation: animation,
                toHeroContext: toHeroContext,
                framwWidth: _frameWidth,
                framwHeight: _frameHeight,
              );
            },
            //The child of the hero, is the main speaker animation
            child: Align(
              alignment: Alignment.center,
              child: Container(
                  width: _frameWidth,
                  height: _frameHeight,
                  child: Sprite(image: speakerSprite, frameWidth: 360, frameHeight: 500, frame: 1)),
            ),
          ),
          Align(
            alignment: Alignment(0, 0),
            child: Transform.translate(
              offset: Offset(100, 0),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 350),
                opacity: _buttonAlpha,
                child: PulsingButton(
                  onPressed: _handleOnPressed,
                  icon: Icons.add,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  void _initFrameValues() {
    double screenRatio = _screenSize.height / _screenSize.width;
    double frameRatio = screenRatio < 2 ? screenRatio / 2 : .95;
    _frameWidth = _screenSize.width * frameRatio;
    _frameHeight = (500 * _frameWidth) / 360;
  }

  void _handleOnPressed() async {
    //Don't accept button presses if we're currently fading the btn in or out
    if (_buttonAlpha < 1) return;
    //Fade button out
    setState(() => _buttonAlpha = 0);
    //Wait a bit to let the btn fade out
    await Future.delayed(Duration(milliseconds: 300));
    //Show new page route, which will place the Hero on top of everything
    Navigator.push(
        context,
        FadeColorPageRoute(
          color: Colors.black,
          enterPage: ProductDetailView(),
        ));
    //Fade button back in, now that hero is covering it
    setState(() => _buttonAlpha = 1);
  }
}

class ProductDetailsHeroFlight extends StatelessWidget {
  final Animation<double> animation;
  final BuildContext toHeroContext;
  final double framwWidth;
  final double framwHeight;

  const ProductDetailsHeroFlight(
      {Key key, @required this.animation, @required this.toHeroContext, this.framwWidth, this.framwHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: framwWidth,
          height: framwHeight,
          child: AnimatedSprite(
            image: speakerSprite,
            frameWidth: 360,
            frameHeight: 500,
            animation: Tween(begin: 0.0, end: 59.0).animate(CurvedAnimation(curve: Interval(0, .8), parent: animation)),
          ),
        ),
        Container(
          width: framwWidth,
          height: framwHeight,
          child: AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              return DefaultTextStyle(
                style: DefaultTextStyle.of(toHeroContext).style,
                child: ProductDetailsTransition(animationValue: animation.value),
              );
            },
          ),
        )
      ],
    );
  }
}

class AnimatedSprite extends AnimatedWidget {
  final ImageProvider image;
  final int frameWidth;
  final int frameHeight;

  AnimatedSprite({
    Key key,
    @required this.image,
    @required this.frameWidth,
    this.frameHeight,
    @required Animation<double> animation,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Sprite(
      image: image,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      frame: animation.value,
    );
  }
}

class Sprite extends StatefulWidget {
  final ImageProvider image;
  final int frameWidth;
  final int frameHeight;
  final num frame;

  Sprite({Key key, @required this.image, @required this.frameWidth, this.frameHeight, this.frame = 0})
      : super(key: key);

  @override
  _SpriteState createState() => _SpriteState();
}

class _SpriteState extends State<Sprite> {
  ImageStream _imageStream;
  ImageInfo _imageInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(Sprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _getImage();
    }
  }

  void _getImage() {
    final ImageStream oldImageStream = _imageStream;
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    if (_imageStream.key == oldImageStream?.key) {
      return;
    }
    final ImageStreamListener listener = ImageStreamListener(_updateImage);
    oldImageStream?.removeListener(listener);
    _imageStream.addListener(listener);
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ui.Image img = _imageInfo?.image;
    if (img == null) {
      return SizedBox();
    }
    int w = img.width, frame = widget.frame.round();
    int frameW = widget.frameWidth, frameH = widget.frameHeight;
    int cols = (w / frameW).floor();
    int col = frame % cols, row = (frame / cols).floor();
    ui.Rect rect = ui.Rect.fromLTWH(col * frameW * 1.0, row * frameH * 1.0, frameW * 1.0, frameH * 1.0);
    return CustomPaint(painter: _SpritePainter(img, rect));
  }
}

class _SpritePainter extends CustomPainter {
  ui.Image image;
  ui.Rect rect;

  _SpritePainter(this.image, this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(image, rect, ui.Rect.fromLTWH(0.0, 0.0, size.width, size.height), Paint());
  }

  @override
  bool shouldRepaint(_SpritePainter oldPainter) {
    return oldPainter.image != image || oldPainter.rect != rect;
  }
}

class ProductDetailsTransition extends StatelessWidget {
  final double animationValue;
  final CurvedAnimation _curvedAnimation;
  final TextStyle bodyStyle =
      TextStyle(fontFamily: 'WorkSans', fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2);

  ProductDetailsTransition({Key key, this.animationValue = 1})
      : _curvedAnimation = CurvedAnimation(
            curve: Interval(0, .8, curve: Curves.easeOut), parent: AlwaysStoppedAnimation(animationValue)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Positioned(
          top: 25,
          left: 45,
          child: _SpeakerAttribute(
            attribute: 'Spectacular tonal range',
            animation: _getAttributeAnimWithInterval(0, .85),
            lineHeight: 270,
          ),
        ),
        Positioned(
          top: 75,
          left: 95,
          child: _SpeakerAttribute(
            attribute: 'Superior-grade aluminum',
            animation: _getAttributeAnimWithInterval(.35, .95),
            lineHeight: 250,
          ),
        ),
        Positioned(
          top: 120,
          left: 175,
          child: _SpeakerAttribute(
            attribute: 'Deep 30Hz bass',
            animation: _getAttributeAnimWithInterval(.45, 1),
            lineHeight: 185,
          ),
        ),
        ScaleTransition(
          scale: Tween<double>(begin: .6, end: 1).animate(_curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(.6, .7), end: Offset(.1, .95)).animate(_curvedAnimation),
            child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(_getCurvedAnimWithInterval(.2, 1)),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.01)
                    ..rotateY(Tween<double>(begin: -.09, end: 0).transform(CurvedAnimation(
                      curve: Interval(0, .8),
                      parent: AlwaysStoppedAnimation(animationValue),
                    ).value)),
                  child: Container(
                    width: 300,
                    height: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Perfect Sound'.toUpperCase(),
                            style: bodyStyle.copyWith(
                                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 52, height: .9)),
                        Text(
                          'This is our best speaker yet.',
                          textAlign: TextAlign.start,
                          style: bodyStyle.copyWith(
                              color: Colors.white, height: 1.5, fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  CurvedAnimation _getCurvedAnimWithInterval(double begin, double end) {
    return CurvedAnimation(curve: Interval(begin, end), parent: _curvedAnimation);
  }

  CurvedAnimation _getAttributeAnimWithInterval(double begin, double end) {
    var attributeAnim = CurvedAnimation(curve: Interval(.65, 1), parent: AlwaysStoppedAnimation(animationValue));
    return CurvedAnimation(curve: Interval(begin, end), parent: attributeAnim);
  }
}

class _SpeakerAttribute extends StatelessWidget {
  final double lineHeight;
  final Animation animation;
  final String attribute;

  const _SpeakerAttribute({Key key, this.lineHeight = 150, this.attribute, this.animation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double lineHeight =
        Tween<double>(begin: 0, end: this.lineHeight).transform(Curves.easeInOutQuad.transform(animation.value));
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        SlideTransition(
          position: Tween<Offset>(begin: Offset(0, -.5), end: Offset.zero).animate(_getAnimationWithInterval(.2, 1)),
          child: FadeTransition(
            opacity: _getAnimationWithInterval(.15, .95),
            child: Text(
              attribute,
              style: TextStyle(fontFamily: 'WorkSans', letterSpacing: 3, color: Colors.white, fontSize: 13.5),
            ),
          ),
        ),
        Positioned(
          top: lineHeight / 2 + 17,
          left: -lineHeight / 2 + 5,
          child: Transform.rotate(
            angle: pi / 2,
            child: Container(
              width: lineHeight,
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          top: lineHeight + 17,
          left: 5,
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(_getAnimationWithInterval(0, .3)),
            child: CustomPaint(
                painter: CirclePainter(
              radius: 3,
              color: Colors.white,
            )),
          ),
        ),
      ],
    );
  }

  CurvedAnimation _getAnimationWithInterval(double begin, double end) {
    return CurvedAnimation(curve: Interval(begin, end), parent: animation);
  }
}

class PulsingButton extends StatefulWidget {
  final Function onPressed;
  final IconData icon;

  const PulsingButton({Key key, @required this.onPressed, @required this.icon}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton> with SingleTickerProviderStateMixin {
  AnimationController _btnAnimController;
  CurvedAnimation _btnAnim;

  @override
  void initState() {
    super.initState();
    _btnAnimController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200))..repeat();
    _btnAnim = CurvedAnimation(curve: Curves.linear, parent: _btnAnimController);
  }

  @override
  void dispose() {
    _btnAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: Tween<double>(begin: .7, end: 0).animate(_btnAnim),
          child: ScaleTransition(
            scale: Tween<double>(begin: .5, end: 1).animate(_btnAnim),
            child: CustomPaint(
              painter: CirclePainter(
                radius: 28,
                color: Color(0xff27aeef),
              ),
              //Add a sizedbox child to the CustomPaint, to give the button more hit area
              child: SizedBox(
                width: 70,
                height: 70,
              ),
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _btnAnimController,
          builder: (BuildContext context, Widget child) {
            double opacity = Tween<double>(begin: .7, end: .9).transform(_btnAnim.value);
            return MaterialButton(
              height: 28,
              splashColor: Color(0xff0f668f),
              hoverColor: Color(0xff0f668f),
              color: Color(0xff27aeef).withOpacity(opacity),
              textColor: Colors.white,
              child: Icon(widget.icon),
              shape: CircleBorder(),
              onPressed: widget.onPressed,
            );
          },
        )
      ],
    );
  }
}

class FadeColorPageRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Color color;

  FadeColorPageRoute({this.enterPage, @required this.color})
      : super(
          transitionDuration: Duration(seconds: 3),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            Animation fadeOut =
                Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(curve: Interval(0, .2), parent: animation));
            Animation fadeIn =
                Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(curve: Interval(.8, 1), parent: animation));
            return Stack(children: <Widget>[
              FadeTransition(
                opacity: fadeOut,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: color,
                ),
              ),
              FadeTransition(
                opacity: fadeIn,
                child: child,
              )
            ]);
          },
        );
}

class ProductDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenRatio = screenSize.height / screenSize.width;
    double frameRatio = screenRatio < 2 ? screenRatio / 2 : .95;
    double frameWidth = screenSize.width * frameRatio;
    double frameHeight = (500 * frameWidth) / 360;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Hero(
                tag: 'hero-speaker',
                child: Container(
                    width: frameWidth,
                    height: frameHeight,
                    child: Sprite(image: speakerSprite, frameWidth: 360, frameHeight: 500, frame: 59)),
              ),
            ),
            Align(
                alignment: Alignment.center,
                child: Container(width: frameWidth, height: frameHeight, child: ProductDetailsTransition())),
            Align(
              alignment: Alignment(0, 0),
              child: Transform.translate(
                offset: Offset(100, 0),
                child: DelayedFadeIn(
                  delay: Duration(seconds: 1),
                  child: PulsingButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icons.remove,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Paint _paint;
  final Color color;
  final double radius;

  CirclePainter({this.color, this.radius})
      : _paint = Paint()
          ..color = color
          ..strokeWidth = 10.0
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, _paint);
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class DelayedFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const DelayedFadeIn({Key key, this.child, @required this.delay, this.duration = const Duration(milliseconds: 700)})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DelayedFadeInState();
}

class _DelayedFadeInState extends State<DelayedFadeIn> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _animationController.duration = widget.duration + widget.delay;
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: CurvedAnimation(curve: Interval(.9, 1), parent: _animationController), child: widget.child);
  }
}
