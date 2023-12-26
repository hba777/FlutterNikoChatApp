import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chatapp/models/chat_user.dart';
import 'package:http/http.dart';

import '../models/message.dart';

class APIs {
  ///For authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  ///For accessing Database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  static User get user => auth.currentUser!;

  ///Firebase Messaging Access
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  ///For Getting Firebase Message Token
  static Future<void> getFirebaseMessagingToken() async{
    await fmessaging.requestPermission(
    );

    fmessaging.getToken().then((t) {
      if(t != null){
        me.pushToken = t;
        log('Push Token $t');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  ///Sending Notification
  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async{
    try{
      final body = {"to": chatUser.pushToken,
        "notification": {
          "title": chatUser.Name,
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data" : "User Id ${me.id}" ,
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            //Sending json data
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=AAAASZYfy1I:APA91bF_MfY6V1maKgaPSRFlQFYxNWj4dyN33Ln6Pp1_s_g9JKxqSSRdVABhL7pwjgeBgRPWs2ZeeuNm2gpd76IcRbOyEVk0R0l7HoYwAo86gNdlkitQthXCbkpZvbP_rm-_-Ag9Kss7'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');

      log(await read(Uri.https('example.com', 'foobar.txt')));
    }catch(e){
      log('\nsendPushNotification $e');
    }
  }
  ///Storing self info
  static late ChatUser me;

  ///Checking if user exists
  static Future<bool> userExists() async {
    return (await firestore.collection('Users').doc(user.uid).get()).exists;
  }

  ///For adding chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('Users')
        .where('Email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');
    
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //User Exists
      firestore.collection('Users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //User doesn't Exist
      log('Er: Doesnt exist');
      return false;
    }
  }

  ///Getting current user info
  static Future<void> getSelfInfo() async {
    (await firestore.collection('Users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);

        //CompileSdk must be set to 33 or check terminal
        await getFirebaseMessagingToken();

        //For setting user status to active
        //Set User Status to Active
        updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    }));
  }

  ///Creating new user
  static Future<void> createUser() async {
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    final chatUser = ChatUser(
        id: user.uid,
        Name: user.displayName.toString(),
        Email: user.email.toString(),
        About: 'Hey, Im Using Niko Chats',
        Image: user.photoURL.toString(),
        CreatedAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firestore
        .collection('Users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  ///Get All Users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds) {
    log('\nUserIds $userIds');

    return firestore
        .collection('Users')
        .where('id', whereIn: userIds)
        .snapshots();
  }

  ///for adding an user to my user when first message send
  static Future<void> sendFirstMessage(ChatUser chatUser,
      String msg, Type type) async {
    await firestore
        .collection('Users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({})
        .then((value) => sendMessage(chatUser, msg, type));
  }

  ///For Getting ids of known users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('Users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }


  ///Get User Specific Info. Stream used for continuous checking
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser
      ) {
    return firestore
        .collection('Users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  ///Update Active Status
  static Future<void> updateActiveStatus(bool isOnline) async{
    firestore
        .collection('Users')
        .doc(user.uid).update(
        {'is_Online': isOnline,
          'last_Active': DateTime.now().millisecondsSinceEpoch.toString(),
          'push_token': me.pushToken});
  }

  ///Updating user info
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('Users')
        .doc(user.uid)
    //Update and set difference.Update only update existing field, Set creates new field
        .update({'name': me.Name, 'About': me.About});
  }

  ///Updating user Profile Picture
  static Future<void> updateProfilePicture(File file) async {
    //Get image file extension
    final ext = file.path
        .split('.')
        .last;
    //Logging
    log('Extension $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //Uploading Image
    //Will take some time hence await
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((
        p0) {
      //Log file size in kbs
      log('Data Transferred: ${p0.bytesTransferred / 1000}');
    });

    //updating image in firestore database
    me.Image = await ref.getDownloadURL();
    await firestore
        .collection('Users')
        .doc(user.uid)
        .update({'Image': me.Image, 'About': me.About});
  }

  ///All Messages Related Stuff
  ///
  /// Chats collections -> conversation_id (doc) -> messages (collection) -->message (doc)

  ///Get Conversation Id
  static String getConversationId(String id) =>
      user.uid.hashCode <= id.hashCode
          ? '${user.uid}_$id'
          : '${id}_${user.uid}';

  ///Get All Messages
  // Getting current user info
  // Get All Users from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('Chats/${getConversationId(user.id)}/Messages/')
        // .orderBy('sent', descending: true)
        .snapshots();
  }

  ///For Sending Message
  static Future<void> sendMessage(ChatUser chatUser, String msg,
      Type type) async {
    //Message Sending time used as id
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    //Message to send
    final Message message = Message(
        msg: msg,
        RecieverId: chatUser.id,
        read: '',
        type: type,
        SenderId: user.uid,
        sent: time);
    final ref = firestore.collection(
        'Chats/${getConversationId(chatUser.id)}/Messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
    sendPushNotification(chatUser, type == Type.text ? msg : 'image'));

  }

  ///Update Read Status of Message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('Chats/${getConversationId(message.SenderId)}/Messages/')
        .doc(message.sent)
        .update({'read': DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()}
    );
  }

  ///Get Only Last Message from User
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('Chats/${getConversationId(user.id)}/Messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  ///Send Chat Image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //Get image file extension
    final ext = file.path
        .split('.')
        .last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime
            .now()
            .millisecondsSinceEpoch}.$ext');

    //Uploading Image
    //Will take some time hence await
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((
        p0) {
      //Log file size in kbs
      log('Data Transferred: ${p0.bytesTransferred / 1000}');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  ///Delete Message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('Chats/${getConversationId(message.RecieverId)}/Messages/')
        .doc(message.sent)
        .delete();

    if(message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  ///Update Message
  static Future<void> updateeMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('Chats/${getConversationId(message.RecieverId)}/Messages/')
        .doc(message.sent)
        .update({
      'msg': updatedMsg
    });
    
  }
}
