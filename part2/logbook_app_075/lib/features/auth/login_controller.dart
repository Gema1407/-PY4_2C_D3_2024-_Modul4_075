// login_controller.dart
class LoginController {
  
  final Map<String, String> _username = {
    "admin1" : "123",
    "admin2" : "1234"
  };

  bool login(String username, String password) {
     return _username[username] == password;
  }
}
