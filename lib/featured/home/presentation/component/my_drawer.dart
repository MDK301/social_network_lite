import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/featured/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_network_lite/featured/chat/presentation/pages/all_chat_page.dart';
import 'package:social_network_lite/featured/friend_list/page/friend_list_page.dart';
import 'package:social_network_lite/featured/profile/presentation/pages/profile_page.dart';
import 'package:social_network_lite/featured/search/presentation/pages/search_page.dart';
import 'package:social_network_lite/featured/setting/pages/page.dart';

import '../../../../config/user_status_service.dart';
import '../../../auth/domain/entities/app_user.dart';
import 'my_drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    late final authCubit = context.read<AuthCubit>();
    late AppUser? currentUser = authCubit.currentUser;
    final UserStatusService _userStatusService = UserStatusService();
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              //divider line
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),

              // home tile
              MyDrawerTile(
                title: "H O M E",
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),

              // profile tile
              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
                onTap: () {
                  //pop menu drawer
                  Navigator.of(context).pop();

                  //get current user uid
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  //nagivator to page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        uid: uid,
                      ),
                    ),
                  );
                },
              ),

              // messenger tile
              MyDrawerTile(
                title: "M E S S E N G E R",
                icon: Icons.message,
                onTap: () {
                  //pop menu drawer
                  Navigator.of(context).pop();

                  //get current user uid
                  final user = context.read<AuthCubit>().currentUser;
                  String? uid = user!.uid;

                  //nagivator to page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllChatPage(
                        uid: uid,
                      ),
                    ),
                  );
                },
              ),

              // friend list tile
              MyDrawerTile(
                title: "F R I E N D  L I S T",
                icon: Icons.list,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FriendListPage()));
                },
              ),

              // search tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Icons.search,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SearchPage()));
                },
              ),

              // settings tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {   Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));},
              ),

              const Spacer(),

              // logout tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.logout,
                onTap: () {
                  context.read<AuthCubit>().logout();


                  _userStatusService.setOffline(currentUser!.uid);
                  authCubit.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
