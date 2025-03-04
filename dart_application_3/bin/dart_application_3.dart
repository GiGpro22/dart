import 'dart:io';
import 'dart:math';

void main() {
  final game = SeaBattle();
  game.startIgra();
}

class SeaBattle {
  static const int razmerPolya = 10;

  static const String pustayaKletka = '◦';
  static const String kletkaKorablya = '■';
  static const String popadanieKletka = 'X';
  static const String promahKletka = 'O';
  static const String potopKletka = '#';

  final List<int> korabli = [4, 3, 3, 2, 2, 2, 1, 1, 1, 1];

  List<List<String>> poleIgroka = [];
  List<List<String>> skritoePoleIgroka = [];
  List<List<String>> poleKompyutera = [];
  List<List<String>> skritoePoleKompyutera = [];

  int korableyOstalsyaIgrok = 0;
  int korableyOstalsyaKompyuter = 0;

  int potoplenoKorableyIgrok = 0;
  int potoplenoKorableyKompyuter = 0;

  SeaBattle() {
    poleIgroka =
        List.generate(razmerPolya, (_) => List.filled(razmerPolya, pustayaKletka));
    skritoePoleIgroka =
        List.generate(razmerPolya, (_) => List.filled(razmerPolya, pustayaKletka));
    poleKompyutera =
        List.generate(razmerPolya, (_) => List.filled(razmerPolya, pustayaKletka));
    skritoePoleKompyutera =
        List.generate(razmerPolya, (_) => List.filled(razmerPolya, pustayaKletka));
  }

  // Начало игры
  void startIgra() {
    print('Добро пожаловать в Морской бой!');

    print('\nРасставьте свои корабли:');
    razmestitKorabliIgroka();

    razmestitKorabliKompyutera();
    korableyOstalsyaKompyuter = korabli.length;
    korableyOstalsyaIgrok = korabli.length;

    while (korableyOstalsyaIgrok > 0 && korableyOstalsyaKompyuter > 0) {
      hodIgroka();
      if (korableyOstalsyaKompyuter <= 0) break; // Компьютер проиграл
      hodKompyutera();
      if (korableyOstalsyaIgrok <= 0) break; // Игрок проиграл
    }

    String pobeditel;
    if (korableyOstalsyaKompyuter <= 0) {
      print('\nВы победили!');
      pobeditel = 'Вы';
    } else {
      print('\nКомпьютер победил!');
      pobeditel = 'Компьютер';
    }

    print('\n--- Финальное поле компьютера ---');
    printPolye(poleKompyutera);
    print('\n--- Финальное поле игрока ---');
    printPolye(poleIgroka);

    // Вывод статистики
    print('\n--- Статистика игры ---');
    print('Победитель: $pobeditel');
    print('Кораблей осталось у игрока: $korableyOstalsyaIgrok');
    print('Кораблей осталось у компьютера: $korableyOstalsyaKompyuter');
    print('Потопленных кораблей у игрока: $potoplenoKorableyIgrok');
    print('Потопленных кораблей у компьютера: $potoplenoKorableyKompyuter');
      }

  void razmestitKorabliIgroka() {
    for (int dlinaKorablya in korabli) {
      bool razmesheno = false;
      while (!razmesheno) {
        print('\nВаше поле:');
        printPolye(poleIgroka);
        print('Разместите корабль длиной $dlinaKorablya.');

        try {
          stdout.write('Введите координату X (A-J): ');
          String? xStr = stdin.readLineSync()?.toUpperCase();
          if (xStr == null || xStr.isEmpty) {
            print('Некорректный ввод X. Попробуйте еще раз.');
            continue;
          }
          int x = xStr.codeUnitAt(0) - 'A'.codeUnitAt(0);

          stdout.write('Введите координату Y (1-10): ');
          String? yStr = stdin.readLineSync();
          if (yStr == null || yStr.isEmpty) {
            print('Некорректный ввод Y. Попробуйте еще раз.');
            continue;
          }
          int y;
          try {
            y = int.parse(yStr) - 1;
          } catch (e) {
            print(
                'Некорректный формат Y. Введите число от 1 до 10. Попробуйте еще раз.');
            continue;
          }

          stdout.write(
              'Введите ориентацию (h - горизонтально, v - вертикально): ');
          String? orientatsiya = stdin.readLineSync()?.toLowerCase();
          if (orientatsiya == null || orientatsiya.isEmpty) {
            print('Некорректный ввод ориентации. Попробуйте еще раз.');
            continue;
          }

          if (x < 0 ||
              x >= razmerPolya ||
              y < 0 ||
              y >= razmerPolya ||
              (orientatsiya != 'h' && orientatsiya != 'v')) {
            print('Некорректные координаты или ориентация.');
            continue;
          }

          razmesheno = popitatsyaRazmestitKorabl(poleIgroka, x, y, dlinaKorablya, orientatsiya);
          if (!razmesheno) {
            print('Невозможно разместить корабль в этом месте. Попробуйте еще раз.');
          }
        } catch (e) {
          print('Ошибка ввода. Попробуйте еще раз.');
        }
      }
    }
  }

