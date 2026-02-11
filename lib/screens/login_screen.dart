import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF66BB6A),
              Color(0xFF29B6F6),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.language,
                    size: 40,
                    color: Color(0xFF1A237E),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  'Please sign in to continue',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Login Form
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: GoogleFonts.nunitoSans(
                              color: const Color(0xFF546E7A),
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF29B6F6),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Password Field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.nunitoSans(
                              color: const Color(0xFF546E7A),
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF29B6F6),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color(0xFF29B6F6),
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Remember Me
                            Row(
                              children: [
                                Checkbox(
                                  value: false,
                                  onChanged: (value) {},
                                  activeColor: const Color(0xFF29B6F6),
                                ),
                                Text(
                                  'Remember me',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 14,
                                    color: const Color(0xFF546E7A),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Forgot Password
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFF29B6F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushNamed(context, '/onboarding');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A237E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'or continue with',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Social Login Buttons
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(
                              icon: Icons.g_translate,
                              color: Color(0xFFDB4437),
                            ),
                            SizedBox(width: 15),
                            SocialLoginButton(
                              icon: Icons.apple,
                              color: Colors.black,
                            ),
                            SizedBox(width: 15),
                            SocialLoginButton(
                              icon: Icons.facebook,
                              color: Color(0xFF4267B2),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFF1A237E),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color color;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}