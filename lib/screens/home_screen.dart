import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/time.dart';
import 'dart:async';
import 'package:marquee/marquee.dart';

class BreakfastItem {
  final String name;
  bool isAvailable;
  bool isManuallySet;

  BreakfastItem({
    required this.name, 
    this.isAvailable = true,
    this.isManuallySet = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<BreakfastItem> breakfastItems;
  Timer? _timer;
  final TextEditingController _newItemController = TextEditingController();
  final TextEditingController _marqueeController = TextEditingController();
  String marqueeText = "Caribbean Queen Jerk is the premier restaurant for delicious, authentic, and affordable Jamaican cuisine in the Greater Toronto Area. We are proud to serve you great food across five locations, including our special Caribbean buffet. Our leadership team has spent more than a decade working together to build a delicious menu and a positive customer experience. Our food is fresh and our smiles are free. Our doors open at 6:00 am to welcome hundreds of hungry clients for breakfast, and they don't close until everyone has enjoyed their tasty Caribbean lunches and dinners. We look forward to serving you soon.";

  @override
  void initState() {
    super.initState();
    breakfastItems = [
      BreakfastItem(name: 'Ackee and SaltFish'),
      BreakfastItem(name: 'Butterbean and Saltfish'),
      BreakfastItem(name: 'Cabbage and Saltfish'),
      BreakfastItem(name: 'Kidney'),
      BreakfastItem(name: 'Liver'),
      BreakfastItem(name: 'Salt Mackerel'),
      BreakfastItem(name: 'Curry Chicken'),
      BreakfastItem(name: 'Stew Chicken'),
      BreakfastItem(name: 'Vegetable Chunks'),
      BreakfastItem(name: 'Porridge'),
      BreakfastItem(name: 'Fritters'),
      BreakfastItem(name: 'Fried Dumpling'),
      BreakfastItem(name: 'Callaloo and Saltfish'),
    ];
    _startTimeCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _newItemController.dispose();
    _marqueeController.dispose();
    super.dispose();
  }

  void _startTimeCheck() {
    // Check time immediately
    _updateAvailabilityByTime();
    
    // Then check every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateAvailabilityByTime();
    });
  }

  void _updateAvailabilityByTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    
    setState(() {
      // Between 5 AM and 11 AM, items are available
      final shouldBeAvailable = currentHour >= 5 && currentHour < 11;
      
      // Update all items' availability except manually set ones
      for (var item in breakfastItems) {
        if (!item.isManuallySet) {
          item.isAvailable = shouldBeAvailable;
        }
      }
      
      // Sort items
      breakfastItems.sort((a, b) {
        if (a.isAvailable == b.isAvailable) return 0;
        return a.isAvailable ? -1 : 1;
      });
    });
  }

  void _toggleAvailability(int index) {
    setState(() {
      breakfastItems[index].isAvailable = !breakfastItems[index].isAvailable;
      breakfastItems[index].isManuallySet = true;  // Mark as manually set
      // Sort items: available items first, then unavailable items
      breakfastItems.sort((a, b) {
        if (a.isAvailable == b.isAvailable) return 0;
        return a.isAvailable ? -1 : 1;
      });
    });
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
                setState(() {
                  breakfastItems.add(
                    BreakfastItem(
                      name: _newItemController.text,
                      isAvailable: DateTime.now().hour >= 5 && DateTime.now().hour < 11,
                      isManuallySet: false,
                    ),
                  );
                  _newItemController.clear();
                });
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
    _marqueeController.text = marqueeText;
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.spaceGrotesk(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                marqueeText = _marqueeController.text;
              });
              Navigator.pop(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.spaceGrotesk(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 55,
              color: Colors.grey[900],
              child: Marquee(
                text: marqueeText,
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 40,
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Time(),
                  const SizedBox(height: 24),
                  Text(
                    'Breakfast Menu',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Available Items',
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: breakfastItems.length,
                itemBuilder: (context, index) {
                  final item = breakfastItems[index];
                  return Dismissible(
                    key: ValueKey(item.name),
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
                      setState(() {
                        breakfastItems.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.name} removed from menu',
                            style: GoogleFonts.spaceGrotesk(),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: () => _toggleAvailability(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.name,
                              style: GoogleFonts.spaceGrotesk(
                                color: item.isAvailable ? Colors.white : Colors.grey[400],
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                decoration: item.isAvailable ? null : TextDecoration.lineThrough,
                                decorationColor: Colors.red,
                                decorationThickness: 2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
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
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

