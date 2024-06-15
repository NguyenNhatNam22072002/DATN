import 'package:flutter/material.dart';
import '../../../constants/color.dart';

class FlashingFunds extends StatefulWidget {
  final double earnings;

  const FlashingFunds({Key? key, required this.earnings}) : super(key: key);

  @override
  State<FlashingFunds> createState() => _FlashingFundsState();
}

class _FlashingFundsState extends State<FlashingFunds>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _colorAnimation =
        ColorTween(begin: Colors.white, end: primaryColor).animate(_controller);

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Chip(
          label: FittedBox(
            child: Text(
              'Available Funds: \$${widget.earnings.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          avatar: const Icon(Icons.monetization_on),
          backgroundColor: _colorAnimation.value,
        );
      },
    );
  }
}
