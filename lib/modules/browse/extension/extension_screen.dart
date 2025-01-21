import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:collection/collection.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/extension/providers/extensions_provider.dart';
import 'package:mangayomi/services/fetch_anime_sources.dart';
import 'package:mangayomi/services/fetch_manga_sources.dart';
import 'package:mangayomi/modules/widgets/progress_center.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/fetch_novel_sources.dart';
import 'package:mangayomi/services/fetch_sources_list.dart';
import 'package:mangayomi/utils/language.dart';
import 'package:mangayomi/modules/browse/extension/widgets/extension_list_tile_widget.dart';

class ExtensionScreen extends ConsumerStatefulWidget {
  final ItemType itemType;
  final String query;
  const ExtensionScreen({required this.query, required this.itemType, super.key});

  @override
  ConsumerState<ExtensionScreen> createState() => _ExtensionScreenState();
}

class _ExtensionScreenState extends ConsumerState<ExtensionScreen> {
  final ScrollController controller = ScrollController();

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildUpdateAllButton(List<Source> updateEntries, BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        for (var source in updateEntries) {
          if (source.itemType == ItemType.manga) {
            await ref.watch(
                fetchMangaSourcesListProvider(id: source.id, reFresh: true)
                    .future);
          } else if (source.itemType == ItemType.anime) {
            await ref.watch(
                fetchAnimeSourcesListProvider(id: source.id, reFresh: true)
                    .future);
          } else {
            await ref.watch(
                fetchNovelSourcesListProvider(id: source.id, reFresh: true)
                    .future);
          }
        }
      },
      icon: const Icon(Icons.system_update_outlined, size: 18),
      label: Text(context.l10n.update_all),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load extensions',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                if (widget.itemType == ItemType.manga) {
                  ref.invalidate(
                      fetchMangaSourcesListProvider(id: null, reFresh: true));
                } else if (widget.itemType == ItemType.anime) {
                  ref.invalidate(
                      fetchAnimeSourcesListProvider(id: null, reFresh: true));
                } else {
                  ref.invalidate(
                      fetchNovelSourcesListProvider(id: null, reFresh: true));
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Source> sources,
    Widget? trailing,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16),
  }) {
    if (sources.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, trailing: trailing),
          Container(
            margin: padding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: sources.map((source) => ExtensionListTileWidget(
                source: source,
                onInstallComplete: () => setState(() {}),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streamExtensions =
    ref.watch(getExtensionsStreamProvider(widget.itemType));

    // Watch appropriate provider based on itemType
    if (widget.itemType == ItemType.manga) {
      ref.watch(fetchMangaSourcesListProvider(id: null, reFresh: false));
    } else if (widget.itemType == ItemType.anime) {
      ref.watch(fetchAnimeSourcesListProvider(id: null, reFresh: false));
    } else {
      ref.watch(fetchNovelSourcesListProvider(id: null, reFresh: false));
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.itemType == ItemType.manga) {
          return ref.refresh(
              fetchMangaSourcesListProvider(id: null, reFresh: true).future);
        } else if (widget.itemType == ItemType.anime) {
          return ref.refresh(
              fetchAnimeSourcesListProvider(id: null, reFresh: true).future);
        } else {
          return ref.refresh(
              fetchNovelSourcesListProvider(id: null, reFresh: true).future);
        }
      },
      child: streamExtensions.when(
        data: (data) {
          // Filter data based on search query
          final filteredData = widget.query.isEmpty
              ? data
              : data
              .where((element) => element.name!
              .toLowerCase()
              .contains(widget.query.toLowerCase()))
              .toList();

          // Separate entries into categories
          final notInstalledEntries = filteredData
              .where((element) =>
          element.version == element.versionLast! && !element.isAdded!)
              .toList();
          final installedEntries = filteredData
              .where((element) =>
          element.version == element.versionLast! && element.isAdded!)
              .toList();
          final updateEntries = filteredData
              .where((element) =>
          compareVersions(element.version!, element.versionLast!) < 0)
              .toList();

          // Group not installed entries by language using collection package
          final groupedNotInstalled = notInstalledEntries.groupListsBy(
                  (source) => completeLanguageName(source.lang!.toLowerCase()));

          return Scrollbar(
            controller: controller,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              children: [
                if (updateEntries.isNotEmpty)
                  _buildSection(
                    title: context.l10n.update_pending,
                    sources: updateEntries,
                    trailing: _buildUpdateAllButton(updateEntries, context),
                  ),
                if (installedEntries.isNotEmpty)
                  _buildSection(
                    title: context.l10n.installed,
                    sources: installedEntries,
                  ),
                ...groupedNotInstalled.entries.map(
                      (entry) => _buildSection(
                    title: entry.key,
                    sources: entry.value,
                  ),
                ),
                if (filteredData.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.extension_off,
                            size: 48,
                            color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No extensions found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        error: (error, _) => _buildErrorState(context),
        loading: () => const ProgressCenter(),
      ),
    );
  }
}