import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => GameState(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Card Matching Game')),
      body: Column(
        children: [
          TimerWidget(),
          ScoreWidget(),
          Expanded(child: CardGrid()),
          if (gameState.isGameWon())
            Container(
              color: Colors.black54,
              child: Center(
                child: Text(
                  'You Win!',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: gameState.cards.length,
      itemBuilder: (context, index) {
        return CardWidget(card: gameState.cards[index]);
      },
    );
  }
}

class CardWidget extends StatelessWidget {
  final CardModel card;

  CardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return GestureDetector(
      onTap: () {
        gameState.flipCard(card);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: Card(
          child: Center(
            child: Text(
              card.isFaceUp ? card.front : '🃏',
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class CardModel {
  final String front;
  final String back;
  bool isFaceUp;

  CardModel({required this.front, required this.back, this.isFaceUp = false});
}

class GameState extends ChangeNotifier {
  List<CardModel> cards = [];
  List<CardModel> faceUpCards = [];
  int score = 0;

  GameState() {
    _initializeCards();
  }

  void _initializeCards() {
    List<String> cardFaces = ['A', 'B', 'C', 'D'];
    for (String face in cardFaces) {
      cards.add(CardModel(front: face, back: '🃏'));
      cards.add(CardModel(front: face, back: '🃏'));
    }
    cards.shuffle();
  }

  void flipCard(CardModel card) {
    if (!card.isFaceUp && faceUpCards.length < 2) {
      card.isFaceUp = true;
      faceUpCards.add(card);
      notifyListeners();

      if (faceUpCards.length == 2) {
        _checkMatch();
      }
    }
  }

  void _checkMatch() {
    if (faceUpCards[0].front == faceUpCards[1].front) {
      score++;
      faceUpCards.clear();
    } else {
      Future.delayed(Duration(seconds: 1), () {
        faceUpCards.forEach((card) {
          card.isFaceUp = false;
        });
        faceUpCards.clear();
        notifyListeners();
      });
    }
  }

  bool isGameWon() {
    return cards.every((card) => card.isFaceUp);
  }
}

class TimerWidget extends StatefulWidget {
  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  int _start = 0;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _start++;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Text('Time: $_start seconds', style: TextStyle(fontSize: 20));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class ScoreWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return Text('Score: ${gameState.score}', style: TextStyle(fontSize: 20));
  }
}
