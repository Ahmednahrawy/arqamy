import 'package:flutter/material.dart';

class TextBuilder extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final double? latterSpacing;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final double? height;
  final double? wordSpacing;
  final TextDecoration? textDecoration;
  final FontStyle? fontStyle;
  const TextBuilder({
    super.key,
    required this.text,
    this.fontSize,
    this.color,
    this.textOverflow,
    this.fontWeight,
    this.latterSpacing,
    this.maxLines,
    this.textAlign,
    this.height,
    this.wordSpacing,
    this.textDecoration,
    this.fontStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DefaultTextStyle.of(context).style.copyWith(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            letterSpacing: latterSpacing,
            height: height,
            wordSpacing: wordSpacing,
            decoration: textDecoration,
            fontStyle: fontStyle,
          ),
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: textAlign,
    );
  }
}
