import 'dart:io';
import 'dart:math';

void prword(List<String> board, int size) {
  stdout.write('  ');
  for (int i = 1; i <= size; i++) {
    stdout.write(' $i');
  }
  stdout.write('\n');

  for (int i = 0; i < size; i++) {
    stdout.write('${i + 1} ');
    for (int j = 0; j < size; j++) {
      stdout.write(' ${board[i * size + j] == ' ' ? '.' : board[i * size + j]}'); 
    }
    stdout.write('\n');
  }
}


String? checkWinner(List<String> board, int size) {
  for (int i = 0; i < size; i++) {
    bool rowWinX = true;
    bool rowWinO = true;
    for (int j = 0; j < size; j++) {
      if (board[i * size + j] != 'X') rowWinX = false;
      if (board[i * size + j] != 'O') rowWinO = false;
    }
    if (rowWinX) return 'X';
    if (rowWinO) return 'O';
  }


  for (int i = 0; i < size; i++) {
    bool colWinX = true;
    bool colWinO = true;
    for (int j = 0; j < size; j++) {
      if (board[j * size + i] != 'X') colWinX = false;
      if (board[j * size + i] != 'O') colWinO = false;
    }
    if (colWinX) return 'X';
    if (colWinO) return 'O';
  }

  
  bool diag1WinX = true;
  bool diag1WinO = true;
  for (int i = 0; i < size; i++) {
    if (board[i * size + i] != 'X') diag1WinX = false;
    if (board[i * size + i] != 'O') diag1WinO = false;
  }
  if (diag1WinX) return 'X';
  if (diag1WinO) return 'O';


  bool diag2WinX = true;
  bool diag2WinO = true;
  for (int i = 0; i < size; i++) {
    if (board[i * size + (size - 1 - i)] != 'X') diag2WinX = false;
    if (board[i * size + (size - 1 - i)] != 'O') diag2WinO = false;
  }
  if (diag2WinX) return 'X';
  if (diag2WinO) return 'O';


  if (!board.contains(' ')) {
    return 'Ничья';
  }

  return null; 
}


int playerMove(List<String> board, int size, String player) {
  while (true) {
    stdout.write('Игрок $player, введите строку и столбец (например, 1 2) или 0 для выхода: ');
    String? input = stdin.readLineSync();
    if (input == null) {
      print('Неверный ввод');
      continue;
    }

    if (input == '0') {
      return -2; 
    }    List<String> parts = input.split(' ');
    if (parts.length != 2) {
      print('Неверный ввод. Введите два числа, разделенных пробелом.');
      continue;
    }

    try {
      int row = int.parse(parts[0]) - 1;
      int col = int.parse(parts[1]) - 1;
      int move = row * size + col;

      if (row >= 0 && row < size && col >= 0 && col < size && board[move] == ' ') {
        return move;
      } else {
        print('Неверный ввод или клетка занята. Попробуйте снова.');
      }
    } catch (e) {
      print('Неверный ввод. Введите два числа.');
    }
  }
}


int robotMove(List<String> board, int size, String robot) {
  String player = robot == 'X' ? 'O' : 'X';


  for (int i = 0; i < size * size; i++) {
    if (board[i] == ' ') {
      List<String> tempBoard = List.from(board);
      tempBoard[i] = robot;
      if (checkWinner(tempBoard, size) == robot) {
        return i;
      }
    }
  }


  for (int i = 0; i < size * size; i++) {
    if (board[i] == ' ') {
      List<String> tempBoard = List.from(board);
      tempBoard[i] = player;
      if (checkWinner(tempBoard, size) == player) {
        return i;
      }
    }
  }


  List<int> availableMoves = [];
  for (int i = 0; i < size * size; i++) {
    if (board[i] == ' ') {
      availableMoves.add(i);
    }
  }
  if (availableMoves.isNotEmpty) {
    return availableMoves[Random().nextInt(availableMoves.length)];
  } else {
    return -1; 
  }
}

void main() {
  while (true) {
    int size;
    while (true) {
      stdout.write('Введите размер игрового поля (3-9): ');
      String? input = stdin.readLineSync();
      if (input == null) {
        print('Неверный ввод');
        continue;
      }
      if (input == '0') {
        return; 
      }
      try {
        size = int.parse(input);
        if (size >= 3 && size <= 9) {
          break;
        } else {
          print('Размер должен быть от 3 до 9.');
        }
      } catch (e) {
        print('Неверный ввод. Введите число.');
      }
    }


    String? mode;
    while (true) {
      stdout.write('Выберите режим игры (1 - игрок против игрока, 2 - игрок против робота, 0 - выйти): ');
      mode = stdin.readLineSync();
      if (mode == null) {
        print('Неверный ввод.');
        continue;
      }
      if (mode == '0') {
        return;
      }
      if (mode == '1' || mode == '2') {
        break;
      } else {
        print('Неверный ввод.');
      }
    }

    while (true) {
      List<String> board = List.filled(size * size, ' ');
      String currentPlayer = Random().nextBool() ? 'X' : 'O';
      print('Первым ходит игрок $currentPlayer.');
      bool againstRobot = mode == '2';

      while (true) {
        prword(board, size);
        stdout.write("${currentPlayer}'по очереди. Введите строку и столбец: \n");
        int move;

        if (!againstRobot || currentPlayer == 'X') {
          move = playerMove(board, size, currentPlayer);
          if (move == -2) {
            break;
          }
        } else {
          move = robotMove(board, size, currentPlayer);
          print('Робот $currentPlayer ходит.');
          if (move == -1) {
            print("Ошибка: Робот не может выполнить ни одного движения!");
            break; 
          }
        }

        board[move] = currentPlayer;

        String? winner = checkWinner(board, size);
        if (winner != null) {
          prword(board, size);
          if (winner == 'Ничья') {
            print('Ничья!');
          } else {
            print('Победил игрок $winner!');
          }
          break; 
        }

        currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      }
      stdout.write('Хотите сыграть еще раз? (y/n): ');
      String? playAgain = stdin.readLineSync()?.toLowerCase();
      if (playAgain != 'y') {
        break; 
      }
    }
    stdout.write('Хотите сменить размер поля или режим игры? (y/n): ');
    String? changeSettings = stdin.readLineSync()?.toLowerCase();
    if (changeSettings != 'y') {
      break; 
    }
  }
}