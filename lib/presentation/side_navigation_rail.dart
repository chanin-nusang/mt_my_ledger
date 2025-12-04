import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mt_my_ledger/core/extensions/screen_utils.dart';
import 'package:mt_my_ledger/generated/locale_keys.g.dart';
import 'package:mt_my_ledger/models/tab_icon_data.dart';

class SideNavigationRail extends StatefulWidget {
  const SideNavigationRail({
    super.key,
    required this.tabIconsList,
    required this.onIndexChanged,
    this.addClick,
    this.user,
  });

  final List<TabIconData> tabIconsList;
  final ValueChanged<int> onIndexChanged;
  final Function()? addClick;
  final User? user;

  @override
  State<SideNavigationRail> createState() => _SideNavigationRailState();
}

class _SideNavigationRailState extends State<SideNavigationRail> {
  final double _railWidth = 168.0;
  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: context.isDesktop,
      minExtendedWidth: _railWidth,
      selectedIndex: widget.tabIconsList.indexWhere(
        (element) => element.isSelected,
      ),
      onDestinationSelected: widget.onIndexChanged,
      labelType: context.isDesktop
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      destinations: widget.tabIconsList.map((e) {
        return NavigationRailDestination(
          padding: EdgeInsets.only(top: 8.0),
          icon: SvgPicture.asset(
            e.imagePath,
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              BlendMode.srcIn,
            ),
          ),
          selectedIcon: SvgPicture.asset(
            e.selectedImagePath,
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          label: Text(_getLabelForIndex(e.index)),
        );
      }).toList(),
      leading: SizedBox(
        width: context.isDesktop ? _railWidth : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 8.0),
                  height: 56,
                  width: 56,
                  // alignment: Alignment.center,s
                  decoration: BoxDecoration(
                    color: Color(0xFF2633C5),
                    gradient: LinearGradient(
                      colors: [Color(0xFF2633C5), Color(0x006a88e5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xFF2633C5).withValues(alpha: 0.4),
                        offset: const Offset(0.0, 8.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withValues(alpha: 0.1),
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: widget.addClick,
                      child: Icon(Icons.add, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return LocaleKeys.home.tr();
      case 1:
        return LocaleKeys.transactions.tr();
      case 2:
        return LocaleKeys.category.tr();
      case 3:
        return LocaleKeys.settings.tr();
      default:
        return '';
    }
  }
}
