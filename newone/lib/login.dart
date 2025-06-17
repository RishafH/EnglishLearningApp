import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:newone/auth_service.dart';
import 'package:newone/dashboard.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  bool isLogin = true;
  bool isLoading = false;

  String email = '';
  String password = '';
  String username = '';
final AuthService _authService = AuthService();

Future<void> handleAuth() async {
  setState(() => isLoading = true);
  try {
    if (isLogin) {
      User? user = await _authService.login(email, password);
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeDashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed.'), backgroundColor: Colors.red),
        );
      }
    } else {
      User? user = await _authService.register(email, password, username);
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeDashboard()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed.'), backgroundColor: Colors.red),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unexpected error: $e'), backgroundColor: Colors.red),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFF6F5),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    isLogin ? "Welcome Back 👋" : "Create Account ✨",
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    isLogin
                        ? "Login to continue your journey."
                        : "Register to start learning English.",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 30),

                  // Username Input (only when registering)
                  if (!isLogin)
                    Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.person),
                          ),
                          onChanged: (val) => username = val.trim(),
                          validator: (val) => val!.isEmpty ? "Enter username" : null,
                        ),
                        SizedBox(height: 20),
                      ],
                    ),

                  // Email
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.email),
                    ),
                    onChanged: (val) => email = val.trim(),
                    validator: (val) => val!.isEmpty ? "Enter email" : null,
                  ),
                  SizedBox(height: 20),

                  // Password
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    onChanged: (val) => password = val.trim(),
                    validator: (val) => val!.length < 6 ? "Min 6 characters" : null,
                  ),
                  SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              await handleAuth();
                            }
                          },
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(isLogin ? "Login" : "Register"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isLogin = !isLogin;
                        email = '';
                        password = '';
                        username = '';
                      });
                    },
                    child: Text(
                      isLogin
                          ? "Don't have an account? Register"
                          : "Already have an account? Login",
                      style: GoogleFonts.poppins(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
