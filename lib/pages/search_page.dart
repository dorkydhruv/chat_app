import 'package:chat_app/helper/helper_func.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets.dart/widgets.dart';
// import 'package:chat_app/widgets.dart/group_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  QuerySnapshot? querySnapshot;
  bool hasUserSearched = false;
  String userName = '';
  User? user;
  bool isJoined = false;

  @override
  void initState() {
    super.initState();

    getCurrentUserIdandname();
  }

  getCurrentUserIdandname() async {
    await HelperFunction.getUserUsernameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  String getName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'Search',
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white, fontSize: 15),
                    hintText: 'Search groups...',
                  ),
                )),
                GestureDetector(
                  onTap: () => initiateSearch(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ))
              : groupList(),
        ],
      ),
    );
  }

  initiateSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      await DatabseService().searchByName(searchController.text).then((val) {
        setState(() {
          _isLoading = false;
          querySnapshot = val;
          hasUserSearched = true;
        });
        print('helo');
      });
    } else {
      return const Text('NOTHING TO SEARCH.');
    }
  }

  Widget groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemBuilder: (ctc, index) {
              return groupTile(
                userName: userName,
                groupId: querySnapshot!.docs[index]['groupId'],
                groupName: querySnapshot!.docs[index]['groupName'],
                admin: querySnapshot!.docs[index]['admin'],
              );
            },
            itemCount: querySnapshot!.docs.length,
          )
        : Container(
            color: Colors.white,
          );
  }

  joinedOrnot(
      String userName, String groupId, String groupName, String admin) async {
    await DatabseService(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTile({
    String? userName,
    String? groupId,
    String? groupName,
    String? admin,
  }) {
    //user joined or not?
    joinedOrnot(userName!, groupId!, groupName!, admin!);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('Admin: ${getName(admin)}'),
      trailing: InkWell(
        onTap: () async {
          await DatabseService(uid: user!.uid)
              .toggleGroupJoin(groupId, userName, groupName);
          if (isJoined) {
            setState(() {
              isJoined = !isJoined;
            });
            // ignore: use_build_context_synchronously
            showSnackBar(
                context, Colors.green, "Successfully joined the group");
            Future.delayed(const Duration(seconds: 2), () {
              nextScreen(
                  context,
                  ChatPage(
                      groupId: groupId,
                      groupName: groupName,
                      userName: userName));
            });
          } else {
            setState(() {
              isJoined = !isJoined;
              showSnackBar(context, Colors.red, "Left the group $groupName");
            });
          }
        },
        child: isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black,
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.rectangle),
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Joined :)',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).primaryColor,
                ),
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Join now ..',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
