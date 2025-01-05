import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/more/settings/reader/providers/reader_state_provider.dart';
import 'package:mangayomi/modules/widgets/loading_icon.dart';
import 'package:mangayomi/services/fetch_anime_sources.dart';
import 'package:mangayomi/services/fetch_manga_sources.dart';
import 'package:mangayomi/modules/main_view/providers/migration.dart';
import 'package:mangayomi/modules/more/about/providers/check_for_update.dart';
import 'package:mangayomi/modules/more/data_and_storage/providers/auto_backup.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/router/router.dart';
import 'package:mangayomi/services/fetch_novel_sources.dart';
import 'package:mangayomi/services/fetch_sources_list.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/modules/library/providers/library_state_provider.dart';
import 'package:mangayomi/modules/more/providers/incognito_mode_state_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'dart:ui';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with SingleTickerProviderStateMixin {
  String getHyphenatedUpdatesLabel(String languageCode, String defaultLabel) {
    switch (languageCode) {
      case 'de':
        return "Aktuali-\nsierungen";
      case 'es':
      case 'es_419':
        return "Actuali-\nzaciones";
      case 'it':
        return "Aggiorna-\nmenti";
      case 'tr':
        return "Güncel-\nlemeler";
      default:
        return defaultLabel;
    }
  }

  late bool hideManga = ref.watch(hideMangaStateProvider);
  late bool hideAnime = ref.watch(hideAnimeStateProvider);
  late bool hideNovel = ref.watch(hideNovelStateProvider);
  late String? location =
      ref.watch(routerCurrentLocationStateProvider(context));
  late String defaultLocation = hideManga
      ? hideAnime
          ? hideNovel
              ? '/more'
              : '/NovelLibrary'
          : '/AnimeLibrary'
      : '/MangaLibrary';
  bool _isMenuVisible = false;
  late final AnimationController _menuController;
  late final Animation<double> _menuAnimation;
  bool _isScrollingDown = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_scrollListener);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(defaultLocation);

      Timer.periodic(Duration(minutes: 5), (timer) {
        ref.read(checkAndBackupProvider);
      });
      ref.watch(checkForUpdateProvider(context: context));
      ref.watch(fetchMangaSourcesListProvider(id: null, reFresh: false));
      ref.watch(fetchAnimeSourcesListProvider(id: null, reFresh: false));
      ref.watch(fetchNovelSourcesListProvider(id: null, reFresh: false));
    });
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (!_isScrollingDown) {
        setState(() {
          _isScrollingDown = true;
        });
      }
    }
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (_isScrollingDown) {
        setState(() {
          _isScrollingDown = false;
        });
      }
    }
  }

  Widget _buildFloatingNavigationBar(List<String> dest, int currentIndex, AppLocalizations l10n) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      bottom: _isScrollingDown ? -80 : 16,
      left: 16,
      right: 16,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _buildNavigationBarDestinations(l10n, ref).length,
                (index) {
                  final destination = _buildNavigationBarDestinations(l10n, ref)[index];
                  final isSelected = currentIndex == index;
                  
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go(dest[index]),
                        customBorder: const CircleBorder(),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isSelected 
                                  ? (destination.selectedIcon ?? destination.icon)
                                  : destination.icon,
                              if (isSelected)
                                DefaultTextStyle(
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Text(
                                    destination.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuVisible = !_isMenuVisible;
      if (_isMenuVisible) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  void _showBottomMenu(BuildContext context, List<String> dest, int currentIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => NavigationDrawer(
        selectedIndex: currentIndex,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              'Mangayomi',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          ...List.generate(
            _buildNavigationBarDestinations(context.l10n, ref).length,
            (index) {
              final destination = _buildNavigationBarDestinations(context.l10n, ref)[index];
              return NavigationDrawerDestination(
                icon: destination.icon,
                selectedIcon: destination.selectedIcon,
                label: Text(destination.label),
              );
            },
          ),
        ],
        onDestinationSelected: (index) {
          context.pop();
          context.go(dest[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final route = GoRouter.of(context);
    location = ref.watch(routerCurrentLocationStateProvider(context));
    return ref.watch(migrationProvider).when(data: (_) {
      return Consumer(builder: (context, ref, child) {
        hideManga = ref.watch(hideMangaStateProvider);
        hideAnime = ref.watch(hideAnimeStateProvider);
        hideNovel = ref.watch(hideNovelStateProvider);
        bool isReadingScreen = location == '/mangaReaderView' ||
            location == '/animePlayerView' ||
            location == '/novelReaderView';
        final dest = [
          '/MangaLibrary',
          '/AnimeLibrary',
          '/NovelLibrary',
          '/updates',
          '/history',
          '/browse',
          '/more'
        ];
        if (hideManga) {
          dest.removeWhere((d) => d == "/MangaLibrary");
        }
        if (hideAnime) {
          dest.removeWhere((d) => d == "/AnimeLibrary");
        }
        if (hideNovel) {
          dest.removeWhere((d) => d == "/NovelLibrary");
        }
        int currentIndex = dest.indexOf(location ?? defaultLocation);
        if (currentIndex == -1) {
          currentIndex = dest.length - 1;
        }

        final incognitoMode = ref.watch(incognitoModeStateProvider);
        final isLongPressed = ref.watch(isLongPressedMangaStateProvider);
        return Column(
          children: [
            if (!isReadingScreen)
              Material(
                child: AnimatedContainer(
                  height: incognitoMode
                      ? Platform.isAndroid || Platform.isIOS
                          ? MediaQuery.of(context).padding.top * 2
                          : 50
                      : 0,
                  curve: Curves.easeIn,
                  duration: const Duration(milliseconds: 150),
                  color: context.primaryColor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          l10n.incognito_mode,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: GoogleFonts.aBeeZee().fontFamily,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Scaffold(
                body: Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification is ScrollUpdateNotification) {
                          setState(() {
                            _isScrollingDown = scrollNotification.scrollDelta! > 0;
                          });
                        }
                        return true;
                      },
                      child: Row(
                        children: [
                          if (context.isTablet) 
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: switch (isLongPressed) {
                                true => 0,
                                _ => switch (location) {
                                    null => 80,
                                    != '/MangaLibrary' &&
                                          != '/AnimeLibrary' &&
                                          != '/NovelLibrary' &&
                                          != '/history' &&
                                          != '/updates' &&
                                          != '/browse' &&
                                          != '/more' =>
                                        0,
                                    _ => MediaQuery.of(context).size.width > 1200 ? 200 : 80,
                                  },
                              },
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: NavigationRail(
                                extended: MediaQuery.of(context).size.width > 1200,
                                minExtendedWidth: 200,
                                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                                labelType: MediaQuery.of(context).size.width > 1200 
                                    ? NavigationRailLabelType.none 
                                    : NavigationRailLabelType.selected,
                                useIndicator: true,
                                indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
                                destinations: _buildNavigationRailDestinations(l10n, ref),
                                selectedIndex: currentIndex,
                                onDestinationSelected: (newIndex) {
                                  route.go(dest[newIndex]);
                                },
                              ),
                            ),
                          Expanded(
                            child: widget.child,
                          ),
                        ],
                      ),
                    ),
                    if (!context.isTablet)
                      _buildFloatingNavigationBar(dest, currentIndex, l10n),
                  ],
                ),
              ),
            ),
          ],
        );
      });
    }, error: (error, _) {
      return const LoadingIcon();
    }, loading: () {
      return const LoadingIcon();
    });
  }

  List<NavigationRailDestination> _buildNavigationRailDestinations(AppLocalizations l10n, WidgetRef ref) {
    return [
      if (!hideManga)
        NavigationRailDestination(
          selectedIcon: const Icon(Icons.collections_bookmark),
          icon: const Icon(Icons.collections_bookmark_outlined),
          label: Text(l10n.manga),
        ),
      if (!hideAnime)
        NavigationRailDestination(
          selectedIcon: const Icon(Icons.video_collection),
          icon: const Icon(Icons.video_collection_outlined),
          label: Text(l10n.anime),
        ),
      if (!hideNovel)
        NavigationRailDestination(
          selectedIcon: const Icon(Icons.local_library),
          icon: const Icon(Icons.local_library_outlined),
          label: Text(l10n.novel),
        ),
      NavigationRailDestination(
        selectedIcon: _updatesTotalNumbers(ref, Icon(Icons.new_releases)),
        icon: _updatesTotalNumbers(ref, Icon(Icons.new_releases_outlined)),
        label: Text(l10n.updates),
      ),
      NavigationRailDestination(
        selectedIcon: const Icon(Icons.history),
        icon: const Icon(Icons.history_outlined),
        label: Text(l10n.history),
      ),
      NavigationRailDestination(
        selectedIcon: _extensionUpdateTotalNumbers(ref, Icon(Icons.explore)),
        icon: _extensionUpdateTotalNumbers(ref, Icon(Icons.explore_outlined)),
        label: Text(l10n.browse),
      ),
      NavigationRailDestination(
        selectedIcon: const Icon(Icons.more_horiz),
        icon: const Icon(Icons.more_horiz_outlined),
        label: Text(l10n.more),
      ),
    ];
  }

  List<NavigationDestination> _buildNavigationBarDestinations(AppLocalizations l10n, WidgetRef ref) {
    return [
      if (!hideManga)
        NavigationDestination(
          selectedIcon: const Icon(Icons.collections_bookmark),
          icon: const Icon(Icons.collections_bookmark_outlined),
          label: l10n.manga,
        ),
      if (!hideAnime)
        NavigationDestination(
          selectedIcon: const Icon(Icons.video_collection),
          icon: const Icon(Icons.video_collection_outlined),
          label: l10n.anime,
        ),
      if (!hideNovel)
        NavigationDestination(
          selectedIcon: const Icon(Icons.local_library),
          icon: const Icon(Icons.local_library_outlined),
          label: l10n.novel,
        ),
      NavigationDestination(
        selectedIcon: _updatesTotalNumbers(ref, Icon(Icons.new_releases)),
        icon: _updatesTotalNumbers(ref, Icon(Icons.new_releases_outlined)),
        label: l10n.updates,
      ),
      NavigationDestination(
        selectedIcon: const Icon(Icons.history),
        icon: const Icon(Icons.history_outlined),
        label: l10n.history,
      ),
      NavigationDestination(
        selectedIcon: _extensionUpdateTotalNumbers(ref, Icon(Icons.explore)),
        icon: _extensionUpdateTotalNumbers(ref, Icon(Icons.explore_outlined)),
        label: l10n.browse,
      ),
      NavigationDestination(
        selectedIcon: const Icon(Icons.more_horiz),
        icon: const Icon(Icons.more_horiz_outlined),
        label: l10n.more,
      ),
    ];
  }
}

Widget _extensionUpdateTotalNumbers(WidgetRef re, Widget widget) {
  return StreamBuilder(
      stream: isar.sources
          .filter()
          .idIsNotNull()
          .and()
          .isActiveEqualTo(true)
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final entries = snapshot.data!
              .where((element) =>
                  compareVersions(element.version!, element.versionLast!) < 0)
              .toList();
          if (entries.isEmpty) {
            return widget;
          }
          return Badge(label: Text("${entries.length}"), child: widget);
        }
        return widget;
      });
}

Widget _updatesTotalNumbers(WidgetRef ref, Widget widget) {
  return StreamBuilder(
      stream: isar.updates.filter().idIsNotNull().watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final entries = snapshot.data!.where((element) {
            if (!element.chapter.isLoaded) {
              element.chapter.loadSync();
            }
            return !(element.chapter.value?.isRead ?? false);
          }).toList();
          if (entries.isEmpty) {
            return widget;
          }
          return Badge(label: Text("${entries.length}"), child: widget);
        }
        return widget;
      });
}