  void razmestitKorabliKompyutera() {
    final random = Random();
    for (int dlinaKorablya in korabli) {
      bool razmesheno = false;
      while (!razmesheno) {
        int x = random.nextInt(razmerPolya);
        int y = random.nextInt(razmerPolya);
        String orientatsiya = random.nextBool() ? 'h' : 'v';
        razmesheno = popitatsyaRazmestitKorabl(poleKompyutera, x, y, dlinaKorablya, orientatsiya);
      }
    }
  }

  bool popitatsyaRazmestitKorabl(List<List<String>> pole, int x, int y, int dlinaKorablya,
      String orientatsiya) {
    if (orientatsiya == 'h') {
      if (x + dlinaKorablya > razmerPolya) return false;
      for (int i = 0; i < dlinaKorablya; i++) {
        if (pole[y][x + i] != pustayaKletka) return false;
        if (!mojnoRazmestitKorablZdes(pole, x + i, y)) return false;
      }
      for (int i = 0; i < dlinaKorablya; i++) {
        pole[y][x + i] = kletkaKorablya;
      }
    } else {
      if (y + dlinaKorablya > razmerPolya) return false;
      for (int i = 0; i < dlinaKorablya; i++) {
        if (pole[y + i][x] != pustayaKletka) return false;
        if (!mojnoRazmestitKorablZdes(pole, x, y + i)) return false;
      }
      for (int i = 0; i < dlinaKorablya; i++) {
        pole[y + i][x] = kletkaKorablya;
      }
    }
    return true;
  }

