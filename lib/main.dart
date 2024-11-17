import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class GameState with ChangeNotifier {
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _gameStatus = 'Turno de X';

  List<String> get board => _board;
  String get currentPlayer => _currentPlayer;
  String get gameStatus => _gameStatus;

  // Combinaciones ganadoras
  List<List<int>> winningCombinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  void _checkWinner() {
    for (var combination in winningCombinations) {
      if (_board[combination[0]] != '' &&
          _board[combination[0]] == _board[combination[1]] &&
          _board[combination[1]] == _board[combination[2]]) {
        _gameStatus = '¡$_currentPlayer ha ganado!';
        notifyListeners();

        // Reiniciar el juego después de un retraso
        Future.delayed(Duration(seconds: 2), () {
          resetGame();
        });
        return;
      }
    }

    // Comprobar empate
    if (!_board.contains('')) {
      _gameStatus = '¡Es un empate!';
      notifyListeners();
    }
  }

  void handleTap(int index) {
    // Verificar que la casilla esté vacía y el juego no haya terminado
    if (_board[index] != '' || _gameStatus != 'Turno de X' && _gameStatus != 'Turno de O') return;

    _board[index] = _currentPlayer;
    _checkWinner();

    // Alternar el turno
    _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    _gameStatus = 'Turno de $_currentPlayer';

    notifyListeners();
  }

  void resetGame() {
    _board = List.filled(9, '');
    _gameStatus = 'Turno de X';
    _currentPlayer = 'X';
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MaterialApp(
        title: 'Juego del Gato',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TicTacToeScreen(),
      ),
    );
  }
}

class TicTacToeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Juego del Gato'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              gameState.gameStatus,
              style: TextStyle(fontSize: 24),
            ),
          ),
          // Tablero
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => gameState.handleTap(index),
                child: Container(
                  color: Colors.blueAccent,
                  child: Center(
                    child: Text(
                      gameState.board[index],
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          // Botón de reiniciar
          ElevatedButton(
            onPressed: gameState.resetGame,
            child: Text('Reiniciar Juego'),
          ),
        ],
      ),
    );
  }
}
