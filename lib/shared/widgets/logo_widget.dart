import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  
  const LogoWidget({super.key, this.size = 200});  

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),  
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            
            child: Icon(
              Icons.inventory_2,
              color: AppColors.primary,
              size: size * 0.5,
            ),
          );
        },
      ),
    );
  }
}