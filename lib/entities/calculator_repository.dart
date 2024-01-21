abstract class CalculatorRepository {
  Future<void> initApp();

  String calculateExpression({required String expression});
}
