import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitness_app/app_theme.dart';
import 'package:fitness_app/screens/ai_coach_screen.dart';
import 'package:fitness_app/screens/generic_content_screen.dart';
import 'package:fitness_app/screens/feedback_screen.dart';
import 'package:fitness_app/screens/settings_screen.dart';
import 'package:fitness_app/screens/workout_history_screen.dart';
import 'package:fitness_app/screens/stats_screen.dart';
import 'package:fitness_app/screens/progress_gallery_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class CustomDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? userImage;
  final VoidCallback? onLogout;
  final Function(int index)? onTabTap;

  const CustomDrawer({
    Key? key,
    required this.userName,
    this.userEmail = 'user@example.com',
    this.userImage,
    this.onLogout,
    this.onTabTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.white,
      child: Column(
        children: [
          // Header Section
          Consumer<UserProvider>(
            builder: (context, user, _) => Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.nearlyDarkBlue,
                    AppTheme.nearlyDarkBlue2.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Image
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: userImage != null
                                  ? Image.asset(
                                      userImage!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.person, size: 50, color: Colors.white),
                                    )
                                  : Icon(Icons.person, size: 50, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.online_prediction, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // User Info
                      Text(
                        user.name,
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.goal.toString().split('.').last,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () => onTabTap?.call(0),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.restaurant_menu_outlined,
                  title: 'Meals',
                  onTap: () => onTabTap?.call(2),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.fitness_center_outlined,
                  title: 'Workouts',
                  onTap: () => onTabTap?.call(1),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () => onTabTap?.call(3),
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.bar_chart_rounded,
                  title: 'Statistics',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => StatsScreen()));
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.auto_awesome_rounded,
                  title: 'Coach AI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AICoachScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.history_rounded,
                  title: 'Workout History',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutHistoryScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.photo_library_outlined,
                  title: 'Body Progress',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgressGalleryScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: AppTheme.gray.withOpacity(0.3)),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.support_agent_outlined,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericContentScreen(
                          title: 'Help & Support',
                          icon: Icons.support_agent_outlined,
                          content: 'Need help? Contact our support team at support@fitnessapp.com or call us at +1 234 567 890. We are available 24/7!',
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.people_outline,
                  title: 'Invite Friends',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericContentScreen(
                          title: 'Invite Friends',
                          icon: Icons.people_outline,
                          content: 'Share the fitness joy! Invite your friends and earn premium features for every successful referral.',
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.star_outline,
                  title: 'Rate App',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericContentScreen(
                          title: 'Rate App',
                          icon: Icons.star_outline,
                          content: 'Loving the app? Please take a moment to rate us on the Store. It helps us grow!',
                        ),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: AppTheme.gray.withOpacity(0.3)),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenericContentScreen(
                          title: 'About',
                          icon: Icons.info_outline,
                          content: 'Fitness App v2.0.0\nBuilt with ❤️ for your health and performance.\n© 2026 Antigravity Inc.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Logout Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              border: Border(top: BorderSide(color: Colors.red.withOpacity(0.2))),
            ),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(
                'Logout',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              onTap: onLogout ??
                  () {
                    Navigator.pop(context);
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.nearlyDarkBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.nearlyDarkBlue),
        ),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppTheme.darkText,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.gray),
        onTap: () {
          if (onTap != null) {
            // Check if it's a tab change or a new screen
            // If it's a new screen, we don't necessarily pop the drawer if we push a new route
            // But usually we pop the drawer first.
            Navigator.pop(context);
            onTap();
          }
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.transparent,
      ),
    );
  }
}
