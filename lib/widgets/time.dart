import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class Time extends StatefulWidget {
  const Time({super.key});

  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  String _timeString = "";
  String _dateString = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);
    final String formattedDate = DateFormat('EEEE, MMMM d, y').format(now);
    setState(() {
      _timeString = formattedTime;
      _dateString = formattedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 80,
            width: 80,
            child: Image.asset("assets/images/logo.png")),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _dateString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timeString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

