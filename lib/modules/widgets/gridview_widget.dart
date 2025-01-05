import 'package:flutter/material.dart';

class GridViewWidget extends StatelessWidget {
  final ScrollController? controller;
  final int? itemCount;
  final bool reverse;
  final double? childAspectRatio;
  final Widget? Function(BuildContext, int) itemBuilder;
  final int? gridSize;

  const GridViewWidget({
    super.key,
    this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.reverse = false,
    this.childAspectRatio = 0.69,
    this.gridSize
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        controller: controller,
        gridDelegate: (gridSize == null || gridSize == 0)
            ? SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: childAspectRatio!,
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        )
            : SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize!,
          childAspectRatio: childAspectRatio!,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: itemBuilder(context, index),
            ),
          );
        },
      ),
    );
  }
}