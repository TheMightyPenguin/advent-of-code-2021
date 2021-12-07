import 'dart:convert';
import 'dart:io';

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  Point.fromString(String x, String y)
      : x = int.parse(x),
        y = int.parse(y);

  String toStringCoordinate() {
    return "$x,$y";
  }

  @override
  String toString() {
    return toStringCoordinate();
  }

  Point moveTowards(Point point) {
    var newX = moveNumberTowards(x, point.x);
    var newY = moveNumberTowards(y, point.y);
    return Point(newX, newY);
  }
}

int moveNumberTowards(int start, int end, [int moveBy = 1]) {
  if (start == end) {
    return start;
  }
  return start + (start < end ? moveBy : (moveBy * -1));
}

class Line {
  Point start;
  Point end;

  Line(this.start, this.end);

  void walkLine(Function(Point p) cb) {
    if (start.x == end.x) {
      var y = start.y;
      while (y != end.y) {
        var point = Point(start.x, y);
        cb(point);
        y += y < end.y ? 1 : -1;
      }
      cb(end);
    } else if (start.y == end.y) {
      var x = start.x;
      while (x != end.x) {
        var point = Point(x, start.y);
        cb(point);
        x += x < end.x ? 1 : -1;
      }
      cb(end);
    } else {
      var point = Point(start.x, start.y);
      while (point.x != end.x && point.y != end.y) {
        cb(point);
        point = point.moveTowards(end);
      }
      cb(point);
    }
  }

  @override
  String toString() {
    return "${start.x},${start.y} -> ${end.x},${end.y}";
  }
}

// parses "x,y" string
Point parseCoordinate(String coordinate) {
  var splitCoordinate = coordinate.split(',');
  return Point.fromString(splitCoordinate.first, splitCoordinate.last);
}

List<Line> parseInput(List<String> lines) {
  List<Line> output = [];
  for (final line in lines) {
    var startAndEnd = line.split(' -> ');
    var start = parseCoordinate(startAndEnd.first);
    var end = parseCoordinate(startAndEnd.last);
    output.add(Line(start, end));
  }
  return output;
}

bool isStraightLine(Line line) {
  return line.start.x == line.end.x || line.start.y == line.end.y;
}

void debugLines(List<Line> lines) {
  for (final line in lines) {
    stdout.writeln(line);
  }
}

void main(List<String> arguments) async {
  final inputPath = 'input.txt';

  final inputLines = await utf8.decoder
      .bind(File(inputPath).openRead())
      .transform(const LineSplitter())
      .where((line) => line.isNotEmpty)
      .toList();

  var lines = parseInput(inputLines).toList();

  Map<String, int> sparseGrid = {};

  for (final line in lines) {
    line.walkLine((point) {
      var coordinate = point.toStringCoordinate();
      sparseGrid[coordinate] = (sparseGrid[coordinate] ?? 0) + 1;
    });
  }

  var overlappingPoints =
      sparseGrid.values.where((value) => value >= 2).toList().length;

  stdout.writeln(sparseGrid);
  debugLines(lines);
  stdout.writeln(overlappingPoints);
}
