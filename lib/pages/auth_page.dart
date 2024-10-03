import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:email_validator/email_validator.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Controllers for the form fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSigningIn = true; // Flag to toggle between sign-in and sign-up
  bool _isLoading = false; // Flag to show loading indicator for form submission
  bool _isCheckingSession =
      true; // Flag to show progress bar during session check
  bool _isRecoveringPassword = false; // Flag for password recovery mode

  @override
  void initState() {
    super.initState();
    _checkSession(); // Check if user is already logged in
  }

  void _checkSession() async {
    final Session? session = Supabase.instance.client.auth.currentSession;

    await Future.delayed(
        const Duration(seconds: 2)); // Simulate a delay for session check

    if (!mounted) return;

    if (session != null) {
      // If a session exists, navigate to the home page
      context.go('/home');
    } else {
      // No session found, stop showing the progress bar and allow login/sign-up
      setState(() {
        _isCheckingSession = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  void _toggleSignInSignUp() {
    setState(() {
      _isSigningIn = !_isSigningIn;
      _isRecoveringPassword = false; // Reset password recovery mode
    });
  }

  void _togglePasswordRecovery() {
    setState(() {
      _isRecoveringPassword = !_isRecoveringPassword;
    });
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ignore: unused_local_variable
      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      context.go('/home'); // Navigate to home page
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error occurred: $error'),
      ));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final Map<String, dynamic> userMetadata = {
        'username': _usernameController.text.trim(),
        'firstname': _firstnameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
      };

      // ignore: unused_local_variable
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
        emailRedirectTo: 'io.supabase.natureconnect://login-callback/',
      );

      if (!mounted) return;
      context.go('/home');
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text('Please check your email to confirm your account.'),
      //   duration: Duration(seconds: 10),
      // ));
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error occurred: $error'),
      ));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String email = _emailController.text.trim();

      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.natureconnect://login-callback/',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password reset email sent. Please check your inbox.'),
        duration: Duration(seconds: 10),
      ));

      setState(() {
        _isRecoveringPassword = false;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error occurred: $error'),
      ));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email),
              labelText: 'Email',
            ),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!EmailValidator.validate(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (!_isRecoveringPassword) ...[
            // Password field
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: 'Password',
              ),
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                } else if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // If sign-up, show additional fields
            if (!_isSigningIn) ...[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstnameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  labelText: 'First Name',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastnameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  labelText: 'Last Name',
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Submit button
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _isSigningIn
                      ? _signIn
                      : _signUp,
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(_isSigningIn ? 'Sign In' : 'Sign Up'),
            ),
            const SizedBox(height: 16),
            // Toggle between sign-in and sign-up
            TextButton(
              onPressed: _toggleSignInSignUp,
              child: Text(_isSigningIn
                  ? 'Don\'t have an account? Sign Up'
                  : 'Already have an account? Sign In'),
            ),
            if (_isSigningIn) ...[
              TextButton(
                onPressed: _togglePasswordRecovery,
                child: const Text('Forgot Password?'),
              ),
            ],
          ] else ...[
            // Password Recovery Mode
            ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Reset Password'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _togglePasswordRecovery,
              child: const Text('Back to Sign In'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NatureConnect'),
        centerTitle: true,
      ),
      body: _isCheckingSession
          ? const Center(
              child:
                  CircularProgressIndicator(), // Show loading spinner while checking session
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      if (_isSigningIn && !_isRecoveringPassword)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: const Image(
                            image: AssetImage('assets/images/logo.jpg'),
                            width: 120,
                          ),
                        ),
                      if (_isSigningIn && !_isRecoveringPassword)
                        const SizedBox(height: 50),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: _buildForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
