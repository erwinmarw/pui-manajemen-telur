import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String _userEmail = '';
  String get userEmail => _userEmail;

  String _userRole = '';
  String get userRole => _userRole;

  void login(String email, String password) {
    // Logika dummy: Jika email matching admin@tokotelur.com, owner@tokotelur.com, erwinmarw@gmail.com, atau muklas@gmail.com dengan password 123
    if ((email == 'admin@tokotelur.com' || email == 'owner@tokotelur.com' || email == 'erwinmarw@gmail.com' || email == 'muklas@gmail.com') && password == '123') {
      _isAuthenticated = true;
      _userEmail = email;
      _userRole = (email == 'admin@tokotelur.com' || email == 'erwinmarw@gmail.com') ? 'Admin' : 'Owner';
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _userEmail = '';
    _userRole = '';
    notifyListeners();
  }
}