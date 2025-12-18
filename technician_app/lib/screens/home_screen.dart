import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:technician_app/l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import 'auth/login_screen.dart';
import 'jobs/job_requests_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatusCard(context, jobProvider),
                const SizedBox(height: 24),
                _buildDashboardItem(
                  context,
                  title: l10n.newJobRequest,
                  count: jobProvider.pendingJobs.length,
                  icon: Icons.notifications_active,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JobRequestsScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardItem(
                  context,
                  title: 'Active Jobs',
                  count: jobProvider.activeJobs.length,
                  icon: Icons.work,
                  color: Colors.blue,
                  onTap: () {
                    // TODO: Navigate to Active Jobs list
                  },
                ),
                const SizedBox(height: 16),
                _buildDashboardItem(
                  context,
                  title: l10n.earnings,
                  count: 0, // Placeholder
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  onTap: () {
                    // TODO: Navigate to Earnings
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, JobProvider provider) {
    return Card(
      color: Colors.blue, // TODO: Toggle color based on status
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.white70),
                ),
                Text(
                  'Online', // TODO: Toggle status
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const Spacer(),
            Switch(value: true, onChanged: (val) {}, activeColor: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (count > 0)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
