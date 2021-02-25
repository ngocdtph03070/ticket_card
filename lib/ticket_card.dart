import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

/// 用于显示票式卡片的组件
class TicketCard extends StatelessWidget {
  TicketCard({
    this.lineFromTop = 0,
    this.lineRadius = 10,
    this.lineColor,
    this.child,
    this.decoration,
  });

  /// 分割线距离顶部的高度
  final double lineFromTop;

  /// 分隔线两边的圆角半径
  final double lineRadius;

  final Widget child;

  /// 票式卡片的装饰器
  final TicketDecoration decoration;

  /// 分割线颜色
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    SemiCircleClipper clipper = SemiCircleClipper(
      radius: lineRadius,
      fromTop: lineFromTop,
    );
    return CustomPaint(
      child: ClipPath(
        clipper: clipper,
        child: child ?? SizedBox(),
      ),
      foregroundPainter: SeparatorPainter(
          fromTop: lineFromTop, radius: lineRadius, color: lineColor),
      painter: ShadowPainter(clipper: clipper, decoration: decoration),
    );
  }
}

/// 半圆剪切
class SemiCircleClipper extends CustomClipper<Path> {
  SemiCircleClipper({
    this.fromTop,
    this.radius,
  });

  /// 距顶部的距离
  final double fromTop;

  /// 剪切的半圆半径
  final double radius;

  @override
  Path getClip(Size size) {
    var path = Path();
    path
      ..moveTo(0, 20)
      ..lineTo(0, max(fromTop - radius, 0))
      ..arcToPoint(Offset(radius, fromTop),
          clockwise: true, radius: Radius.circular(radius))
      ..arcToPoint(Offset(0, fromTop + radius),
          clockwise: true, radius: Radius.circular(radius))
      ..lineTo(0, size.height - radius)
      ..cubicTo(0, size.height - radius, 0, size.height, radius, size.height)
      ..lineTo(size.width - radius, size.height)
      ..cubicTo(size.width - radius, size.height, size.width, size.height,
          size.width, size.height - radius)
      ..lineTo(size.width, fromTop + radius)
      ..arcToPoint(Offset(size.width - radius, fromTop),
          clockwise: true, radius: Radius.circular(radius))
      ..arcToPoint(Offset(size.width, max(fromTop - radius, 0)),
          radius: Radius.circular(radius))
      ..lineTo(size.width, radius)
      ..cubicTo(size.width, radius, size.width, 0, size.width - radius, 0)
      ..lineTo(20, 0)
      ..cubicTo(radius, 0, 0, 0, 0, radius)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => oldClipper != this;
}

/// 绘制背景阴影
class ShadowPainter extends CustomPainter {
  ShadowPainter({
    this.clipper,
    TicketDecoration decoration,
  }) : _decoration = decoration ?? TicketDecoration();

  final CustomClipper<Path> clipper;

  final TicketDecoration _decoration;

  TicketBorder get _border => _decoration.border;

  @override
  void paint(Canvas canvas, Size size) {
    if (_border != null) {
      if (_border.style == TicketBorderStyle.none) return;
      Paint paint = Paint()
        ..color = _border.color ?? Colors.black
        ..strokeWidth = _border.width ?? 0.5
        ..style = PaintingStyle.stroke;
      Path path = clipper.getClip(size);

      switch (_border.style) {
        case TicketBorderStyle.none:
          return;
        case TicketBorderStyle.solid:
          break;
        case TicketBorderStyle.dotted:
          path = dashPath(path,
              dashArray: CircularIntervalList<double>(<double>[5, 5]));
          break;
      }

      canvas.drawPath(path, paint);
    }
    // 绘制阴影
    _decoration.shadow.forEach((e) {
      canvas.drawShadow(clipper.getClip(size), e.color, e.elevation ?? 0, true);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// 绘制票式卡片虚线
class SeparatorPainter extends CustomPainter {
  SeparatorPainter({
    this.fromTop,
    this.radius,
    this.color,
  });

  final double radius;

  ///距离顶部的高度
  final double fromTop;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (fromTop == 0) return;
    Paint paint = Paint()
      ..color = color ?? Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    Path path = Path()
      ..moveTo(radius + 5, fromTop)
      ..lineTo(size.width - radius - 5, fromTop);
    // 绘制虚线
    canvas.drawPath(
        dashPath(path, dashArray: CircularIntervalList<double>(<double>[5, 5])),
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// 票式卡片的阴影类
class TicketShadow {
  TicketShadow({
    this.color,
    this.elevation,
  });

  /// 阴影颜色
  final Color color;

  /// 阴影的高程
  final double elevation;
}

/// 票式卡片border类型
enum TicketBorderStyle { none, solid, dotted }

class TicketBorder {
  TicketBorder({
    this.color,
    this.width,
    this.style,
  });
  final Color color;
  final double width;
  final TicketBorderStyle style;
}

class TicketDecoration {
  TicketDecoration({
    this.shadow = const [],
    this.border,
  });

  /// 卡片背景阴影
  final List<TicketShadow> shadow;

  /// 卡片的边框
  final TicketBorder border;
}
