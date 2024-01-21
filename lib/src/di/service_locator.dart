import 'package:flutter_rust_calculator/data/rust_calculator_repository.dart';
import 'package:flutter_rust_calculator/entities/calculator_repository.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

Future<void> setUpServices() async {
  locator.registerSingleton<CalculatorRepository>(RustCalculatorRepository());
}