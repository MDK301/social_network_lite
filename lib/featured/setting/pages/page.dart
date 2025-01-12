import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_network_lite/responsive/constrainEdgeInsets_scaffold.dart';
import 'package:social_network_lite/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // theme cubit
    final themeCubit = context.watch<ThemeCubit>();

    // is dark mode
    bool isDarkMode = themeCubit.isDarkMode;

    // SCAFFOLD
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ), // AppBar
      body: Column(
        children: [
          // dark mode tile
          ListTile(
            title: Text("Dark Mode"),
            trailing: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) {
                themeCubit.toggleTheme();
              },
            ),
          ),
          IconButton(onPressed: (){DatabaseReference ref = FirebaseDatabase.instance.ref("test");

          ref.set({
            "name": "Test User",
            "isOnline": true
          }).then((_) {
            print("Data written successfully!");
          }).catchError((error) {
            print("Failed to write data: $error");
          });
          }, icon: Icon(Icons.table_rows,size: 350,))
        ],
      ),
    );
  }
}
