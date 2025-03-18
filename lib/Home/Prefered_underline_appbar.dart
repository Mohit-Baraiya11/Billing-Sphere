import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Prefered_underline_appbar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height, // Use preferredSize height
      color: Colors.grey.withOpacity(0.5),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(1.0); // Correct height
}