  bool mojnoRazmestitKorablZdes(List<List<String>> pole, int x, int y) {
    if (x < 0 || x >= razmerPolya || y < 0 || y >= razmerPolya) return false;

    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int newX = x + i;
        int newY = y + j;

        if (newX >= 0 && newX < razmerPolya && newY >= 0 && newY < razmerPolya) {
          if (pole[newY][newX] == kletkaKorablya ||
              pole[newY][newX] == 'X' ||
              pole[newY][newX] == '.') {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Ход игрока
  void hodIgroka() {
    print('\n--- Ваш ход ---');
    print('Поле противника:');
    printPolye(skritoePoleKompyutera);
    print('Ваше поле:');
    printPolye(poleIgroka);
    print('Потопленные корабли: $potoplenoKorableyKompyuter');

    bool validniyVystrel = false;
    while (!validniyVystrel) {
      try {
        stdout.write('Введите координату X для атаки (A-J): ');
        String? xStr = stdin.readLineSync()?.toUpperCase();
        if (xStr == null || xStr.isEmpty) {
          print('Некорректный ввод X. Попробуйте еще раз.');
          continue;
        }
        int x = xStr.codeUnitAt(0) - 'A'.codeUnitAt(0);

        stdout.write('Введите координату Y для атаки (1-10): ');
        String? yStr = stdin.readLineSync();
        if (yStr == null || yStr.isEmpty) {
          print('Некорректный ввод Y. Попробуйте еще раз.');
          continue;
        }
        int y;
        try {
          y = int.parse(yStr) - 1;
        } catch (e) {
          print(
              'Некорректный формат Y. Введите число от 1 до 10. Попробуйте еще раз.');
          continue;
        }

        if (x < 0 || x >= razmerPolya || y < 0 || y >= razmerPolya) {
          print('Некорректные координаты.');
          continue;
        }

        if (skritoePoleKompyutera[y][x] == popadanieKletka ||
            skritoePoleKompyutera[y][x] == promahKletka ||
            skritoePoleKompyutera[y][x] == potopKletka) {
          print('Вы уже стреляли в эту клетку.');
          continue;
        }

        validniyVystrel = true;
        if (poleKompyutera[y][x] == kletkaKorablya) {
          print('Попадание!');
          poleKompyutera[y][x] = popadanieKletka;
          skritoePoleKompyutera[y][x] = popadanieKletka;

          if (korablPotoplen(poleKompyutera, x, y)) {
            print('Корабль потоплен!');
            otmetitKorablKakPotop(poleKompyutera, x, y);
            korableyOstalsyaKompyuter--;
            potoplenoKorableyKompyuter++;

            if (korableyOstalsyaKompyuter <= 0) {
              print('Вы уничтожили все корабли противника!');
              return; // Завершаем ход игрока, так как он победил
            }
          }
        } else {
          print('Промах.');
          poleKompyutera[y][x] = promahKletka;
          skritoePoleKompyutera[y][x] = promahKletka;
        }
      } catch (e) {
        print('Ошибка ввода. Попробуйте еще раз.');
      }
    }
  }

  // Ход компьютера
  void hodKompyutera() {
    print('\n--- Ход компьютера ---');
    final random = Random();
    bool validniyVystrel = false;
    while (!validniyVystrel) {
      int x = random.nextInt(razmerPolya);
      int y = random.nextInt(razmerPolya);

      if (poleIgroka[y][x] == popadanieKletka ||
          poleIgroka[y][x] == promahKletka ||
          poleIgroka[y][x] == potopKletka) {
        continue;
      }

      validniyVystrel = true;
      if (poleIgroka[y][x] == kletkaKorablya) {
        print('Компьютер попал в ваш корабль!');
        poleIgroka[y][x] = popadanieKletka;
        skritoePoleIgroka[y][x] = popadanieKletka; 

        if (korablPotoplen(poleIgroka, x, y)) {
          print('Компьютер потопил ваш корабль!');
          otmetitKorablKakPotop(poleIgroka, x, y);
          korableyOstalsyaIgrok--;
          potoplenoKorableyIgrok++;

          if (korableyOstalsyaIgrok <= 0) {
            print('Компьютер уничтожил все ваши корабли!');
            return; // Завершаем ход компьютера, так как он победил
          }
        }
} else {
  print( 'Компьютер промахнулся.');
  poleIgroka[y][x] = promahKletka;
  skritoePoleIgroka[y][x] = promahKletka; 
}

      sleep(Duration(milliseconds: 500));
    }
  }

  bool korablPotoplen(List<List<String>> pole, int x, int y) {
    // Проверка, действительно ли потоплен корабль
    int dlinaKorablya = poluchitDlinuKorablyaVZdes(pole, x, y);
    if (dlinaKorablya == 0) return false;

    int popadanieCount = 0;
    for (int i = 0; i < razmerPolya; i++) {
      for (int j = 0; j < razmerPolya; j++) {
        if (yavlyaetsyaChastyuTogoJeKorablya(pole, x, y, j, i) && pole[i][j] == popadanieKletka) {
          popadanieCount++;
        }
      }
    }

    return popadanieCount == dlinaKorablya;
  }


  int poluchitDlinuKorablyaVZdes(List<List<String>> pole, int x, int y) {
      if (pole[y][x] != popadanieKletka && pole[y][x] != kletkaKorablya) return 0;

      // проверка горизонт
      int dlina = 1;
      int i = x + 1;
      while (i < razmerPolya && (pole[y][i] == kletkaKorablya || pole[y][i] == popadanieKletka)) {
          dlina++;
          i++;
      }
      i = x - 1;
      while (i >= 0 && (pole[y][i] == kletkaKorablya || pole[y][i] == popadanieKletka)) {
          dlina++;
          i--;
      }
      if (dlina > 1) return dlina;

      // проверка вертик
      dlina = 1;
      i = y + 1;
      while (i < razmerPolya && (pole[i][x] == kletkaKorablya || pole[i][x] == popadanieKletka)) {
          dlina++;
          i++;
      }
      i = y - 1;
      while (i >= 0 && (pole[i][x] == kletkaKorablya || pole[i][x] == popadanieKletka)) {
          dlina++;
          i--;
      }
      return dlina;
  }


  void otmetitKorablKakPotop(List<List<String>> pole, int x, int y) {
    for (int i = 0; i < razmerPolya; i++) {
      for (int j = 0; j < razmerPolya; j++) {
        if (yavlyaetsyaChastyuTogoJeKorablya(pole, x, y, j, i)) {
          pole[i][j] = potopKletka;
          if (pole == poleKompyutera) {
            skritoePoleKompyutera[i][j] = potopKletka;
          }
          if (pole == poleIgroka) {
          skritoePoleIgroka[i][j] = potopKletka;
          }
        }
      }
    }
  }

  bool yavlyaetsyaChastyuTogoJeKorablya(List<List<String>> pole, int x1, int y1, int x2,
      int y2) {
    if (pole[y1][x1] != kletkaKorablya && pole[y1][x1] != popadanieKletka && pole[y1][x1] != potopKletka) return false;
    if (pole[y2][x2] != kletkaKorablya && pole[y2][x2] != popadanieKletka && pole[y2][x2] != potopKletka) return false;

    if (y1 == y2) {
      // горизон
      int nachaloX = min(x1, x2);
      int konecX = max(x1, x2);

      for (int i = nachaloX; i <= konecX; i++) {
        if (pole[y1][i] == pustayaKletka || pole[y1][i] == promahKletka) {
          return false;
        }
      }
      return true;
    }

    if (x1 == x2) {
      // вертикаль
      int nachaloY = min(y1, y2);
      int konecY = max(y1, y2);

      for (int i = nachaloY; i <= konecY; i++) {
        if (pole[i][x1] == pustayaKletka || pole[i][x1] == promahKletka) {
          return false;
        }
      }
      return true;
    }

    return false;
  }



  void printPolye(List<List<String>> pole) {
    stdout.write('   ');
    for (int i = 0; i < razmerPolya; i++) {
      stdout.write('${String.fromCharCode('A'.codeUnitAt(0) + i)} ');
    }
    print('');

    for (int i = 0; i < razmerPolya; i++) {
      stdout.write('${(i + 1).toString().padLeft(2, ' ')} ');
      for (int j = 0; j < razmerPolya; j++) {
        stdout.write('${pole[i][j]} ');
      }
      print('');
    }
  }
}