import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  // Controllers for editing
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: user.name);
    _weightController = TextEditingController(text: user.weight.toString());
    _heightController = TextEditingController(text: user.height.toString());
    _ageController = TextEditingController(text: user.age.toString());
  }

  void _saveProfile() {
    final user = Provider.of<UserProvider>(context, listen: false);
    user.updateProfile(
      name: _nameController.text,
      weight: double.tryParse(_weightController.text) ?? user.weight,
      height: double.tryParse(_heightController.text) ?? user.height,
      age: int.tryParse(_ageController.text) ?? user.age,
    );
    
    setState(() => _isEditing = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated and synchronized with AI Coach!', style: GoogleFonts.outfit()),
        backgroundColor: AppTheme.nearlyDarkBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, AppBar().preferredSize.height + MediaQuery.of(context).padding.top + 24, 24, 100),
            child: Column(
              children: [
                _buildProfileCard(user),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _isEditing 
                        ? _buildEditField('Weight (kg)', _weightController, Icons.fitness_center)
                        : _buildStatCard('Weight', '${user.weight}kg', Icons.fitness_center),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _isEditing
                        ? _buildEditField('Height (cm)', _heightController, Icons.height)
                        : _buildStatCard('Height', '${user.height}cm', Icons.height),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard('Daily Goal', '${user.targetCalories} kcal', Icons.bolt),
                const SizedBox(height: 40),
                _buildLogoutButton(),
              ],
            ),
          ),
          _getAppBarUI(),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProvider user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 20),
          if (_isEditing) ...[
            _buildTextField('Full Name', _nameController),
            const SizedBox(height: 12),
            _buildTextField('Age', _ageController, isNumber: true),
          ] else ...[
            Text(
              user.name,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText),
            ),
            Text(
              user.email,
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.nearlyDarkBlue, width: 2),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppTheme.nearlyDarkBlue.withOpacity(0.1),
        child: Icon(Icons.person, size: 60, color: AppTheme.nearlyDarkBlue),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppTheme.nearlyDarkBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.outfit(),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.nearlyDarkBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.nearlyDarkBlue, size: 20),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label, border: InputBorder.none, isDense: true),
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.nearlyDarkBlue, size: 24),
          const SizedBox(height: 12),
          Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.1),
        foregroundColor: Colors.red,
        elevation: 0,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout),
          const SizedBox(width: 12),
          Text('Logout', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _getAppBarUI() {
    return Container(
      height: AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        boxShadow: [BoxShadow(color: AppTheme.gray.withOpacity(0.2), offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Profile', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          TextButton(
            onPressed: _isEditing ? _saveProfile : () => setState(() => _isEditing = true),
            child: Text(_isEditing ? 'SAVE' : 'EDIT', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
