// check
// https://dartpad.dev/40308e0a5f47acba46ba62f4d8be2bf4

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() => runApp(ParallaxTravelCardsHero());

const _urlBlowingLeaf =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FBlowingLeaf.png?alt=media&token=5a79cce9-c1ed-4b46-a282-7d383bacd749';
const _urlCloudLarge =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FCloudLarge.png?alt=media&token=373a86c0-c194-47ce-8bd8-fc6976cfad7d';
const _urlCloudSmal =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FCloudSmall.png?alt=media&token=085c9cdb-a81d-44b7-bdd5-0b82ac704c01';
const _urlGround =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FGround.png?alt=media&token=d3e4821c-d3dc-47ce-a3d5-2a08bea42c01';
const _urlParisBack =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FParis%2FParis-Back.png?alt=media&token=8bab90d4-82a3-4965-969a-8ddb9e9fe663';
const _urlParisFront =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FParis%2FParis-Front.png?alt=media&token=2fec3fe2-8d78-407b-9fda-301c7b8eeb2d';
const _urlParisMiddle =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FParis%2FParis-Middle.png?alt=media&token=e36163d6-2a53-4720-b7da-798818116124';
const _urlRoad =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FRoad.png?alt=media&token=432ca339-daa2-4ffa-a69f-17b1ecf5b97c';
const _urlTree =
    'https://firebasestorage.googleapis.com/v0/b/vgv-flutter-vignettes.appspot.com/o/parallax_travel_cards_hero%2FTree.png?alt=media&token=899827c3-5dc2-4c78-b0c1-da62888191d2';

class CityData {
  final String name;
  final String title;
  final String description;
  final String information;
  final Color color;

  const CityData({
    this.title,
    this.name,
    this.description,
    this.information,
    this.color,
  });
}

class CityDetailsPage extends StatelessWidget {
  final CityData city;

  const CityDetailsPage(this.city);

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildHeroWidget(context),
              _buildCityDetails(),
            ]),
        _buildBackButton(context),
      ]));

  Widget _buildBackButton(BuildContext context) => SafeArea(
      child: IconButton(
          padding: EdgeInsets.only(left: Styles.hzScreenPadding),
          icon: Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context)));

  Widget _buildCityDetails() => Expanded(
    child: Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(border: Border.all(color: Color(0xFFE9C0A2))),
      padding: const EdgeInsets.all(6.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Color(0xFFFCEDD3))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(city.title, style: Styles.appHeader),
              Container(
                  padding: const EdgeInsets.only(
                      top: 8,
                      left: Styles.hzScreenPadding * 1.5,
                      right: Styles.hzScreenPadding * 1.5),
                  child: Text(city.information,
                      style: Styles.cardSubtitle, textAlign: TextAlign.center)),
            ]),
      ),
  ));

  Widget _buildFlightWidget(
          BuildContext flightContext,
          Animation<double> heroAnimation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext) =>
      AnimatedBuilder(
          animation: heroAnimation,
          builder: (context, child) => DefaultTextStyle(
              style: DefaultTextStyle.of(toHeroContext).style,
              child: CityScenery(
                  city: city, animationValue: heroAnimation.value)));

  Widget _buildHeroWidget(context) => Hero(
      tag: '${city.name}-hero',
      flightShuttleBuilder: _buildFlightWidget,
      child: Container(
          height: MediaQuery.of(context).size.height * .55,
          width: double.infinity,
          child: CityScenery(animationValue: 1, city: city)));
}

class CityScenery extends StatelessWidget {
  final double animationValue;
  final CityData city;

