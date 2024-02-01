import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_rust_calculator/entities/calculator_repository.dart';
import 'package:flutter_rust_calculator/screens/video_picker_screen.dart';
import 'package:flutter_rust_calculator/src/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServices();
  await locator.get<CalculatorRepository>().initApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Rust Calculator'),
      home: const VideoPickerScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _expressionController;
  late String? _result;
  late String? _error;

  @override
  void initState() {
    super.initState();
    _expressionController = TextEditingController();
    _result = null;
    _error = null;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: _expressionController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    _onCalculateTap();
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter an expression',
                    hintText: 'e.g. 1 + 2 * 3',
                  ),
                  inputFormatters: [
                    //To remove whitespaces after each character
                    FilteringTextInputFormatter.deny(RegExp(r' \s+')),
                  ],
                  onChanged: (value) {
                    if (_error != null || _result != null) {
                      setState(() {
                        _error = null;
                        _result = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                _error != null
                    ? Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      )
                    : _result != null
                        ? Row(
                            children: [
                              const Text(
                                'Result: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _result!,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          )
                        : const SizedBox(height: 24),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _onCalculateTap,
                        child: const Text('Calculate'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _onClearTap,
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onClearTap() {
    setState(() {
      _expressionController.text = '';
      _result = null;
      _error = null;
    });
  }

  void _onCalculateTap() {
    if (_expressionController.text.isEmpty) {
      setState(() {
        _error = "Expression cannot be empty";
      });
      return;
    }
    try {
      setState(() {
        _result = locator.get<CalculatorRepository>().calculateExpression(expression: _expressionController.text);
        _error = null;
      });
    } catch (e, s) {
      if (kDebugMode) {
        print('$e\n$s');
      }
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _expressionController.dispose();
  }
}
