import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: ThemeData.dark(),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _output = '0';
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<String> buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', 'x',
    '1', '2', '3', '-',
    'C', '0', '.', '=', // Add dot button
    'DEL', // Add DEL button
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onButtonPressed(String value) {
    setState(() {
      _controller.forward(from: 0.0);
      if (value == 'C') {
        _output = '0'; // Clear the screen
      } else if (value == 'DEL') {
        // Delete last character, but don't delete if only one character is present
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = '0'; // Reset to 0 if there's only one character
        }
      } else if (value == '=') {
        _calculateResult();
      } else {
        // Prevent multiple operators in a row and multiple decimals
        if (_output.isNotEmpty &&
            _isOperator(value) &&
            _isOperator(_output[_output.length - 1])) {
          return;
        }
        if (value == '.' && _output.contains('.')) {
          return;
        }
        // If the screen is 0, replace it with the first character
        if (_output == '0') {
          _output = value;
        } else {
          _output += value;
        }
      }
    });
  }

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == 'x' || value == '/';
  }

  void _calculateResult() {
    try {
      String expression = _output.replaceAll('x', '*'); // Convert 'x' to '*'
      double result = _evaluateExpression(expression);
      if (result.isNaN) {
        _output = 'Error';
      } else {
        _output = result.toString();
      }
    } catch (e) {
      _output = 'Error';
    }
  }

  double _evaluateExpression(String expression) {
    Parser p = Parser();
    Expression exp = p.parse(expression);
    ContextModel cm = ContextModel();
    return exp.evaluate(EvaluationType.REAL, cm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Calculator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(20),
              child: ScaleTransition(
                scale: _animation,
                child: Text(
                  _output,
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount:
                buttons.length, // This will match the actual number of buttons
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onButtonPressed(buttons[index]),
                child: Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      buttons[index],
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
