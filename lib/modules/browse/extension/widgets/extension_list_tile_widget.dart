import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/fetch_anime_sources.dart';
import 'package:mangayomi/services/fetch_manga_sources.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/fetch_novel_sources.dart';
import 'package:mangayomi/services/fetch_sources_list.dart';
import 'package:mangayomi/utils/cached_network.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/utils/language.dart';

class ExtensionListTileWidget extends ConsumerStatefulWidget {
  final Source source;
  final bool isTestSource;
  final VoidCallback? onInstallComplete;

  const ExtensionListTileWidget({
    super.key,
    required this.source,
    this.isTestSource = false,
    this.onInstallComplete,
  });

  @override
  ConsumerState<ExtensionListTileWidget> createState() => _ExtensionListTileWidgetState();
}

class _ExtensionListTileWidgetState extends ConsumerState<ExtensionListTileWidget> {
  bool _isLoading = false;

  Widget _buildSourceIcon() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: widget.source.iconUrl!.isEmpty
          ? const Icon(Icons.extension_rounded)
          : ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: cachedNetworkImage(
          imageUrl: widget.source.iconUrl!,
          fit: BoxFit.cover,
          width: 40,
          height: 40,
          errorWidget: const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(Icons.extension_rounded),
            ),
          ),
          useCustomNetworkImage: false,
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, {bool isPrimary = false}) {
    return Container(
      height: 32,
      child: TextButton(
        onPressed: _isLoading ? null : () async {
          if (widget.isTestSource || (!_needsUpdate && _isSourceInstalled)) {
            context.push('/extension_detail', extra: widget.source);
          } else {
            await _handleInstallOrUpdate();
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              isPrimary
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  bool get _needsUpdate => !widget.isTestSource &&
      compareVersions(widget.source.version!, widget.source.versionLast!) < 0;

  bool get _isSourceInstalled => widget.source.sourceCode != null &&
      widget.source.sourceCode!.isNotEmpty;

  Future<void> _handleInstallOrUpdate() async {
    setState(() => _isLoading = true);
    try {
      if (widget.source.itemType == ItemType.manga) {
        await ref.watch(
            fetchMangaSourcesListProvider(id: widget.source.id, reFresh: true)
                .future);
      } else if (widget.source.itemType == ItemType.anime) {
        await ref.watch(
            fetchAnimeSourcesListProvider(id: widget.source.id, reFresh: true)
                .future);
      } else {
        await ref.watch(
            fetchNovelSourcesListProvider(id: widget.source.id, reFresh: true)
                .future);
      }
      widget.onInstallComplete?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: _isLoading ? null : () async {
          if (_isSourceInstalled || widget.isTestSource) {
            if (widget.isTestSource) {
              isar.writeTxnSync(() => isar.sources.putSync(widget.source));
            }
            context.push('/extension_detail', extra: widget.source);
          } else {
            await _handleInstallOrUpdate();
          }
        },
        leading: _buildSourceIcon(),
        title: Text(
          widget.source.name!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  completeLanguageName(widget.source.lang!.toLowerCase()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "v${widget.source.version!}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (widget.source.isObsolete ?? false) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "OBSOLETE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildActionButton(
          context,
          widget.isTestSource
              ? l10n.settings
              : !_isSourceInstalled
              ? l10n.install
              : _needsUpdate
              ? l10n.update
              : l10n.settings,
          isPrimary: !_isSourceInstalled || _needsUpdate,
        ),
      ),
    );
  }
}