  const CityScenery({this.animationValue = 0, @required this.city});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final animation = AlwaysStoppedAnimation(animationValue);
    return Stack(alignment: Alignment.center, children: <Widget>[
      _buildBackgroundTransition(animation),
      _buildCardInfo(animation, screenSize),
      _buildRoadTransition(animation, screenSize),
      FadeTransition(opacity: animation, child: _Clouds()),
      _buildCityAndTreesTransition(animation, screenSize),
      FadeTransition(opacity: animation, child: _Leaves()),
    ]);
  }

  Widget _buildBackgroundTransition(Animation animation) {
    final gradientStart = ColorTween(begin: city.color, end: Color(0xFFfde9c8))
        .animate(CurvedAnimation(curve: Curves.easeOut, parent: animation));
    final gradientEnd = ColorTween(begin: city.color, end: Color(0xFFfdf8f1))
        .evaluate(animation);
    final borderRadiusAnimation =
        Tween<double>(begin: Styles.cardBorderRadius, end: 0)
            .transform(animationValue);
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadiusAnimation),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [gradientStart.value, gradientEnd],
            )));
  }

  Widget _buildCardInfo(Animation animation, Size screenSize) => FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0)
          .animate(CurvedAnimation(curve: Interval(0, .22), parent: animation)),
      child: Container(
          padding: EdgeInsets.only(right: 35.0, left: 35.0, bottom: 8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Sized box gives the space of the city image in the stack
                SizedBox(height: screenSize.height * .22),
                Padding(
                    padding: const EdgeInsets.only(top: 22.0),
                    child: Text(city.title, style: Styles.cardTitle)),
                Text(city.description,
                    textAlign: TextAlign.center, style: Styles.cardSubtitle),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Learn More'.toUpperCase(),
                        style: Styles.cardAction))
              ])));

  Widget _buildCityAndTreesTransition(Animation animation, Size screenSize) {
    final sizeStart = Size(screenSize.width * .55, screenSize.height * .24);
    final sizeEnd = Size(screenSize.width, screenSize.height * .35);
    final sizeTransition = Tween(begin: sizeStart, end: sizeEnd).animate(
        CurvedAnimation(
            curve: Interval(.25, 1, curve: Curves.easeIn), parent: animation));

    final cityPositionTransition =
        Tween(begin: Offset(0, -screenSize.height * .112), end: Offset.zero)
            .animate(CurvedAnimation(
                curve: Interval(0.5, 1, curve: Curves.easeIn),
                parent: animation));

    final treesOpacityTransition = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            curve: Interval(.75, 1, curve: Curves.easeIn), parent: animation));

    return Transform.translate(
        offset: cityPositionTransition.value,
        child: Stack(alignment: Alignment.center, children: <Widget>[
          _CityImage(size: sizeTransition.value, city: city),
          FadeTransition(opacity: treesOpacityTransition, child: _Trees()),
        ]));
  }

  Widget _buildRoadTransition(Animation animation, Size screenSize) {
    final scale = .55 * .2;
    return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
            curve: Interval(.7, 1, curve: Curves.easeIn), parent: animation)),
        child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0, -1.4), end: Offset.zero)
                .animate(animation),
            child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.vertical,
                axisAlignment: -1,
                child: Center(
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.network(_urlRoad,
                            width: double.infinity,
                            height: screenSize.height * scale - 5,
                            fit: BoxFit.fitHeight))))));
  }
}

class HeroCardDemo extends StatelessWidget {
  static const _city = CityData(
      name: 'Osaka',
      title: 'Osaka, France',
      description:
          'Get ready to explore the city of love filled with romantic scenery and experiences.',
      information:
          'Paris, located along the Seine River, in the north-central part of France. For centuries, Paris has been one of the world’s most important and attractive cities.',
      color: Color(0xfffdeed5),
      );

  const HeroCardDemo();

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          brightness: Brightness.light,
      ),
      body: Center(
          child: GestureDetector(
              onTap: () => (context) {
                    Navigator.push(context,
                        WhitePageRoute(enterPage: CityDetailsPage(_city)));
                  }(context),
              child: Container(
                  constraints: BoxConstraints(
                      minHeight: 290,
                      minWidth: 250,
                      maxHeight: MediaQuery.of(context).size.height * .43,
                      maxWidth: 300),
                  child: Hero(
                      tag: '${_city.name}-hero',
                      child: CityScenery(city: _city))))));
}


