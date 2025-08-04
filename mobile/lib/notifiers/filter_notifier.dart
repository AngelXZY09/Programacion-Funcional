import 'package:flutter/foundation.dart';
import '../utils_funcional.dart';

class FilterNotifier extends ChangeNotifier {
  bool _excludeEnrolledOrFinished = false;

  bool get excludeEnrolledOrFinished => _excludeEnrolledOrFinished;

  // # toggleExcludeEnrolledOrFinished ha sido convertido a función libre funcional (ver utils_funcional.dart)

  // Método que usa la función funcional para alternar el estado
  void toggleExcludeEnrolledOrFinished() {
    _excludeEnrolledOrFinished = toggleExcludeEnrolledOrFinishedFunc(_excludeEnrolledOrFinished);
    notifyListeners();
  }

  // Método para setear un valor específico si es necesario en el futuro
  void setExcludeEnrolledOrFinished(bool value) {
    if (_excludeEnrolledOrFinished != value) {
      _excludeEnrolledOrFinished = value;
      notifyListeners();
    }
  }
} 