import 'dart:ui';

import 'package:assign_erp/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

// Neumorphism is a design style that combines minimalism with three-dimensionality, and is often used in graphical user interfaces (GUIs)
// We can apply it on any  widget

extension Neumorphism on Widget {
  addNeumorphism({
    double borderRadius = 10.0,
    Offset offset = const Offset(5, 5),
    double blurRadius = 10,
    Color? bgColor,
    Color topShadowColor = kGrayColor, //Colors.white60,
    Color bottomShadowColor = const Color(0x26234395),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            offset: offset,
            blurRadius: blurRadius,
            color: bottomShadowColor,
          ),
          BoxShadow(
            offset: Offset(-offset.dx, -offset.dx),
            blurRadius: blurRadius,
            color: topShadowColor,
          ),
        ],
      ),
      child: this,
    );
  }

  fluidGlassMorphism({
    double blurRadius = 10,
    double blurRadius2 = 20,
    double borderRadius = 25,
    Color? bgColor,
    VoidCallback? onTap,
    bool fadeBg = true,
    double? width,
    double? height,
  }) {
    final bColor = (bgColor ?? Colors.blue);
    final cardBgColor = fadeBg ? bColor.withAlpha((0.8 * 255).toInt()) : bColor;
    return AnimatedContainer(
      width: width,
      height: height,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha((0.05 * 255).toInt()),
            blurRadius: blurRadius,
            offset: Offset(-6, -6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha((0.2 * 255).toInt()),
            blurRadius: blurRadius2,
            offset: Offset(6, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.08 * 255).toInt()),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withAlpha((0.2 * 255).toInt()),
                width: 1.5,
              ),
            ),
            child: this,
          ),
        ),
      ),
    );
  }
}