class ParallaxTravelCardsHero extends StatelessWidget {
  const ParallaxTravelCardsHero();

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Hero Travel Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light),
      home: HeroCardDemo());
}

///Takes a x,y or z rotation, in degrees, and rotates. Good for spins & 3d flip effects
class Rotation3d extends StatelessWidget {
  static const double degrees2Radians = pi / 180;

  final Widget child;
  final double rotationX;
  final double rotationY;
  final double rotationZ;

  const Rotation3d(
      {@required this.child,
      this.rotationX = 0,
      this.rotationY = 0,
      this.rotationZ = 0});

  @override
  Widget build(BuildContext context) => Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(rotationX * degrees2Radians)
        ..rotateY(rotationY * degrees2Radians)
        ..rotateZ(rotationZ * degrees2Radians),
      child: child);
}

class Styles {
  static const double hzScreenPadding = 18.0;
  static const double cardBorderRadius = 10.0;

  static final TextStyle baseTitle = TextStyle(
    fontFamily: 'Trajan Pro',
  );
  static final TextStyle baseBody = TextStyle(
    fontFamily: 'OpenSans',
  );

  static final TextStyle appHeader =
      baseTitle.copyWith(color: Color(0xFF473344), fontSize: 48, height: 1.2);

  static final TextStyle cardTitle =
      baseTitle.copyWith(height: 1, color: Color(0xFF473344), fontSize: 25);
  static final TextStyle cardSubtitle =
      baseBody.copyWith(color: Color(0xFF666666), height: 1.8, fontSize: 12);
  static final TextStyle cardAction = baseBody.copyWith(
      color: Color(0xFF60435B),
      fontSize: 12,
      height: 1,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1);
}

///Create a transition that fades in the new view, while fading out a white background
class WhitePageRoute extends PageRouteBuilder {
  final Widget enterPage;

  WhitePageRoute({this.enterPage})
      : super(
            transitionDuration: Duration(milliseconds: 1700),
            pageBuilder: (context, animation, secondaryAnimation) => enterPage,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    Stack(children: <Widget>[
                      FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                              CurvedAnimation(
                                  curve: Interval(0, .2), parent: animation)),
                          child: Container(color: Colors.white)),
                      FadeTransition(
                          opacity: Tween<double>(begin: 0, end: 1).animate(
                              CurvedAnimation(
                                  curve: Interval(.7, 1), parent: animation)),
                          child: child)
                    ]));
}

class _CityImage extends StatelessWidget {
  final Size size;
  final CityData city;

  const _CityImage({this.size, this.city});

  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Container(
            width: size.width,
            height: size.height,
            child: Stack(alignment: Alignment.bottomCenter, children: <Widget>[
              Image.network(_urlParisBack),
              Image.network(_urlParisMiddle),
              Image.network(_urlParisFront),
            ])),
        Image.network(_urlGround, width: size.width),
      ]);
}

class _Clouds extends StatefulWidget {
  final double animationValue;

  const _Clouds({this.animationValue = 0.5});

  @override
  _CloudsState createState() => _CloudsState();
}

class _CloudsState extends State<_Clouds> with SingleTickerProviderStateMixin {
  static final Map<String, _CloudsState> _cachedState = {};
  Ticker _ticker;
  double _animationValue;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dxPosition = Tween<double>(
            begin: -screenSize.width * .1, end: screenSize.width * 1.8)
        .transform(_animationValue);

    return Stack(children: <Widget>[
      Positioned(
          top: screenSize.height * .065,
          left: dxPosition - (screenSize.width * 0.65),
          child: Image.network(_urlCloudLarge, width: screenSize.width * .2)),
      Positioned(
          top: screenSize.height * .12,
          left: dxPosition * .5,
          child: Image.network(_urlCloudSmal, width: screenSize.width * .15)),
    ]);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Restore old state from the static cache, workaround because Hero causes our widget to lose state
    final prevState = _cachedState[widget.key.toString()];
    if (prevState != null) {
      _animationValue = prevState._animationValue;
    } else {
      _animationValue = widget.animationValue;
    }
    //Replace cached state with ourselves
    _cachedState[widget.key.toString()] = this;
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration d) {
    final speed = .0003;
    setState(() {
      if (_animationValue <= 1) {
        _animationValue += speed;
      } else {
        _animationValue = 0;
      }
    });
  }
}

