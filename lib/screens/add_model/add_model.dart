import 'package:amallo/screens/add_model/create_model/create_model_page.dart';
import 'package:amallo/screens/add_model/download_model/download_model.dart';
import 'package:flutter/material.dart';

import '../../extensions/colors.dart';

class AddModelScreen extends StatefulWidget {
  static const routeName = 'addModel';

  const AddModelScreen({super.key});

  @override
  State<AddModelScreen> createState() => _AddModelScreenState();
}

class _AddModelScreenState extends State<AddModelScreen> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue,
            AppColors.turquoise,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.1, 0.9],
        ),
      ),
      child: DefaultTabController(
        length: 2, // This number must match the number of tabs.
        child: Scaffold(
          backgroundColor: Colors.black26,
          appBar: buildAppBar(),
          body: NestedScrollView(
            // Add the NestedScrollView widget.
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[];
            },
            body: const TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                DownloadModelPage(),
                CreateModelPage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: const Text('Add Model'),
      bottom: buildTabBar(),
    );
  }

  TabBar buildTabBar() {
    return const TabBar(
      tabs: [
        Tab(text: 'Download'),
        Tab(text: 'Create'),
      ],
    );
  }
}
