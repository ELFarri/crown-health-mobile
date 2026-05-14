import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _unit = 'Kilograms (kg)';

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: userProvider.isDarkMode ? AppTheme.darkBackground : AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: userProvider.isDarkMode ? Colors.white : AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            color: userProvider.isDarkMode ? Colors.white : AppTheme.darkText, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Preferences'),
            _buildSettingTile(
              isDarkMode: userProvider.isDarkMode,
              title: 'Notifications',
              subtitle: 'Receive workout reminders',
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppTheme.nearlyDarkBlue,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
            ),
            _buildSettingTile(
              isDarkMode: userProvider.isDarkMode,
              title: 'Dark Mode',
              subtitle: 'Enjoy a deep black experience',
              trailing: Switch(
                value: userProvider.isDarkMode,
                activeColor: AppTheme.nearlyDarkBlue,
                onChanged: (val) => userProvider.toggleDarkMode(val),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Units'),
            _buildSettingTile(
              isDarkMode: userProvider.isDarkMode,
              title: 'Weight Unit',
              subtitle: _unit,
              onTap: () => _showUnitPicker(),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Account'),
            _buildSettingTile(
              isDarkMode: userProvider.isDarkMode,
              title: 'Change Password',
              subtitle: 'Last changed 3 months ago',
              onTap: () {},
            ),
            _buildSettingTile(
              isDarkMode: userProvider.isDarkMode,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Calal v1.0.0',
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.nearlyDarkBlue,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required bool isDarkMode,
    required String title, 
    String? subtitle, 
    Widget? trailing, 
    VoidCallback? onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: ListTile(
        title: Text(
          title, 
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppTheme.darkText
          )
        ),
        subtitle: subtitle != null 
            ? Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)) 
            : null,
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 14, color: isDarkMode ? Colors.grey : AppTheme.gray),
        onTap: onTap,
      ),
    );
  }

  void _showUnitPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Weight Unit', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildUnitOption('Kilograms (kg)'),
              _buildUnitOption('Pounds (lbs)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnitOption(String unit) {
    return ListTile(
      title: Text(unit, style: GoogleFonts.outfit()),
      trailing: _unit == unit ? Icon(Icons.check_circle, color: AppTheme.nearlyDarkBlue) : null,
      onTap: () {
        setState(() => _unit = unit);
        Navigator.pop(context);
      },
    );
  }
}
