import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CurrentUser {
  final String name;
  final String role;
  final String profileImage;

  CurrentUser({
    required this.name,
    required this.role,
    required this.profileImage,
  });
}

class UserProvider with ChangeNotifier {
  CurrentUser _currentUser = CurrentUser(
    name: kIsWeb ? 'Erwin Marwah' : 'H. Muklas',
    role: kIsWeb ? 'Admin' : 'Owner',
    profileImage: kIsWeb
        ? 'https://ui-avatars.com/api/?name=Erwin+Marwah&background=3B82F6&color=fff&size=128'
        : 'https://ui-avatars.com/api/?name=H+Muklas&background=F59E0B&color=fff&size=128',
  );

  CurrentUser get currentUser => _currentUser;

  void updateUser(String name, String role, String profileImage) {
    _currentUser = CurrentUser(name: name, role: role, profileImage: profileImage);
    notifyListeners();
  }

  void loginAs(String email) {
    if (email == 'admin@tokotelur.com' || email == 'erwinmarw@gmail.com') {
      _currentUser = CurrentUser(
        name: 'Erwin Marwah',
        role: 'Admin',
        profileImage: 'https://ui-avatars.com/api/?name=Erwin+Marwah&background=3B82F6&color=fff&size=128',
      );
    } else if (email == 'owner@tokotelur.com' || email == 'muklas@gmail.com') {
      _currentUser = CurrentUser(
        name: 'H. Muklas',
        role: 'Owner',
        profileImage: 'https://ui-avatars.com/api/?name=H+Muklas&background=F59E0B&color=fff&size=128',
      );
    }
    notifyListeners();
  }
}
