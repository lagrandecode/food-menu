import 'package:flutter/material.dart';

class MarqueeProvider extends ChangeNotifier {
  String _marqueeText = "Caribbean Queen Jerk is the premier restaurant for delicious, authentic, and affordable Jamaican cuisine in the Greater Toronto Area. We are proud to serve you great food across five locations, including our special Caribbean buffet. Our leadership team has spent more than a decade working together to build a delicious menu and a positive customer experience. Our food is fresh and our smiles are free. Our doors open at 6:00 am to welcome hundreds of hungry clients for breakfast, and they don't close until everyone has enjoyed their tasty Caribbean lunches and dinners. We look forward to serving you soon.";

  String get marqueeText => _marqueeText;

  void updateMarqueeText(String newText) {
    _marqueeText = newText;
    notifyListeners();
  }
}

///////