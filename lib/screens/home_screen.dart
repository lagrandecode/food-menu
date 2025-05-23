import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/time.dart';
import 'package:marquee/marquee.dart';
import '../providers/marquee_provider.dart';
import '../providers/food_items_provider.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'dart:async';
import '../providers/weather_provider.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isCompactMobile = screenWidth <= 599;
    final showSidebar = screenWidth >= 890 && screenHeight >= 728;

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
              height: isCompactMobile ? 40 : 55,
              color: Colors.grey[900],
              child: Consumer<MarqueeProvider>(
                builder: (context, marqueeProvider, child) => Marquee(
                  text: marqueeProvider.marqueeText,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: isCompactMobile ? 18 : (isMobile ? 24 : 40),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactMobile = screenWidth <= 599;

    return Column(
      children: [
        Expanded(
          child: _buildMenuContent(foodItemsProvider, isCompactMobile),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(FoodItemsProvider foodItemsProvider, double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;
    final showSidebar = screenWidth >= 890 && screenHeight >= 728;
    final isCompactMobile = screenWidth <= 599;

    return Row(
      children: [
        if (showSidebar)
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
        Expanded(
          child: _buildMenuContent(foodItemsProvider, isCompactMobile),
        ),
      ],
    );
  }

  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherWidget() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        if (weatherProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (weatherProvider.error != null) {
          return Center(
            child: Text(
              'Error loading weather: ${weatherProvider.error}',
              style: GoogleFonts.spaceGrotesk(color: Colors.red),
            ),
          );
        }

        final weatherData = weatherProvider.weatherData;
        if (weatherData == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weather',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    weatherData.isDaytime ? Icons.wb_sunny : Icons.nightlight_round,
                    color: weatherData.isDaytime ? Colors.orange : Colors.blueGrey,
                  ),
                ],
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getWeatherIcon(weatherData.condition),
                          size: 50,
                          color: _getWeatherIconColor(weatherData.condition),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${weatherData.temperature.toStringAsFixed(1)}°C',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              weatherData.description,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeatherInfo('Humidity', '${weatherData.humidity}%', Icons.water_drop),
                        _buildWeatherInfo('Wind', '${weatherData.windSpeed} km/h', Icons.air),
                        _buildWeatherInfo('Clouds', '${weatherData.cloudCover}%', Icons.cloud),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildMenuContent(FoodItemsProvider foodItemsProvider, bool isCompactMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCompactMobile) ...[
                const Time(),
                const SizedBox(height: 24),
              ],
              Text(
                menuText,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontSize: isCompactMobile ? 24 : 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available Items',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.grey[700],
                  fontSize: isCompactMobile ? 14 : 18,
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
                                    fontSize: isCompactMobile ? 20 : 30,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isCompactMobile ? 8 : 12,
                                      vertical: isCompactMobile ? 4 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.isAvailable ? 'Available' : 'Not Available',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: item.isAvailable ? Colors.green : Colors.red,
                                        fontSize: isCompactMobile ? 14 : 20,
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

  IconData _getWeatherIcon(String condition) {
    switch (condition.toUpperCase()) {
      case 'CLEAR':
        return Icons.wb_sunny;
      case 'PARTLY_CLOUDY':
        return Icons.cloud;
      case 'CLOUDY':
        return Icons.cloud_queue;
      case 'RAIN':
        return Icons.beach_access;
      case 'SNOW':
        return Icons.ac_unit;
      case 'THUNDERSTORM':
        return Icons.flash_on;
      case 'FOG':
        return Icons.cloud;
      case 'WINDY':
        return Icons.air;
      case 'HAIL':
        return Icons.grain;
      case 'SLEET':
        return Icons.grain;
      case 'DUST':
        return Icons.blur_on;
      case 'SMOKE':
        return Icons.cloud;
      case 'HAZE':
        return Icons.blur_on;
      case 'MIST':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _getWeatherIconColor(String condition) {
    switch (condition.toUpperCase()) {
      case 'CLEAR':
        return Colors.orange;
      case 'PARTLY_CLOUDY':
        return Colors.blueGrey;
      case 'CLOUDY':
        return Colors.grey;
      case 'RAIN':
        return Colors.blue;
      case 'SNOW':
        return Colors.lightBlue;
      case 'THUNDERSTORM':
        return Colors.deepPurple;
      case 'FOG':
        return Colors.grey;
      case 'WINDY':
        return Colors.blueGrey;
      case 'HAIL':
        return Colors.blueGrey;
      case 'SLEET':
        return Colors.blueGrey;
      case 'DUST':
        return Colors.brown;
      case 'SMOKE':
        return Colors.grey;
      case 'HAZE':
        return Colors.grey;
      case 'MIST':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}


