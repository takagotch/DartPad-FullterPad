import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ShoesStorePage(),
        ),
      ),
    );
  }
}

const bottomBackgroundColor = Color(0xFFF1F2F7);

const brands = ['Nike', 'Adidas', 'Jordan', 'Puma', 'Reebok'];

const marginSide = 14.0;

const leftItemSeparator = const SizedBox(
  width: 30,
);

const marginCenter = EdgeInsets.symmetric(horizontal: 50, vertical: 15);

class Shoe {
  final String name;
  final String image;
  final double price;
  final Color color;

  const Shoe({
    this.name,
    this.image,
    this.price,
    this.color,
  });
}

const theOneShoe = Shoe(
  name: 'CLICK FOR DETAILS',
  price: 130.00,
  image: 'https://raw.githubusercontent.com/diegoveloper/'
      'flutter-samples/master/images/shoes/1.png',
  color: Color(0xFF5574b9),
);

class ShoesStorePage extends StatefulWidget {
  @override
  _ShoesStorePageState createState() => _ShoesStorePageState();
}

class _ShoesStorePageState extends State<ShoesStorePage> {
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discover',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.black,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brands.length,
              itemBuilder: (_, index) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: LeftItem(brands[index], index == 0, true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(marginSide),
            child: _buildHeader(),
          ),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LeftItem('New', false),
                          leftItemSeparator,
                          LeftItem('Featured', true),
                          leftItemSeparator,
                          LeftItem('Upcoming', false),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -10,
                  height: size.height * 0.50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 28.0,
                    ),
                    child: ShoeCard(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShoeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: ShoesStoreDetailPage(
              shoe: theOneShoe,
            ),
          ),
        ));
      },
      child: Stack(
        overflow: Overflow.visible,
        children: [
          Stack(
            children: [
              Hero(
                tag: 'hero_background',
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: marginCenter,
                  color: theOneShoe.color,
                  child: const SizedBox.expand(),
                ),
              ),
              Container(
                margin: marginCenter,
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          theOneShoe.name.split(' ').join('\n'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "\$${theOneShoe.price}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: Hero(
              tag: 'hero_image',
              child: Image.network(
                theOneShoe.image,
                height: size.width / 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShoesStoreDetailPage extends StatelessWidget {
  final Shoe shoe;

  const ShoesStoreDetailPage({Key key, this.shoe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -size.width / 2,
            right: -size.width / 3,
            width: size.width * 1.4,
            height: size.width * 1.4,
            child: Hero(
              tag: 'hero_background',
              child: Container(
                decoration: BoxDecoration(
                  color: shoe.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: kToolbarHeight + 20,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  shoe.name.split(' ').first,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: Material(
                      elevation: 10,
                      shape: CircleBorder(
                          side: BorderSide(
                        color: shoe.color,
                      )),
                      color: shoe.color,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Icon(Icons.favorite_border),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: size.height * 0.1),
              child: Hero(
                tag: 'hero_image',
                child: Image.network(
                  shoe.image,
                  height: MediaQuery.of(context).size.width / 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeftItem extends StatelessWidget {
  final bool selected;
  final bool large;
  final String text;

  const LeftItem(this.text, this.selected, [this.large = false]);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? Colors.black : Colors.grey[400],
        fontSize: large? 17 : 14,
      ),
    );
  }
}
