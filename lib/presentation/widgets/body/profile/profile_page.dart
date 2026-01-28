import 'package:flutter/material.dart';
import 'package:movielist/core/utils/app_colors.dart';
import 'package:movielist/core/utils/app_constants.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/presentation/widgets/body/profile/custom_list_tile.dart';
import 'package:movielist/presentation/widgets/body/profile/profile_item.dart';
import 'package:movielist/services/tmdb_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TmdbService _tmdbService = TmdbService();
  AccountDetails? _accountDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  Future<void> _loadAccountDetails() async {
    setState(() => _isLoading = true);
    try {
      final sessionId = await _tmdbService.getSessionId();
      if (sessionId != null) {
        final details = await _tmdbService.getAccountDetails(sessionId);
        if (mounted) {
          setState(() {
            _accountDetails = details;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _tmdbService.logout();
      if (success && mounted) {
        // Navigate to login screen
        // Replace with your login screen route
        // Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _handleTap(BuildContext context, String title) {
    switch (title) {
      case 'Account Settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AccountSettingsPage()),
        );
        break;
      case 'Notifications':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationsPage()),
        );
        break;
      case 'Privacy & Security':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrivacySecurityPage()),
        );
        break;
      case 'Help & Support':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpSupportPage()),
        );
        break;
      case 'About':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AboutPage()),
        );
        break;
      case 'Logout':
        _handleLogout();
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Tapped: $title')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView(
            children: [
              ProfileItem(accountDetails: _accountDetails),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FilledButton(
                  onPressed: () {
                    // Navigate to edit profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit Profile coming soon')),
                    );
                  },
                  child: Text('Edit Profile'),
                ),
              ),
              SizedBox(height: 24),

              // Settings List
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.only(left: 72),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.lightGrey.withValues(alpha: 0.3),
                  ),
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return CustomListTile(
                    icon: item.icon,
                    title: item.title,
                    trailing: item.trailing,
                    showArrow: item.showArrow,
                    onTap: () => _handleTap(context, item.title),
                  );
                },
              ),
            ],
          );
  }
}

// Account Settings Page
class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: ListView(
        children: [
          CustomListTile(
            icon: Icons.person,
            title: 'Change Username',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Change Username')));
            },
          ),
          CustomListTile(
            icon: Icons.email,
            title: 'Change Email',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Change Email')));
            },
          ),
          CustomListTile(
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Change Password')));
            },
          ),
          CustomListTile(
            icon: Icons.language,
            title: 'Language',
            trailing: 'English',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Change Language')));
            },
          ),
        ],
      ),
    );
  }
}

// Notifications Page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _newReleasesNotif = true;
  bool _recommendationsNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Push Notifications'),
            subtitle: Text('Receive notifications on your device'),
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
            },
          ),
          SwitchListTile(
            title: Text('Email Notifications'),
            subtitle: Text('Receive notifications via email'),
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notification Types',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: Text('New Releases'),
            subtitle: Text('Get notified about new movies and shows'),
            value: _newReleasesNotif,
            onChanged: (value) {
              setState(() => _newReleasesNotif = value);
            },
          ),
          SwitchListTile(
            title: Text('Recommendations'),
            subtitle: Text('Personalized recommendations for you'),
            value: _recommendationsNotif,
            onChanged: (value) {
              setState(() => _recommendationsNotif = value);
            },
          ),
        ],
      ),
    );
  }
}

// Privacy & Security Page
class PrivacySecurityPage extends StatelessWidget {
  const PrivacySecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy & Security')),
      body: ListView(
        children: [
          CustomListTile(
            icon: Icons.visibility,
            title: 'Profile Visibility',
            trailing: 'Public',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Change Profile Visibility')),
              );
            },
          ),
          CustomListTile(
            icon: Icons.lock,
            title: 'Two-Factor Authentication',
            trailing: 'Off',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Enable 2FA')));
            },
          ),
          CustomListTile(
            icon: Icons.security,
            title: 'Privacy Policy',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('View Privacy Policy')));
            },
          ),
          CustomListTile(
            icon: Icons.description,
            title: 'Terms of Service',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('View Terms of Service')));
            },
          ),
          CustomListTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            showArrow: false,
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Account'),
                  content: Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deletion requested'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Help & Support Page
class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Help & Support')),
      body: ListView(
        children: [
          CustomListTile(
            icon: Icons.help,
            title: 'FAQs',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('View FAQs')));
            },
          ),
          CustomListTile(
            icon: Icons.contact_support,
            title: 'Contact Support',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Contact Support')));
            },
          ),
          CustomListTile(
            icon: Icons.bug_report,
            title: 'Report a Bug',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Report a Bug')));
            },
          ),
          CustomListTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Send Feedback')));
            },
          ),
        ],
      ),
    );
  }
}

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 32),
            Icon(Icons.movie, size: 100, color: AppColors.primaryColor),
            SizedBox(height: 16),
            Text(
              'MovieList',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: AppColors.lightGrey),
            ),
            SizedBox(height: 32),
            Text(
              'Your ultimate companion for discovering and organizing movies and TV shows.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            Divider(),
            CustomListTile(
              icon: Icons.info,
              title: 'App Version',
              trailing: '1.0.0',
              showArrow: false,
              onTap: () {},
            ),
            CustomListTile(
              icon: Icons.code,
              title: 'Powered by TMDB',
              showArrow: false,
              onTap: () {},
            ),
            CustomListTile(
              icon: Icons.copyright,
              title: '© 2025 MovieList',
              showArrow: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