class _Leaf extends StatelessWidget {
  final double animationValue;
  final double rotationScale;
  final Function getCurvePath;
  final Curve curve;

  const _Leaf(
      {@required this.animationValue,
      @required this.getCurvePath,
      this.curve = Curves.linear,
      this.rotationScale = 1});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final dxPosition = Tween<double>(begin: -10, end: screenSize.width + 10)
        .transform(Interval(0, .9, curve: curve).transform(animationValue));
    final dyPosition =
        Tween<double>(begin: 0, end: pi * 2).transform(animationValue);
    final rotation = Tween<double>(begin: 0, end: 360)
        .transform(Curves.easeOutSine.transform(animationValue));

    return Positioned(
        child: Rotation3d(
            rotationY: rotation * rotationScale,
            child: Image.network(_urlBlowingLeaf,
                width: screenSize.width * .015 + Random().nextDouble() * .01)),
        bottom: getCurvePath(dyPosition),
        left: dxPosition);
  }
}

class _Leaves extends StatefulWidget {
  const _Leaves();

  @override
  _LeavesState createState() => _LeavesState();
}

class _LeavesState extends State<_Leaves> with SingleTickerProviderStateMixin {
  static final Map<String, _LeavesState> _cachedState = {};

  Ticker _ticker;
  double _animationValue;

  @override
  Widget build(BuildContext context) => Stack(children: <Widget>[
        _Leaf(
            animationValue: _animationValue,
            rotationScale: 1.5,
            curve: Curves.easeInOutSine,
            getCurvePath: (double screenPosition) =>
                sin(screenPosition) * 15 + 200),
        _Leaf(
            animationValue: _animationValue,
            rotationScale: 1.7,
            curve: Curves.linearToEaseOut,
            getCurvePath: (double screenPosition) =>
                -cos(screenPosition) * 30 + 130),
        _Leaf(
            animationValue: _animationValue,
            rotationScale: 1.2,
            curve: Curves.ease,
            getCurvePath: (double screenPosition) =>
                atan(screenPosition) * 10 + 150),
      ]);

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //Restore old state from the static cache, workaround because Hero causes our widget to lose state
    final prevState = _cachedState[widget.key.toString()];
    if (prevState != null) {
      _animationValue = prevState._animationValue;
    } else {
      _animationValue = 0;
    }
    //Replace cached state with ourselves
    _cachedState[widget.key.toString()] = this;

    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration d) {
    final speed = .001;
    setState(() {
      if (_animationValue + speed < 1) {
        _animationValue += speed;
      } else {
        _animationValue = 0;
      }
    });
  }
}

class _Trees extends StatelessWidget {
  const _Trees();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Stack(children: <Widget>[
      Positioned(
          bottom: screenSize.height * .07,
          right: screenSize.width * .2,
          child: _getTreeAsset(screenSize, false)),
      Positioned(
          bottom: screenSize.height * .07,
          left: screenSize.width * .2,
          child: _getTreeAsset(screenSize, false)),
      Positioned(
          bottom: screenSize.height * .01,
          right: screenSize.width * .1,
          child: _getTreeAsset(screenSize, true)),
      Positioned(
          bottom: screenSize.height * .01,
          left: screenSize.width * .1,
          child: _getTreeAsset(screenSize, true)),
    ]);
  }

  Widget _getTreeAsset(Size screenSize, bool isFront) {
    final sizeProportion = isFront ? .08 : .05;
    return Image.network(_urlTree, width: screenSize.width * sizeProportion);
  }
}
