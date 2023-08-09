import 'package:chat_app/pages/group_info_page.dart';
import 'package:chat_app/service/database_service.dart';
import 'package:chat_app/widgets.dart/message_tile.dart';
import 'package:chat_app/widgets.dart/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final groupId;
  final groupName;
  final userName;
  const ChatPage(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.userName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageController = TextEditingController();
  String admin = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChatAndAdmin();
  }

  getChatAndAdmin() {
    DatabseService().getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabseService().getGrpAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(widget.groupName),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(
                    context,
                    GroupInfoPage(
                        adminName: admin,
                        groupId: widget.groupId,
                        groupName: widget.groupName));
              },
              icon: Icon(Icons.info))
        ],
      ),
      body: Stack(
        children: [
          //chat messages
          chatMessages(),
          Container(
            alignment: Alignment.bottomCenter,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                        hintText: 'Send a message',
                        hintStyle: TextStyle(fontSize: 16),
                        border: InputBorder.none),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                GestureDetector(
                  onTap: () {
                    sendMessages();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(60)),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
        stream: chats,
        builder: (ctc, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (ctc, index) {
                    return MessageTile(
                        message: snapshot.data.docs[index]['message'],
                        sender: snapshot.data.docs[index]['sender'],
                        sentByme: widget.userName ==
                            snapshot.data.docs[index]['sender']);
                  },
                  itemCount: snapshot.data.docs.length,
                )
              : Container();
        });
  }

  sendMessages() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        'message': messageController.text,
        'sender': widget.userName,
        'time': DateTime.now().millisecondsSinceEpoch
      };

      DatabseService().sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageController.clear();
      });
    }
  }
}
