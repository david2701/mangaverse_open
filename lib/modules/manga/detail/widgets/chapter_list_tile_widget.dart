import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/utils/date.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/utils/extensions/chapter.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:mangayomi/modules/manga/detail/providers/state_providers.dart';
import 'package:mangayomi/modules/manga/download/download_page_widget.dart';

class ChapterListTileWidget extends ConsumerWidget {
  final Chapter chapter;
  final List<Chapter> chapterList;
  final bool sourceExist;
  const ChapterListTileWidget({
    required this.chapterList,
    required this.chapter,
    required this.sourceExist,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLongPressed = ref.watch(isLongPressedStateProvider);
    final l10n = l10nLocalizations(context)!;
    
    return Container(
      color: chapterList.contains(chapter)
          ? context.primaryColor.withValues(alpha: 0.4)
          : null,
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            textColor: chapter.isRead!
                ? context.isLight
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.3)
                : null,
            selectedColor: chapter.isRead!
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white,
            onLongPress: () {
              if (!isLongPressed) {
                ref.read(chaptersListStateProvider.notifier).update(chapter);
                ref.read(isLongPressedStateProvider.notifier).update(!isLongPressed);
              } else {
                ref.read(chaptersListStateProvider.notifier).update(chapter);
              }
            },
            onTap: () async {
              if (isLongPressed) {
                ref.read(chaptersListStateProvider.notifier).update(chapter);
              } else {
                chapter.pushToReaderView(context, ignoreIsRead: true);
              }
            },
            leading: GestureDetector(
              onTap: () async {
                chapter.isRead = !chapter.isRead!;
                await chapter.update();
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: chapter.isRead! 
                        ? Colors.grey[400]!
                        : context.isLight 
                            ? Colors.grey.withOpacity(0.5)
                            : Colors.grey[400]!,
                    width: 2,
                  ),
                  color: chapter.isRead! ? Colors.grey[400] : Colors.transparent,
                ),
                child: chapter.isRead!
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            title: Row(
              children: [
                if (chapter.isBookmarked!) 
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.bookmark,
                      size: 16,
                      color: context.primaryColor,
                    ),
                  ),
                Expanded(
                  child: Text(
                    chapter.name!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: chapter.isRead! ? FontWeight.normal : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: DefaultTextStyle(
              style: TextStyle(
                fontSize: 12,
                color: chapter.isRead!
                    ? context.isLight
                        ? Colors.black.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.3)
                    : Colors.grey[600],
              ),
              child: Row(
                children: [
                  if ((chapter.manga.value!.isLocalArchive ?? false) == false)
                    Text(
                      chapter.dateUpload == null || chapter.dateUpload!.isEmpty
                          ? ""
                          : dateFormat(chapter.dateUpload!, ref: ref, context: context),
                    ),
                  _buildProgressIndicator(chapter, l10n, context),
                  _buildScanlator(chapter, context),
                ],
              ),
            ),
            trailing: !sourceExist || (chapter.manga.value!.isLocalArchive ?? false)
                ? null
                : ChapterPageDownload(chapter: chapter),
          ),
          if (chapter.isRead!)
            Positioned(
              top: 4,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.read,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Chapter chapter, dynamic l10n, BuildContext context) {
    if (chapter.isRead! || chapter.lastPageRead!.isEmpty || chapter.lastPageRead == "1") {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(' • '),
        Text(
          chapter.manga.value!.itemType == ItemType.anime
              ? l10n.episode_progress(
                  Duration(milliseconds: int.parse(chapter.lastPageRead!))
                      .toString()
                      .substringBefore("."))
              : l10n.page(chapter.manga.value!.itemType == ItemType.manga
                  ? chapter.lastPageRead!
                  : "${((double.tryParse(chapter.lastPageRead!) ?? 0) * 100).toStringAsFixed(0)} %"),
        ),
      ],
    );
  }

  Widget _buildScanlator(Chapter chapter, BuildContext context) {
    if (!(chapter.scanlator?.isNotEmpty ?? false)) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(' • '),
        Text(chapter.scanlator!),
      ],
    );
  }
}
