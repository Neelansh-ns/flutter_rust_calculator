import 'package:flutter_rust_calculator/entities/calculator_repository.dart';
import 'package:flutter_rust_calculator/src/rust/api/simple.dart' as rust_lib;
import 'package:flutter_rust_calculator/src/rust/frb_generated.dart';

class RustCalculatorRepository extends CalculatorRepository {
  @override
  Future<void> initApp() {
    return RustLib.init();
  }

  @override
  calculateExpression({required String expression}) {
    return rust_lib.calculateExpression(expression: expression);
  }
}
