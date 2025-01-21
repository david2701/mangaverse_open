import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangayomi/modules/more/about/providers/check_for_update.dart';
import 'package:mangayomi/modules/more/about/providers/get_package_info.dart';
import 'package:mangayomi/modules/widgets/progress_center.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: TextStyle(color: color),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: color.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ref.watch(getPackageInfoProvider).when(
        data: (data) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  l10n!.about,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                background: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Image.asset(
                        "assets/app_icons/icon.png",
                        color: isDarkMode ? Colors.white : Colors.black,
                        height: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'APP INFORMATION',
                    children: [
                      ListTile(
                        title: const Text('Version'),
                        subtitle: Text(
                          'Beta (${data.version})',
                          style: const TextStyle(fontSize: 13),
                        ),
                        leading: const Icon(Icons.info_outline),
                      ),
                      ListTile(
                        title: Text(l10n.check_for_update),
                        leading: const Icon(Icons.system_update_outlined),
                        onTap: () {
                          ref.read(checkForUpdateProvider(
                              context: context, manualUpdate: true));
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildSection(
                    title: 'ATTRIBUTION',
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Original Project',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This application is a fork of Mangayomi, originally created by kodjodevf. We extend our sincere gratitude to the original author and all contributors for their outstanding work and dedication to the open-source community.',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => _launchInBrowser(Uri.parse(
                                    'https://github.com/kodjodevf/mangayomi')),
                                child: Text(
                                  'View Original Project →',
                                  style: TextStyle(
                                    color:
                                    Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildSection(
                    title: 'CONNECT WITH US',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              icon: FontAwesomeIcons.github,
                              label: 'GitHub',
                              color: isDarkMode ? Colors.white : Colors.black,
                              onPressed: () => _launchInBrowser(Uri.parse(
                                  'https://github.com/kodjodevf/mangayomi')),
                            ),
                            _buildSocialButton(
                              icon: FontAwesomeIcons.discord,
                              label: 'Discord',
                              color: const Color(0xFF5865F2),
                              onPressed: () => _launchInBrowser(Uri.parse(
                                  'https://discord.com/invite/EjfBuYahsP')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => ErrorWidget(error),
        loading: () => const ProgressCenter(),
      ),
    );
  }
}

Future<void> _launchInBrowser(Uri url) async {
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}