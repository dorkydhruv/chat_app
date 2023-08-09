import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';

import '../widgets.dart/widgets.dart';
import 'login_in_page.dart';

class ProfilePage extends StatefulWidget {
  final userName;
  final emial;
  const ProfilePage(this.userName, this.emial, {super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
              fontSize: 27, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Text(widget.userName!,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              // titleAlignment: ListTileTitleAlignment.top,
              onTap: () {
                nextScreen(context, const HomePage());
              },
              selectedColor: Theme.of(context).primaryColor,
              title: const Text(
                'Groups',
                style: TextStyle(color: Colors.black),
              ),
              // selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
            ),
            ListTile(
              // titleAlignment: ListTileTitleAlignment.top,
              onTap: () {
                // nextScreen(context, ProfilePage());
              },
              selectedColor: Theme.of(context).primaryColor,
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.black),
              ),
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.account_circle),
            ),
            ListTile(
              // titleAlignment: ListTileTitleAlignment.top,
              onTap: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text('Logout?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            authService.signOut().whenComplete(() {
                              nextScreenReplace(context, const LoginInPage());
                            });
                          },
                          child: const Text('Yes')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('No')),
                    ],
                  ),
                );
              },
              selectedColor: Theme.of(context).primaryColor,
              title: const Text(
                'LogOut',
                style: TextStyle(color: Colors.black),
              ),
              // selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.account_circle_rounded,
              size: 200,
              color: Colors.grey[700],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Full name',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 2,
              height: 20,
              color: Colors.amberAccent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  widget.emial,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
