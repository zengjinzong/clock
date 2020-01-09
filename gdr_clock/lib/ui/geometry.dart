import 'dart:ui';

import 'package:vector_math/vector_math_64.dart' show Vector2, Vector3;

extension ExtendedOffset on Offset {
  Offset operator +(Size size) => Offset(dx + size.width, dy + size.height);

  /// This exists because of a web compiler error: https://github.com/dart-lang/sdk/issues/39938#issue-542985784
  ///
  /// See [ExtendedOffset.+].
  Offset plus(Size size) => Offset(dx + size.width, dy + size.height);

  /// Returns a [Vector3] respecting only two dimensions,
  /// i.e. z is always 0.
  Vector3 get vector3 => Vector3(dx, dy, 0);
}

extension ExtendedSize on Size {
  Size get onlyWidth => Size(width, 0);

  Size get onlyHeight => Size(0, height);

  Offset get offset => Offset(width, height);
}

/// Line with functionality tailored to the needs of this clock challenge entry.
class Line1d {
  final double start, end;

  const Line1d({this.start, this.end});

  factory Line1d.fromSE({double start, double extent}) => Line1d(start: start, end: start + extent);

  factory Line1d.fromEE({double end, double extent}) => Line1d(start: end - extent, end: end);

  factory Line1d.fromSEI({double start, double end, double indent}) => Line1d(start: start + indent, end: end - indent);

  factory Line1d.fromCenter({double center, double extent}) => Line1d(start: center - extent / 2, end: center + extent / 2);

  double get extent => end - start;

  /// Takes [start] as either [dx] or [dy] based on what is not supplied to construct an offset.
  /// This means that [start] is the top of a line in one case and the left in the other.
  Offset startOffset({double dx, double dy}) {
    assert(dx == null || dy == null);

    if (dx == null) return Offset(start, dy);
    return Offset(dx, start);
  }

  /// Takes [start] as either [dx] or [dy] based on what is not supplied to construct an offset.
  /// This means that [end] is the bottom of a line in one case and the right in the other.
  Offset endOffset({double dx, double dy}) {
    assert(dx == null || dy == null);

    if (dx == null) return Offset(end, dy);
    return Offset(dx, end);
  }
}

extension ExtendedRect on Rect {
  Rect include(Offset offset) {
    return expandToInclude(Rect.fromCenter(center: offset, width: 0, height: 0));
  }
}

class Line2d {
  final Offset start, end;

  const Line2d({this.start, this.end});

  /// Positions the new [start]/[end] [startFactor]/[endFactor]
  /// away from [end]/[start].
  ///
  /// For example, the following code will remove the end half of the line:
  ///
  /// ```dart
  /// newLine = line.paddingStartEnd(0, 1 / 2);
  /// ```
  Line2d paddingStartEnd(double startFactor, double endFactor) => Line2d(start: end + (start - end) * startFactor, end: start + (end - start) * endFactor);

  Line2d padding(double factor) => paddingStartEnd(factor, factor);

  Line2d startPadding(double factor) => Line2d(start: start, end: start + (end - start) * factor);

  Line2d endPadding(double factor) => Line2d(start: end + (start - end) * factor, end: end);

  double get length => (end - start).distance;

  Offset get offset => end - start;

  Line2d shift(Offset offset) => Line2d(start: start + offset, end: end + offset);

  /// This returns one of the two normals to this
  /// line. It does not matter which one it is because
  /// this is only used in [pathWithWidth], which
  /// will extend in both directions anyway :)
  Vector2 get normal {
    return Vector2(-(end.dy - start.dy), end.dx - start.dx);
  }

  Path pathWithWidth(double width) {
    final normalVector = normal..normalize(), normalOffset = Offset(normalVector.x, normalVector.y);

    final s1 = start - normalOffset * width / 2, s2 = start + normalOffset * width / 2, e1 = end - normalOffset * width / 2, e2 = end + normalOffset * width / 2;

    return Path()..addPolygon([s1, s2, e1, e2], false);
  }
}
