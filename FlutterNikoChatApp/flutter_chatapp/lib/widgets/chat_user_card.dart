import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/widgets/dialogs/profile_dialog.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  //Last Message info if null
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04,
      vertical: 4),
      elevation: 0.5,
      color: Colors.blue.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          //Navigating to chat screen
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot){
            final data = snapshot.data?.docs;
            final list = data
                ?.map((e) => Message.fromJson(e.data()))
                .toList() ??
                [];
            if(list.isNotEmpty){
              _message = list[0];
            }
          return ListTile(
            //User Profile Picture
            // leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
            leading: InkWell(
              onTap: (){
                showDialog(context: context,
                    builder: (_) => ProfileDialog(user: widget.user));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height *.03),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: widget.user.Image,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            //Username
            title: Text(widget.user.Name),
            //Last User Message
            subtitle: Text(_message != null ?
            _message!.type == Type.image ?
                'Image'
            :_message!.msg :widget.user.About,maxLines: 1,),
            //Last Message Time
            trailing: _message == null
                //Show nothing when no message sent
                ? null
            //Show container only if you haven't seen the others message
                : _message!.read.isEmpty && _message!.SenderId != APIs.user.uid?
            //Green Status showing Unread

            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade400,
                borderRadius: BorderRadius.circular(10)
              ),
            ) :
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context,
                  time: _message!.sent),
              style: const TextStyle(color: Colors.black38),),
          );
          }
        )
      ),
    );
  }
}
