import 'package:flutter/material.dart';

class BottomNavbarSaveButton extends StatelessWidget {
  final String leftButtonText;
  final String rightButtonText;
  final Color leftButtonColor;
  final Color rightButtonColor;
  final VoidCallback onLeftButtonPressed;
  final VoidCallback onRightButtonPressed;

  const BottomNavbarSaveButton({
    Key? key,
    required this.leftButtonText,
    required this.rightButtonText,
    required this.leftButtonColor,
    required this.rightButtonColor,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 0.5,
            color: Color(0xFFDAE7F2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: leftButtonColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: onLeftButtonPressed,
              child: Text(leftButtonText),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: rightButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: onRightButtonPressed,
              child: Text(rightButtonText),
            ),
          ),
        ],
      ),
    );
  }
}
