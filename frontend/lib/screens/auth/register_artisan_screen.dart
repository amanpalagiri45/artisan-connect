import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../state/auth_provider.dart';

class RegisterArtisanScreen extends StatefulWidget {
  const RegisterArtisanScreen({Key? key}) : super(key: key);

  @override
  State<RegisterArtisanScreen> createState() => _RegisterArtisanScreenState();
}

class _RegisterArtisanScreenState extends State<RegisterArtisanScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _craftTypeController = TextEditingController();
  final _regionController = TextEditingController();
  final _coopController = TextEditingController();
  final _heritageStoryController = TextEditingController();
  int _yearsExperience = 5;

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.registerArtisan(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      craftType: _craftTypeController.text,
      region: _regionController.text,
      cooperative: _coopController.text.isNotEmpty ? _coopController.text : null,
      heritageStory: _heritageStoryController.text.isNotEmpty ? _heritageStoryController.text : null,
      yearsOfExperience: _yearsExperience,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artisan profile created successfully! Welcome to Artisan Connect.'),
          backgroundColor: AppTheme.sageAccent,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _craftTypeController.dispose();
    _regionController.dispose();
    _coopController.dispose();
    _heritageStoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisan Onboarding'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTerracotta.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryTerracotta.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.palette_outlined, color: AppTheme.primaryTerracotta, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Join our verified directory of traditional and indigenous craftspeople to connect directly with global ethical buyers.',
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Personal Info Section
                const Text(
                  '1. Account Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password (min 6 chars) *', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Contact Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                ),
                const SizedBox(height: 24),

                // Craft & Provenance Section
                const Text(
                  '2. Craft & Provenance Profile',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _craftTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Primary Craft Discipline *',
                    hintText: 'e.g. Handloom Weaving, Terracotta, Wood Carving',
                    prefixIcon: Icon(Icons.handyman_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Craft type required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _regionController,
                  decoration: const InputDecoration(
                    labelText: 'Village / Region / State *',
                    hintText: 'e.g. Maheshwar, Madhya Pradesh',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Region required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coopController,
                  decoration: const InputDecoration(
                    labelText: 'Community Cooperative / Guild Name',
                    hintText: 'e.g. Nimar Women Weavers Collective',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heritageStoryController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Heritage Story & Traditional Technique',
                    hintText: 'Describe the cultural origin, tools, and traditional techniques of your craft...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),

                // Years of Experience Slider
                Row(
                  children: [
                    const Icon(Icons.history, color: AppTheme.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text('Years of Craft Experience: $_yearsExperience years',
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13.5)),
                  ],
                ),
                Slider(
                  value: _yearsExperience.toDouble(),
                  min: 1,
                  max: 50,
                  divisions: 49,
                  activeColor: AppTheme.primaryTerracotta,
                  label: '$_yearsExperience yrs',
                  onChanged: (val) => setState(() => _yearsExperience = val.round()),
                ),
                const SizedBox(height: 24),

                // Submit
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitRegistration,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Complete Artisan Registration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
