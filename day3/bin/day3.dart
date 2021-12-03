import 'dart:convert';
import 'dart:io';

typedef GetBitFn = String Function(int zeros, int ones);
typedef Filter = bool Function();

int getValueFromCriteria(List<List<String>> binaryMatrix, GetBitFn getBit) {
  var columns = binaryMatrix.first.length;
  var rows = binaryMatrix.length;
  var binary = '';
  List<int> indexes = List<int>.generate(rows, (i) => i);

  for (var column = 0; column < columns; column++) {
    var zeros = 0;
    var ones = 0;

    for (var currentRowIndex = 0;
        currentRowIndex < indexes.length;
        currentRowIndex++) {
      var row = indexes[currentRowIndex];
      if (binaryMatrix[row][column] == '0') {
        zeros++;
      } else {
        ones++;
      }
    }

    var bitToKeep = getBit(zeros, ones);

    List<int> newIndexes = [];
    for (var currentRowIndex = 0;
        currentRowIndex < indexes.length;
        currentRowIndex++) {
      var row = indexes[currentRowIndex];
      if (bitToKeep == binaryMatrix[row][column]) {
        newIndexes.add(row);
      }
    }

    indexes = newIndexes;

    if (indexes.length == 1) {
      break;
    }
  }

  for (var column = 0; column < columns; column++) {
    var row = indexes.first;
    binary += binaryMatrix[row][column];
  }

  return int.parse(binary, radix: 2);
}

void main(List<String> arguments) async {
  final inputPath = 'input.txt';

  final lines = utf8.decoder
      .bind(File(inputPath).openRead())
      .transform(const LineSplitter());

  List<List<String>> binaryMatrix = [];

  await for (final line in lines) {
    var numbersInLine = line.split('');
    binaryMatrix.add(numbersInLine);
  }

  var gamma = getValueFromCriteria(binaryMatrix, (zeros, ones) {
    if (zeros == ones) {
      return '1';
    } else if (zeros > ones) {
      return '0';
    } else {
      return '1';
    }
  });
  var epsilon = getValueFromCriteria(binaryMatrix, (zeros, ones) {
    if (zeros == ones) {
      return '0';
    } else if (zeros > ones) {
      return '1';
    } else {
      return '0';
    }
  });

  stdout.writeln(gamma);
  stdout.writeln(epsilon);

  stdout.writeln(gamma * epsilon);
}
