import 'package:arqamy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:arqamy/config/routes/app_router.dart';
import 'package:arqamy/config/routes/routes.dart';
import 'package:arqamy/config/theme/colors.dart';
import 'package:arqamy/core/helpers/spacing.dart';
import 'package:arqamy/core/widgets/textbuilder.dart';
import 'package:arqamy/my_app.dart';
import 'package:share_plus/share_plus.dart';

class SideNav extends StatefulWidget {
  const SideNav({super.key});

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  late DrawersController drawer;
  static bool isCollapse = false;

  void collapseDrawer() {
    setState(() {
      isCollapse = !isCollapse;
    });
  }

  @override
  void initState() {
    super.initState();
    drawer = DrawersController(context);
  }

  @override
  Widget build(BuildContext context) {
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
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 5.0,
                                color: ColorsManager.black,
                                offset: Offset(1.0, 1.0),
                              )
                            ],
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white),
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
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToRoute(context, i);
                    },
                    leading: Icon(
                      drawer.sideDrawer[i].icon,
                      color: ColorsManager.black,
                    ),
                    title: isCollapse
                        ? null
                        : TextBuilder(
                            text: drawer.sideDrawer[i].title!,
                            fontSize: 18.0,
                            color: ColorsManager.black,
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
                leading: const Icon(
                  Icons.power_settings_new,
                  color: ColorsManager.black,
                ),
                title: isCollapse
                    ? null
                    : TextBuilder(
                        text: S.of(context).logout,
                        fontSize: 18.0,
                        color: ColorsManager.black,
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
  String? routeName;
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
    case 5:
      shareApp();
      break;

    // Handle additional cases if necessary
    default:
      routeName = Routes.orderScreen;
  }
  if (routeName != null) {
    Navigator.pushNamed(context, routeName);
  }
}

void shareApp() {
  SharePlus.instance.share(
    ShareParams(
        text:
            'Check out my app: https://play.google.com/store/apps/details?id=com.nahro.arqamy'),
  );
}

class DrawersController {
  final BuildContext context;

  DrawersController(this.context);

  List<DrawerModel> get sideDrawer => [
        DrawerModel(S.of(context).home, Icons.home),
        DrawerModel(S.of(context).suppliers, Icons.receipt_long),
        DrawerModel(S.of(context).inventory, Icons.person),
        DrawerModel(S.of(context).settings, Icons.settings),
        DrawerModel(S.of(context).share_app, Icons.share),
      ];
}

class DrawerModel {
  final String? title;
  final IconData? icon;

  DrawerModel(this.title, this.icon);
}
