import 'package:flutter/material.dart';
import 'dart:math';
import '../models/card_item.dart';

class CardWidget extends StatefulWidget {
  final CardItem card;
  final VoidCallback onTap;
  final bool isNumberMode;

  const CardWidget({
    super.key,
    required this.card,
    required this.onTap,
    this.isNumberMode = false,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  final List<Color> pantoneBlues = [
    const Color(0xFF0038A8),
    const Color(0xFF0057B7),
    const Color(0xFF00AEEF),
    const Color(0xFF1974D2),
    const Color(0xFF1E90FF),
    const Color(0xFF4169E1),
    const Color(0xFF4682B4),
    const Color(0xFF6495ED),
    const Color(0xFF87CEEB),
    const Color(0xFF87CEFA),
  ];

  final Random _random = Random();
  Color? _pantoneColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.card.isFlipped
              ? (widget.isNumberMode && widget.card.content.isEmpty
                  ? Colors.grey[200]
                  : Colors.white)
              : (_pantoneColor ??= pantoneBlues[_random.nextInt(pantoneBlues.length)]),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.blueGrey, width: 2),
        ),
        child: Center(
          child: widget.card.isFlipped
              ? Text(
                  widget.card.content,
                  style: TextStyle(
                    fontSize: widget.isNumberMode ? 32 : 40,
                    fontWeight: widget.isNumberMode ? FontWeight.bold : FontWeight.normal,
                    color: Colors.black
                  ),
                )
              : const Text(''),
        ),
      ),
    );
  }
}
