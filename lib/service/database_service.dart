import 'package:cloud_firestore/cloud_firestore.dart';

class DatabseService {
  final String? uid;
  DatabseService({this.uid});

  //refernce for our collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  //update userdata base
  Future updateUserData(String fullname, String email) async {
    return await userCollection.doc(uid).set({
      'fullName': fullname,
      'email': email,
      'groups': [],
      'profilePic': '',
      'uid': uid,
    });
  }

  Future getUserData(String email) async {
    QuerySnapshot querySnapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return querySnapshot;
  }

  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  //create groups struct
  Future createGroup(String userName, String id, String groupName) async {
    DocumentReference grpDocumentReference = await groupCollection.add({
      'groupName': groupName,
      'groupIcon': '',
      'admin': '${id}_$userName',
      'members': [],
      'groupId': '',
      'recentMessage': '',
      'recentMessageSender': '',
    });
    //update members
    await grpDocumentReference.update({
      'members': FieldValue.arrayUnion(['${uid}_$userName']),
      'groupId': grpDocumentReference.id,
    });

    //
    DocumentReference userDocumentReference = userCollection.doc(uid);
    return await userDocumentReference.update({
      'groups': FieldValue.arrayUnion(['${grpDocumentReference.id}_$groupName'])
    });
  }

  //getting the chat
  getChats(String grouId) async {
    return groupCollection
        .doc(grouId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  //get groupAdmin
  getGrpAdmin(String groupId) async {
    DocumentReference documentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot['admin'];
  }

  // get grp members
  getGroupMemebers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  //search groups
  searchByName(String groupName) {
    return groupCollection.where('groupName', isEqualTo: groupName).get();
  }

  //function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
    if (groups.contains('${groupId}_$groupName')) {
      return true;
    } else {
      return false;
    }
  }

  //toggle thw join and exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    //if group contains our user then remove /join them
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(['${uid}_$userName'])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(['${uid}_$userName'])
      });
    }
  }

  //send message
  sendMessage(String groupId, Map<String, dynamic> chatMessage) async {
    groupCollection.doc(groupId).collection('messages').add(chatMessage);
    groupCollection.doc(groupId).update({
      'recentMessage': chatMessage['message'],
      'recentMessageSender': chatMessage['sender'],
      'recentMessageTime': chatMessage['time'].toString()
    });
  }
}
