import 'package:flutter/material.dart';

class WebViewProvider with ChangeNotifier {
  int _loadingPercentage = 0;
  bool _isConnected = true;
  //*
  //*
  int get loadingPercentage => _loadingPercentage;
  bool get isConnected => _isConnected;
  //*
  //*
  set setLoadingPercentage(int value) {
    _loadingPercentage = value;
    notifyListeners();
  }

  set setIsConnected(bool value) {
    _isConnected = value;
    notifyListeners();
  }
}
