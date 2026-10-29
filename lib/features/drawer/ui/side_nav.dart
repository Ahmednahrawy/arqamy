import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arqamy/config/routes/app_router.dart';
import 'package:arqamy/config/routes/routes.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/core/widgets/textbuilder.dart';
import 'package:arqamy/my_app.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SideNav extends StatefulWidget {
  const SideNav({super.key});

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  static bool isCollapse = false;
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.nahro.arqamy';
  bool _hasUpdate = false;

  void collapseDrawer() {
    setState(() {
      isCollapse = !isCollapse;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final status = await InAppUpdate.checkForUpdate();
      if (!mounted) return;
      setState(() {
        _hasUpdate =
            status.updateAvailability == UpdateAvailability.updateAvailable;
      });
    } on Exception catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'side navigation',
          context: ErrorDescription('while checking for app updates'),
        ),
      );
    }
  }

  Future<void> _openStoreListing() async {
    try {
      final launched = await launchUrl(
        Uri.parse(_playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('Could not open the app store listing.');
      }
    } on Exception catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'side navigation',
          context: ErrorDescription('while opening the app store listing'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawer = DrawersController(context, hasUpdate: _hasUpdate);
    final colors = Theme.of(context).colorScheme;
    final semanticColors = AppSemanticColors.of(context);
    return Drawer(
      width: isCollapse ? 90 : 180,
      child: Material(
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // logo
              isCollapse
                  ? const Text('Arqamy')
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: 100.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: colors.surface),
                        child: const Center(
                          child: ListTile(
                            leading: CircleAvatar(
                                maxRadius: 55.0,
                                backgroundImage:
                                    AssetImage('assets/images/arqamy.png'),
                                child: Text('')),
                          ),
                        ),
                      ),
                    ),
              //items
              verticalSpace(10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: drawer.sideDrawer.length,
                itemBuilder: (BuildContext context, int i) {
                  return ListTile(
                    onTap: () async {
                      if (i == 4) {
                        final size = MediaQuery.sizeOf(context);
                        final sharePositionOrigin =
                            Rect.fromLTWH(0, 0, size.width, size.height);
                        Navigator.pop(context);
                        shareApp(sharePositionOrigin);
                        return;
                      }
                      Navigator.pop(context);
                      if (i == 5) {
                        await _openStoreListing();
                        return;
                      }
                      _navigateToRoute(context, i);
                    },
                    leading: Icon(
                      drawer.sideDrawer[i].icon,
                      color: i == 5 && _hasUpdate
                          ? semanticColors.warning
                          : colors.onSurface,
                    ),
                    title: isCollapse
                        ? null
                        : TextBuilder(
                            text: drawer.sideDrawer[i].title!,
                            fontSize: 18.0,
                            color: colors.onSurface,
                          ),
                  );
                },
              ),
              ListTile(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MyApp(appRouter: AppRouter())),
                      (route) => false);
                },
                leading: Icon(
                  Icons.power_settings_new,
                  color: colors.onSurface,
                ),
                title: isCollapse
                    ? null
                    : TextBuilder(
                        text: S.of(context).logout,
                        fontSize: 18.0,
                        color: colors.onSurface,
                      ),
              ),
              IconButton(
                  onPressed: collapseDrawer,
                  icon: isCollapse
                      ? const Icon(Icons.arrow_forward_ios)
                      : const Icon(Icons.arrow_back_ios))
            ],
          ),
        )),
      ),
    );
  }
}

void _navigateToRoute(BuildContext context, int index) {
  var routeName = Routes.orderScreen;
  switch (index) {
    case 0:
      routeName = Routes.orderScreen;
      break;
    case 1:
      routeName = Routes.customerScreen;
      break;
    // case 2:
    // routeName = Routes.inventoryScreen;
    // break;
    case 3:
      routeName = Routes.settingsScreen;
      break;
  }
  Navigator.pushNamed(context, routeName);
}

Future<void> shareApp(Rect sharePositionOrigin) async {
  await SharePlus.instance.share(
    ShareParams(
        text:
            'Check out my app: https://play.google.com/store/apps/details?id=com.nahro.arqamy',
        sharePositionOrigin: sharePositionOrigin),
  );
}

class DrawersController {
  final BuildContext context;
  final bool hasUpdate;

  DrawersController(this.context, {this.hasUpdate = false});

  List<DrawerModel> get sideDrawer => [
        DrawerModel(S.of(context).home, Icons.home),
        DrawerModel(S.of(context).suppliers, Icons.receipt_long),
        DrawerModel(S.of(context).inventory, Icons.person),
        DrawerModel(S.of(context).settings, Icons.settings),
        DrawerModel(S.of(context).share_app, Icons.share),
        DrawerModel(
          S.of(context).update_app,
          hasUpdate ? Icons.system_update_alt : Icons.system_update,
        ),
      ];
}

class DrawerModel {
  final String? title;
  final IconData? icon;

  DrawerModel(this.title, this.icon);
}
