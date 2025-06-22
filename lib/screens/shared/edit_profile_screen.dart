import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animated_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _specialtiesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
    _bioController = TextEditingController(text: user?.bio);
    _specialtiesController = TextEditingController(text: user?.specialties?.join(', '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _specialtiesController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser!;

      // Create a map of the data to update
      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      if (currentUser.role == UserRole.barber) {
        updatedData['bio'] = _bioController.text.trim();
        updatedData['specialties'] = _specialtiesController.text.split(',').map((s) => s.trim()).toList();
      }

      await authProvider.updateUserProfile(updatedData);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile Updated Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          user?.role == UserRole.barber ? Icons.store : Icons.person,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onPrimary, size: 20),
                            onPressed: () {
                              // TODO: Implement image picking logic
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Text('Personal Information', style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 16),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'Phone cannot be empty' : null,
                ),
                if (user?.role == UserRole.barber) ...[
                  SizedBox(height: 32),
                  Text('Barber Profile', style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 16),
                  // --- FIX: Replaced CustomTextField with standard TextFormField for multiline ---
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Bio / Description',
                      prefixIcon: Icon(Icons.info_outline), // Rely on InputDecorationTheme
                    ),
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _specialtiesController,
                    label: 'Specialties (comma-separated)',
                    prefixIcon: Icons.star,
                  ),
                ],
                SizedBox(height: 40),
                AnimatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : Text('Save Changes', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}