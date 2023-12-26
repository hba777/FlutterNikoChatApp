import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/screens/view_profile_screen.dart';

import '../../main.dart';
import '../../models/chat_user.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [

            //Profile Picture
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  width: mq.height * .2,
                  height: mq.height * .2,
                  fit: BoxFit.cover,
                  imageUrl: user.Image,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.person),
                ),
              ),
            ),

            //Username
            Positioned(
              left: mq.width * .04,
              top: mq.height * .01,
              //Set Max width
              width: mq.width * .55,
              child: Text(
                user.Name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            //Info Icon
            Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                    onPressed: () {
                      //Remove Current Screen
                      Navigator.pop(context);
                      
                      Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) =>
                      ViewProfileScreen(user: user)));
                    },
                    minWidth: 0,
                    padding: EdgeInsets.all(0),
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 30,
                    )))
          ],
        ),
      ),
    );
  }
}
