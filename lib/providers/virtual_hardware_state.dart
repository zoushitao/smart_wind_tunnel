class VirtualHardwareState {
  late List<List<int>> _matrix;
  //getter
  List<List<int>> get matrix => _matrix;

  VirtualHardwareState() {
    int numRows = 8;
    int numCols = 8;

    _matrix = List.generate(
      numRows,
      (row) => List<int>.filled(numCols, 3000),
    );
  }

  void setAll(int val) {
    // 获取矩阵的行数和列数
    int numRows = _matrix.length;
    int numCols = _matrix[0].length;
    // 迭代遍历矩阵
    for (int i = 0; i < numRows; i++) {
      for (int j = 0; j < numCols; j++) {
        _matrix[i][j] = val;
      }
    }
  }

  void setRow(int val, int row) {
    // 获取矩阵的行数和列数

    int numRows = _matrix.length;
    int numCols = _matrix[0].length;
    // 迭代遍历矩阵
    for (int i = 0; i < numRows; i++) {
      _matrix[row][i] = val;
    }
  }

  void setCol(int val, int col) {
    // 获取矩阵的行数和列数
    int numRows = _matrix.length;
    int numCols = _matrix[0].length;
    // 迭代遍历矩阵
    for (int i = 0; i < numCols; i++) {
      _matrix[i][col] = val;
    }
  }
}
