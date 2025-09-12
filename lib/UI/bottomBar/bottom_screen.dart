import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:talknep/components/common_appbar.dart';
import 'package:talknep/gen/assets.gen.dart';
import 'package:talknep/l10n/app_localizations.dart';
import 'package:talknep/provider/bottomBar/bottomBar_provider.dart';
import 'package:talknep/util/theme_extension.dart';
import 'package:talknep/widget/app_sizer.dart';

class BottomBarScreen extends StatelessWidget {
  BottomBarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Consumer<BottomBarProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar:
              provider.currentIndex == 1
                  ? AppBar(toolbarHeight: 0)
                  : CommonAppBar(index: provider.currentIndex),
          body: provider.pages[provider.currentIndex],
          backgroundColor: context.scaffoldBackgroundColor,
          bottomNavigationBar: BottomNavigationBar(
            onTap: (index) => provider.changeIndex(context, index),
            type: BottomNavigationBarType.fixed,
            currentIndex: provider.currentIndex,
            backgroundColor: context.colorsScheme.surface,
            selectedItemColor:
                Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
            selectedLabelStyle: GoogleFonts.poppins(
              color: context.colorsScheme.primary,
              fontSize: Sizer.sp(2.5),
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: Sizer.sp(2.5),
              color:
                  Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor,
            ),
            items: [
              BottomNavigationBarItem(
                label: local.home,

                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Assets.icon.homeIcon.image(
                    width: 24,
                    height: 24,
                    color:
                        provider.currentIndex == 0
                            ? context.colorsScheme.primary
                            : context.colorsScheme.onSurface,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: local.reel,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Assets.icon.sparkIcon.image(
                    width: 24,
                    height: 24,
                    color:
                        provider.currentIndex == 1
                            ? context.colorsScheme.primary
                            : context.colorsScheme.onSurface,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: local.video,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Assets.icon.reelIcon.image(
                    width: 24,
                    height: 24,
                    color:
                        provider.currentIndex == 2
                            ? context.colorsScheme.primary
                            : context.colorsScheme.onSurface,
                  ),
                ),
              ),

              BottomNavigationBarItem(
                label: local.store,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Assets.icon.marketplaceIcon.image(
                    width: 24,
                    height: 24,
                    color:
                        provider.currentIndex == 3
                            ? context.colorsScheme.primary
                            : context.colorsScheme.onSurface,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: local.notification,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Assets.icon.notificationIcon.image(
                    width: 24,
                    height: 24,
                    color:
                        provider.currentIndex == 4
                            ? context.colorsScheme.primary
                            : context.colorsScheme.onSurface,
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: local.menu,
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Assets.icon.menuIcon.image(
                    width: 24,
                    height: 24,
                    color:
                        provider.currentIndex == 5
                            ? context.colorsScheme.primary
                            : context.colorsScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
