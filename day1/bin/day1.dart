import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

int getIncreasingMeasures(List<int> measures) {
  int? prevMeasure;
  var increasingMeasures = 0;

  for (final measure in measures) {
    if (prevMeasure != null && measure > prevMeasure) {
      increasingMeasures++;
    }
    prevMeasure = measure;
  }

  return increasingMeasures;
}

void main(List<String> arguments) async {
  final inputPath = 'input.txt';

  final lines = utf8.decoder
      .bind(File(inputPath).openRead())
      .transform(const LineSplitter());

  List<int> measures = [];
  List<int> groupedMeasures = [];

  await for (final line in lines) {
    measures.add(int.parse(line, radix: 10));
  }

  for (var index = 0; index + 2 < measures.length; index++) {
    groupedMeasures
        .add(measures[index] + measures[index + 1] + measures[index + 2]);
  }

  var increasingMeasures = getIncreasingMeasures(groupedMeasures);
  stdout.writeln(increasingMeasures);
}
