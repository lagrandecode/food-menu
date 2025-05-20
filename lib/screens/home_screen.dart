import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/time.dart';
import 'package:marquee/marquee.dart';
import '../providers/marquee_provider.dart';
import '../providers/food_items_provider.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _newItemController = TextEditingController();
  final TextEditingController _marqueeController = TextEditingController();

  Timer? _timer;
  String menuText = 'Breakfast Menu';

  @override
  void initState() {
    super.initState();
    _updateMenuText();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateMenuText();
    });
  }

  void _updateMenuText() {
    final now = DateTime.now();
    final isBreakfast = now.hour >= 5 && (now.hour < 11);
    final newMenuText = isBreakfast ? 'Breakfast Menu' : 'Lunch Menu';
    if (menuText != newMenuText) {
      setState(() {
        menuText = newMenuText;
      });
    }
  }

  @override
  void dispose() {
    _newItemController.dispose();
    _marqueeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final foodItemsProvider = Provider.of<FoodItemsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'editMarquee',
            onPressed: _showEditMarqueeDialog,
            backgroundColor: Colors.blue,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'addItem',
            onPressed: _showAddItemDialog,
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 55,
              color: Colors.grey[900],
              child: Consumer<MarqueeProvider>(
                builder: (context, marqueeProvider, child) => Marquee(
                  text: marqueeProvider.marqueeText,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 40,
                    fontWeight: FontWeight.bold,
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 20.0,
                  velocity: 50.0,
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 1),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
            ),
            Expanded(
              child: isMobile
                  ? _buildMobileLayout(foodItemsProvider)
                  : _buildDesktopLayout(foodItemsProvider, screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(FoodItemsProvider foodItemsProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWeatherWidget(),
          _buildAdvertisementsWidget(),
          _buildEventsWidget(),
          _buildMenuContent(foodItemsProvider),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(FoodItemsProvider foodItemsProvider, double screenWidth) {
    return Row(
      children: [
        // Left Sidebar (1/3 width)
        Container(
          width: screenWidth / 3,
          color: Colors.grey[100],
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildWeatherWidget(),
                _buildAdvertisementsWidget(),
                _buildEventsWidget(),
              ],
            ),
          ),
        ),
        // Main Content (2/3 width)
        Expanded(
          child: _buildMenuContent(foodItemsProvider),
        ),
      ],
    );
  }

  Widget _buildWeatherWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weather',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, size: 40, color: Colors.orange),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '25°C',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sunny',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAdvertisementsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advertisements',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: PageView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ads.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ads.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 400,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FlutterCarousel(
              options: CarouselOptions(
                height: 400,
                viewportFraction: 1.0,
                enableInfiniteScroll: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: false,
              ),
              items: [
                _buildEventCard(
                  'Special Event 1',
                  'Join us for an amazing experience!',
                  'assets/images/img1.JPG',
                ),
                _buildEventCard(
                  'Special Event 2',
                  'Don\'t miss out on this exclusive event!',
                  'assets/images/img2.JPG',
                ),
                _buildEventCard(
                  'Special Event 3',
                  'Experience something extraordinary!',
                  'assets/images/img3.JPG',
                ),
                _buildEventCard(
                  'Special Event 5',
                  'Join us for a memorable evening!',
                  'assets/images/logo.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String description, String imagePath) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(FoodItemsProvider foodItemsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Time(),
              const SizedBox(height: 24),
              Text(
                menuText,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available Items',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.grey[700],
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: foodItemsProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foodItemsProvider.items.length,
                  onReorder: foodItemsProvider.reorderItems,
                  itemBuilder: (context, index) {
                    final item = foodItemsProvider.items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      onDismissed: (direction) {
                        foodItemsProvider.deleteItem(item.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.name} removed from menu',
                              style: GoogleFonts.spaceGrotesk(),
                            ),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () => foodItemsProvider.toggleAvailability(item),
                        child: Container(
                          key: ValueKey(item.id),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: Colors.yellow),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: item.isAvailable ? Colors.black : Colors.grey[300],
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                    decoration: item.isAvailable ? null : TextDecoration.lineThrough,
                                    decorationColor: Colors.red,
                                    decorationThickness: 2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.isAvailable ? 'Available' : 'Not Available',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: item.isAvailable ? Colors.green : Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.drag_handle, color: Colors.transparent),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Add New Item',
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
        ),
        content: TextField(
          controller: _newItemController,
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter item name',
            hintStyle: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _newItemController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_newItemController.text.isNotEmpty) {
                Provider.of<FoodItemsProvider>(context, listen: false)
                    .addItem(_newItemController.text);
                _newItemController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: GoogleFonts.spaceGrotesk(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditMarqueeDialog() {
    _marqueeController.text = Provider.of<MarqueeProvider>(context, listen: false).marqueeText;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit Marquee Text',
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
        ),
        content: TextField(
          controller: _marqueeController,
          style: GoogleFonts.spaceGrotesk(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter marquee text',
            hintStyle: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _marqueeController.clear();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_marqueeController.text.isNotEmpty) {
                Provider.of<MarqueeProvider>(context, listen: false)
                    .updateMarqueeText(_marqueeController.text);
                _marqueeController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.spaceGrotesk(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}


