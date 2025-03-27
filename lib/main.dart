import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

// Entry point of the application
void main() {
  runApp(CalculatorApp());
}

// Main application widget
class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Flutter Calculator', // App title
      theme: ThemeData.dark(), // Use a dark theme
      home: CalculatorScreen(), // Set the home screen
    );
  }
}

// Stateful widget for the calculator screen
class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

// State class for the calculator screen
class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String _output = '0'; // Holds the current output displayed on the screen
  late AnimationController _controller; // Controls the animation
  late Animation<double> _animation; // Defines the animation behavior

  // List of buttons to display on the calculator
  final List<String> buttons = [
    '7', '8', '9', '/', // Row 1
    '4', '5', '6', 'x', // Row 2
    '1', '2', '3', '-', // Row 3
    'C', '0', '.', '=', // Row 4 (includes clear, dot, and equals buttons)
    'DEL', // Delete button
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Animation duration
      vsync: this, // Provides a Ticker for the animation
    );
    // Define a curved animation
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  // Handles button presses
  void _onButtonPressed(String value) {
    setState(() {
      _controller.forward(from: 0.0); // Trigger the animation
      if (value == 'C') {
        _output = '0'; // Clear the screen
      } else if (value == 'DEL') {
        // Delete the last character, but reset to 0 if only one character remains
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = '0';
        }
      } else if (value == '=') {
        _calculateResult(); // Calculate the result
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
        // Replace the initial 0 with the first input character
        if (_output == '0') {
          _output = value;
        } else {
          _output += value; // Append the input character
        }
      }
    });
  }

  // Checks if a value is an operator
  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == 'x' || value == '/';
  }

  // Calculates the result of the current expression
  void _calculateResult() {
    try {
      // Replace 'x' with '*' for mathematical evaluation
      String expression = _output.replaceAll('x', '*');
      double result = _evaluateExpression(
        expression,
      ); // Evaluate the expression
      if (result.isNaN) {
        _output = 'Error'; // Handle invalid results
      } else {
        _output = result.toString(); // Display the result
      }
    } catch (e) {
      _output = 'Error'; // Handle exceptions
    }
  }

  // Evaluates a mathematical expression using the math_expressions package
  double _evaluateExpression(String expression) {
    Parser p = Parser(); // Create a parser
    Expression exp = p.parse(expression); // Parse the expression
    ContextModel cm = ContextModel(); // Create a context model
    return exp.evaluate(EvaluationType.REAL, cm); // Evaluate the expression
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set the background color
      appBar: AppBar(title: Text('Calculator')), // App bar with title
      body: Column(
        children: [
          // Display area for the output
          Expanded(
            child: Container(
              alignment:
                  Alignment.bottomRight, // Align text to the bottom-right
              padding: EdgeInsets.all(20), // Add padding
              child: ScaleTransition(
                scale: _animation, // Apply the animation
                child: Text(
                  _output, // Display the current output
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Grid of calculator buttons
          GridView.builder(
            shrinkWrap: true, // Prevent the grid from expanding
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 buttons per row
            ),
            itemCount: buttons.length, // Total number of buttons
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap:
                    () => _onButtonPressed(buttons[index]), // Handle button tap
                child: Container(
                  margin: EdgeInsets.all(8), // Add margin around buttons
                  decoration: BoxDecoration(
                    color: Colors.grey[850], // Button background color
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54, // Shadow color
                        offset: Offset(2, 2), // Shadow offset
                        blurRadius: 5, // Shadow blur radius
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      buttons[index], // Display button text
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
