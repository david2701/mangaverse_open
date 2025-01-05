import 'dart:io';

import 'package:draggable_menu/draggable_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/router/router.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';

class MeasureWidgetSize extends StatefulWidget {
  final Function(Size? size) onCalculateSize;
  final Widget child;

  const MeasureWidgetSize(
      {super.key, required this.onCalculateSize, required this.child});

  @override
  State<MeasureWidgetSize> createState() => _MeasureWidgetSizeState();
}

class _MeasureWidgetSizeState extends State<MeasureWidgetSize> {
  final _key = GlobalKey();

  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onCalculateSize(_key.currentContext?.size));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(key: _key, child: widget.child);
  }
}

Future<void> customDraggableTabBar(
    {required List<Widget> tabs,
    required List<Widget> children,
    required BuildContext context,
    required TickerProvider vsync,
    bool fullWidth = false,
    Widget? moreWidget}) async {
  final controller = DraggableMenuController();
  late TabController tabBarController;
  tabBarController = TabController(length: tabs.length, vsync: vsync);
  final maxHeight = context.height(0.5);
  final minHeight = context.height(0.3);

  int index = 0;
  List<Map<String, dynamic>> widgetsHeight = [];

  void refresh() {
    if (widgetsHeight.isEmpty) return;
    final targetIndex = widgetsHeight.indexWhere((element) => element["index"] == index);
    if (targetIndex >= 0) {
      try {
        controller.animateTo(targetIndex);
      } catch (_) {
        // Ignorar errores si el controlador no está listo
      }
    }
  }

  tabBarController.animation!.addListener(() {
    final currentIndex = tabBarController.animation!.value.round();
    index = tabBarController.index;
    if (index != currentIndex) {
      index = currentIndex;
      refresh();
    } else {
      refresh();
    }
  });

  await showDialog(
    context: context,
    builder: (context) {
      return Material(
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              MeasureWidgetSize(
                onCalculateSize: (size) {
                  if (size == null) return;
                  double newHeight = size.height + 52.0;
                  newHeight = newHeight.clamp(minHeight, maxHeight);
                  widgetsHeight.add({"index": i, "height": newHeight});
                  if (widgetsHeight.length == children.length) {
                    Navigator.pop(context);
                  }
                },
                child: children[i],
              )
            ]
          ],
        ),
      );
    },
  );

  if (widgetsHeight.isEmpty) {
    widgetsHeight.add({"index": 0, "height": minHeight});
  }

  widgetsHeight.sort((a, b) => (a["height"] as double).compareTo(b["height"] as double));

  if (context.mounted) {
    await DraggableMenu.open(
      context,
      DraggableMenu(
        curve: Curves.linearToEaseOut,
        controller: controller,
        levels: widgetsHeight
            .map((e) => DraggableMenuLevel(height: e["height"] as double))
            .toList(),
        customUi: Consumer(builder: (context, ref, child) {
          final location = ref.watch(routerCurrentLocationStateProvider(context));
          final width = context.isTablet && !fullWidth
              ? switch (location) {
                  null => 100,
                  != '/MangaLibrary' &&
                        != '/AnimeLibrary' &&
                        != '/history' &&
                        != '/browse' &&
                        != '/more' =>
                    0,
                  _ => 100,
                }
              : 0;

          return Scaffold(
            backgroundColor: Platform.isLinux ? null : Colors.transparent,
            body: Container(
              width: context.width(1) - width,
              constraints: BoxConstraints(
                minHeight: minHeight,
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Barra superior con indicador de arrastre
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  
                  // TabBar mejorado
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                            child: TabBar(
                              controller: tabBarController,
                              tabs: tabs,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                              ),
                              labelColor: Theme.of(context).primaryColor,
                              unselectedLabelColor: Theme.of(context).hintColor,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                          ),
                        ),
                        if (moreWidget != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: moreWidget,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Contenido con más espacio
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBarView(
                        controller: tabBarController,
                        children: children.map((e) => SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: MeasureWidgetSize(
                              onCalculateSize: (_) => refresh(),
                              child: e,
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        child: const SizedBox.shrink(),
      ),
    );
  }
}
