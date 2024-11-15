import 'package:flutter/foundation.dart';

class TotalLemburProvider with ChangeNotifier {
  int _totalLembur = 0;

  int get totalLembur => _totalLembur;

  void updateTotalLembur(int newTotal) {
    _totalLembur = newTotal;
    notifyListeners();
  }
}
