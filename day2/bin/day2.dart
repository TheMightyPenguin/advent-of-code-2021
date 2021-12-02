import 'dart:convert';
import 'dart:io';
import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  final inputPath = 'input.txt';

  final lines = utf8.decoder
      .bind(File(inputPath).openRead())
      .transform(const LineSplitter());

  List<Tuple2<String, int>> instructions = [];

  await for (final line in lines) {
    var split = line.split(' ');
    instructions.add(Tuple2(split[0], int.parse(split[1], radix: 10)));
    stdout.writeln(instructions.last);
  }

  var depth = 0;
  var horizontalPosition = 0;
  var aim = 0;

  for (final instruction in instructions) {
    switch (instruction.item1) {
      case 'forward':
        {
          horizontalPosition += instruction.item2;
          depth += aim * instruction.item2;
        }
        break;
      case 'up':
        {
          // depth -= instruction.item2;
          aim -= instruction.item2;
        }
        break;
      case 'down':
        {
          // depth += instruction.item2;
          aim += instruction.item2;
        }
        break;
      default:
        {
          stdout.writeln('UNKNOWN INSTRUCTION ${instruction.item1}');
        }
        break;
    }
  }

  stdout.writeln(depth * horizontalPosition);
}
