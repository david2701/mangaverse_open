import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mangayomi/modules/more/widgets/incognito_mode_widget.dart';
import 'package:mangayomi/modules/more/widgets/list_tile_widget.dart';
import 'package:mangayomi/providers/l10n_providers.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
        size: 26,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 22),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                l10n!.more,
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
                const IncognitoModeWidget(),
                const Divider(height: 1),
                _buildSectionHeader(l10n.library, context),
                _buildListTile(
                  icon: Icons.download_outlined,
                  title: l10n.download_queue,
                  onTap: () => context.push('/downloadQueue'),
                  iconColor: Colors.blue,
                ),
                _buildListTile(
                  icon: Icons.label_outline_rounded,
                  title: l10n.categories,
                  onTap: () => context.push('/categories', extra: (false, 0)),
                  iconColor: Colors.orange,
                ),
                _buildListTile(
                  icon: Icons.storage,
                  title: l10n.data_and_storage,
                  onTap: () => context.push('/dataAndStorage'),
                  iconColor: Colors.green,
                ),
                const Divider(height: 32),
                _buildSectionHeader(l10n.settings, context),
                _buildListTile(
                  icon: Icons.settings_outlined,
                  title: l10n.settings,
                  onTap: () => context.push('/settings'),
                  iconColor: Colors.grey,
                ),
                _buildListTile(
                  icon: Icons.info_outline,
                  title: l10n.about,
                  onTap: () => context.push('/about'),
                  iconColor: Colors.purple,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}