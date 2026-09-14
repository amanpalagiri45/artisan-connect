import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../widgets/server_config_dialog.dart';
import 'register_artisan_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'ramlal.pottery@artisanconnect.org');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  void _submitLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${auth.currentUser?.fullName}!'),
          backgroundColor: AppTheme.sageAccent,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed. Please check credentials.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _fillArtisanDemo() {
    setState(() {
      _emailController.text = 'ramlal.pottery@artisanconnect.org';
      _passwordController.text = 'password123';
    });
  }

  void _fillBuyerDemo() {
    setState(() {
      _emailController.text = 'sarah.jenkins@ethicalliving.com';
      _passwordController.text = 'password123';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dns_outlined),
            tooltip: 'Server Connection Settings',
            onPressed: () => ServerConfigDialog.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTerracotta.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.handshake_outlined,
                      size: 48,
                      color: AppTheme.primaryTerracotta,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'ARTISAN CONNECT',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.primaryTerracotta,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Connecting Marginalized Artisans to Ethical Markets',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Quick Demo Autofill Chips
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fast Test Accounts (Seeded):',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _fillArtisanDemo,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Artisan Demo', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _fillBuyerDemo,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              child: const Text('Buyer Demo', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textSecondary, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitLogin,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In to Account'),
                ),
                const SizedBox(height: 20),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Are you a traditional artisan? ',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterArtisanScreen()),
                        );
                      },
                      child: const Text(
                        'Register as Artisan',
                        style: TextStyle(
                          color: AppTheme.primaryTerracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
