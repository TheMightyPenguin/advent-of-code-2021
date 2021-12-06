import 'dart:convert';
import 'dart:io';
import 'package:tuple/tuple.dart';

const gridSize = 5;

class BingoCell {
  final int value;
  bool marked = false;

  BingoCell(this.value);
}

typedef BingoCellGrid = List<List<BingoCell>>;

class BingoBoard {
  final BingoCellGrid grid;
  final Map<int, Tuple2<int, int>> valueToPosition = {};
  bool hasWon = false;

  BingoBoard(this.grid) {
    _buildValueToPositionMap();
  }

  void _buildValueToPositionMap() {
    for (var rowIndex = 0; rowIndex < grid.length; rowIndex++) {
      for (var colIndex = 0; colIndex < grid[rowIndex].length; colIndex++) {
        var cell = grid[rowIndex][colIndex];
        valueToPosition[cell.value] = Tuple2(rowIndex, colIndex);
      }
    }
  }

  // returns true if the user won, false otherwise
  bool markAndCheck(int value) {
    var position = valueToPosition[value];
    if (position != null) {
      var cell = grid[position.item1][position.item2];
      cell.marked = true;
      hasWon = checkHorizontalLineFromPosition(position) ||
          checkVerticalLineFromPosition(position);
    }
    return hasWon;
  }

  bool checkHorizontalLineFromPosition(Tuple2<int, int> startPosition) {
    var rowIndex = startPosition.item1;
    for (var cell in grid[rowIndex]) {
      if (!cell.marked) {
        return false;
      }
    }
    return true;
  }

  bool checkVerticalLineFromPosition(Tuple2<int, int> startPosition) {
    var colIndex = startPosition.item2;
    for (var rowIndex = 0; rowIndex < grid.length; rowIndex++) {
      var cell = grid[rowIndex][colIndex];
      if (!cell.marked) {
        return false;
      }
    }
    return true;
  }

  List<int> unmarkedValues() {
    List<int> values = [];
    for (var rowIndex = 0; rowIndex < grid.length; rowIndex++) {
      for (var colIndex = 0; colIndex < grid[rowIndex].length; colIndex++) {
        var cell = grid[rowIndex][colIndex];
        if (!cell.marked) {
          values.add(cell.value);
        }
      }
    }
    return values;
  }

  void debug() {
    stdout.writeln('--------------------');
    stdout.writeln('Won: $hasWon');
    for (final row in grid) {
      stdout.writeln(row.map((cell) {
        var paddedValue = cell.value.toString().padLeft(2);
        return "$paddedValue ${cell.marked ? '✅' : '❌'}";
      }).toList());
    }
    stdout.writeln('--------------------');
  }
}

List<BingoBoard> getBoardsFromLines(List<String> lines) {
  var numberOfBoards = (lines.length) / gridSize;
  List<BingoBoard> boards = [];
  for (var boardNumber = 0; boardNumber < numberOfBoards; boardNumber++) {
    var start = (boardNumber * gridSize);
    var end = start + gridSize;
    var boardCells = lines
        .sublist(start, end)
        .map(
          (line) => line
              .split(RegExp(r"\s+"))
              .where((cellValue) => cellValue.isNotEmpty)
              .map(
            (cellValue) {
              return BingoCell(int.parse(cellValue, radix: 10));
            },
          ).toList(),
        )
        .toList();
    boards.add(BingoBoard(boardCells));
  }
  return boards;
}

void main(List<String> arguments) async {
  final inputPath = 'input.txt';

  final lines = await utf8.decoder
      .bind(File(inputPath).openRead())
      .transform(const LineSplitter())
      .where((line) => line.isNotEmpty)
      .toList();

  var numbersToDraw =
      lines.removeAt(0).split(',').map((value) => int.parse(value, radix: 10));
  var boards = getBoardsFromLines(lines);
  var winningBoards = 0;

  for (final value in numbersToDraw) {
    var losingBoards = boards.where((board) => !board.hasWon);
    for (final board in losingBoards) {
      var won = board.markAndCheck(value);
      winningBoards += won ? 1 : 0;
      var lastBoardWinning = winningBoards == boards.length;
      if (lastBoardWinning) {
        stdout.writeln("value: $value");
        stdout.writeln("info: $winningBoards, ${boards.length}");
        for (final board in boards) {
          board.debug();
        }
        var sum =
            board.unmarkedValues().reduce((value, element) => value + element);
        stdout.writeln('$sum, $value');
        stdout.writeln('Output: ${sum * value}');
        return;
      }
    }
  }
}
