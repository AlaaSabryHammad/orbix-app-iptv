import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/design.dart';
import '../../core/l10n/l10n.dart';
import '../../core/session/session.dart';
import '../../data/data.dart';
import '../../shared/widgets/widgets.dart';
import 'providers.dart';

/// Tab-screen header: Unbounded 28 title, then icon actions (Movies/Series).
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final g = OxWindowSize.of(context).gutter;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(g, top + 10, g - 8, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          spacing: 4,
          children: [
            Expanded(child: Semantics(header: true, child: Text(title, style: context.oxText.h1.copyWith(fontSize: 28)))),
            ...actions,
          ],
        ),
      ),
    );
  }
}

/// Categories of [kind] for the chip row (adult ones hidden by the filter).
final categoriesProvider = StreamProvider.autoDispose.family<List<MediaCategory>, ContentKind>((ref, kind) {
  final id = ref.watch(activeAccountIdProvider) ?? '';
  final hidden = ref.watch(hiddenCategoriesProvider(kind)).value ?? const {};
  return ref.watch(catalogRepositoryProvider).watchCategories(id, kind).map((c) => c.where((x) => !hidden.contains(x.id)).toList());
});

/// "All" + one chip per category, horizontally scrolling.
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key, required this.kind, required this.selected, required this.onSelected});

  final ContentKind kind;

  /// Null = All.
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider(kind)).value ?? const [];
    final g = OxWindowSize.of(context).gutter;
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.fromSTEB(g, 18, g, 4),
        itemCount: cats.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => i == 0
            ? OxChip(label: context.l10n.actionAll, selected: selected == null, onTap: () => onSelected(null))
            : OxChip(label: cats[i - 1].name, selected: selected == cats[i - 1].id, onTap: () => onSelected(cats[i - 1].id)),
      ),
    );
  }
}

/// Grid columns for poster grids: 3 on phones, more as space allows (~130 dp).
int posterColumns(double width) => (width / 136).floor().clamp(3, 10);

/// A virtualised poster grid sliver — handles catalogs with thousands of titles.
class PosterGridSliver extends StatelessWidget {
  const PosterGridSliver({super.key, required this.itemCount, required this.itemBuilder, this.captionHeight = 40});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Space for the title / year lines under each poster.
  final double captionHeight;

  @override
  Widget build(BuildContext context) {
    final g = OxWindowSize.of(context).gutter;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: g),
      sliver: SliverLayoutBuilder(
        builder: (context, c) {
          final cols = posterColumns(c.crossAxisExtent);
          final w = (c.crossAxisExtent - 12 * (cols - 1)) / cols;
          return SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 18,
              crossAxisSpacing: 12,
              childAspectRatio: w / (w * 1.5 + 8 + captionHeight),
            ),
            itemCount: itemCount,
            itemBuilder: itemBuilder,
          );
        },
      ),
    );
  }
}

/// Empty category message.
class EmptyCategory extends StatelessWidget {
  const EmptyCategory({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
        child: OxStateView(
          emblem: const OxStateEmblem(icon: OxIcons.film, background: OxColors.ink3, foreground: OxColors.text3),
          title: context.l10n.emptyCategoryTitle,
          message: context.l10n.emptyCategoryBody,
        ),
      );
}

/// Grid / list toggle in a 3 dp-padded Ink 3 well (Movies header).
class ViewToggle extends StatelessWidget {
  const ViewToggle({super.key, required this.grid, required this.onChanged});

  final bool grid;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget button(bool isGrid) {
      final on = grid == isGrid;
      return OxPressable(
        onTap: () => onChanged(isGrid),
        semanticLabel: isGrid ? l.gridView : l.listView,
        selected: on,
        child: AnimatedContainer(
          duration: OxMotion.base,
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: on ? OxColors.ink5 : const Color(0x00000000), borderRadius: BorderRadius.circular(11)),
          child: Center(child: OxIcon(isGrid ? OxIcons.grid : OxIcons.list, size: OxIconSize.sm, color: on ? OxColors.text1 : OxColors.text3)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: OxColors.ink3, borderRadius: BorderRadius.circular(14), border: Border.all(color: OxColors.line)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [button(true), button(false)]),
    );
  }
}
