import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedDifficulty = 'Medium';
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Learning Settings
            _buildSectionHeader('Learning'),
            _buildSettingTile(
              icon: Icons.show_chart,
              title: 'Difficulty Level',
              subtitle: 'Choose your learning level',
              trailing: DropdownButton<String>(
                value: _selectedDifficulty,
                items: ['Beginner', 'Medium', 'Advanced']
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDifficulty = newValue ?? 'Medium';
                  });
                },
              ),
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Interface Language',
              subtitle: 'Choose display language',
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items: ['English', 'French', 'Spanish', 'German']
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue ?? 'English';
                  });
                },
              ),
            ),
            _buildDivider(),

            // Notifications
            _buildSectionHeader('Notifications'),
            _buildToggleTile(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              subtitle: 'Get reminded to practice daily',
              value: _notificationsEnabled,
              onChanged: (newValue) {
                setState(() {
                  _notificationsEnabled = newValue;
                });
              },
            ),
            _buildToggleTile(
              icon: Icons.volume_up,
              title: 'Sound Effects',
              subtitle: 'Play sounds for correct answers',
              value: _soundEnabled,
              onChanged: (newValue) {
                setState(() {
                  _soundEnabled = newValue;
                });
              },
            ),
            _buildDivider(),

            // Display
            _buildSectionHeader('Display'),
            _buildToggleTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Easy on the eyes',
              value: _darkModeEnabled,
              onChanged: (newValue) {
                setState(() {
                  _darkModeEnabled = newValue;
                });
              },
            ),
            _buildDivider(),

            // About
            _buildSectionHeader('About'),
            _buildSimpleTile(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0',
            ),
            _buildSimpleTile(
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Contact our support team',
              onTap: () {
                _showDialog('Help & Support', 'Contact us at support@linguaneural.com');
              },
            ),
            _buildSimpleTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                _showDialog('Privacy Policy', 'Your privacy is important to us...');
              },
            ),
            _buildSimpleTile(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                _showDialog('Terms of Service', 'Please read our terms carefully...');
              },
            ),
            _buildDivider(),

            // Account
            _buildSectionHeader('Account'),
            _buildSimpleTile(
              icon: Icons.logout,
              title: 'Logout',
              titleColor: Colors.red,
              onTap: () {
                _showLogoutConfirmation();
              },
            ),
            _buildSimpleTile(
              icon: Icons.delete,
              title: 'Delete Account',
              titleColor: Colors.red,
              onTap: () {
                _showDeleteAccountConfirmation();
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A237E),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF29B6F6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF29B6F6), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF66BB6A), size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: const Color(0xFF546E7A),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF66BB6A),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color.lerp(titleColor ?? const Color(0xFFFF9800), Colors.white, 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: titleColor ?? const Color(0xFFFF9800), size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: titleColor ?? const Color(0xFF1A237E),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: const Color(0xFF546E7A),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF90A4AE)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        color: Colors.grey.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. All your data will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
